classdef Image < dynamicprops
    %Stores the image data for one imaging
    %   This includes the raw_image, background image (back_image), the
    %   image (with background removed), and appropriate metadata.
    
    %Typical properties
    properties
        back_ROI %Region to use for scaling background signal (coordinates relative to ROI)
        
        %Actual Image data
        image_name=''; %Name of this image series
        timestamp=[]; %time at which the image was taken
        raw_image_filename=''; %image with signal over background (includes path)
        raw_image=[]; %data from the raw_image file
        back_image_filename=''; %image of background signal (includes path)
        back_image=[]; %data from the back_image file
        noise_image_filename=''; %image of noise (includes path)
        noise_image=[]; %data from the noise_image file
        image=[]; %image with background removed
        
        %Other
        self_filename %File name used to save this instance of this class (includes path)
        run_config %Configuration paramters sent to Main_PCO_... during this acquisition
        index %Number indexing this image in the series of images taken
        notes=''; %String that can be used to store notes about this acquisition
    end
    
    %Protected properties
    properties (SetAccess=private)
        ROI %Region of interest of the pictures.  Struct with row_min row_max, col_min, col_max attributes
        dir=''; %directory storing this data
    end
    
    %Hidden properties
    properties (Hidden)
        raw_image_string=''; %name of the raw image file without path
        back_image_string=''; %name of the background image file without path
        noise_image_string=''; %name of the noise file without path
        self_string
    end
    
    %Dependent properties
    properties (Dependent)
        has_raw_image %Returns true if the raw image file exists
        has_back_image %Returns true if the background image file exists
        has_noise_image %Returns true if the noise image files exists
    end
    
    %Initialization
    methods
        function [self]=Image(image_name,index)
            %Initializes an image instance
            %   image_name should be the name (without path or filetype
            %   extension of the image data.  index is a number used to
            %   keep track of all the different images from one series of
            %   photos.
            if nargin > 0
                %Determine file names
                self.index=index;
                self.set_file_names(image_name,index);
                
                %Set default values for initial parameters
                self.set_default_values();
            end
        end
        
        function [] = set_file_names(self,image_name,index)
            %Determines the file names for raw_data, back_data and
            %noise_data
            
            %Just in case image_name includes relative path
            [path,image_name,ext]=fileparts( fullfile(pwd,image_name) );
            image_name=[image_name,ext]; %allows image names with '.' characters
            self.set_file_names_helper(path,image_name,index);
        end
        
        function [] = set_default_values(self)
            %This function sets default values when an Image instance is
            %initialized.
            
            %Set Region of Interest
            self.ROI.row_min=1;%71; %51;
            self.ROI.row_max=2;%260; %250;
            self.ROI.col_min=1;%101;
            self.ROI.col_max=2;%270;
            
            %Set background Region of Interest
            %  Coordinates are relative to the ROI, not the original image.
            %  This region is used to figure out how to scale the
            %  background before subtracting it from raw_data.
            self.back_ROI.row_min=1;%131;
            self.back_ROI.row_max=2;%180;
            self.back_ROI.col_min=1;%110;
            self.back_ROI.col_max=2;%140;
        end
    end
    
    %Metadata Manipulation
    methods
        function [] = add_metadata(self,name,value)
            %Adds a new attribute called name and assigns it to be value
            %   name should be a string
            z_add_metadata(self,name,value);
        end
        
        function [] = set_metadata(self,name,value)
            %Sets the value of the given metadata
            %   name should be a string giving the name of the property and
            %   value should be the desired value of that property.
            %   This function will add the property to the instance if
            %   needed.
            z_set_metadata(self,name,value);
        end
        
        function [] = update_metadata(self,name,value)
            %Updates the value of the given metadata
            %   name should be a string giving the name of the property and
            %   value should be the desired value of that property.
            %   This function errors out if the instance does not already
            %   have the given property.
            z_update_metadata(self,name,value);
        end
        
        function [] = transfer_metadata(self,object)
            %Copies all of the properties of object to this Image instance
            %   Copies the values of the object properties as well.
            %   Overwrites any existing properties of this image instance
            %   with the new data.
            z_transfer_metadata(object,self)
        end
        
        function [ value, exists ] = get_metadata(self,name)
            %Checks to see if the instance has attribute name and returns
            %its value
            %  If the property exists, its value is returned as value.  If
            %  the property does not exist, value=[] is returned.
            %  Returns exists=1 if the property exists or 0 if it doesn't.
            [value,exists]=z_get_metadata(self,name);
        end
    end
    
    %Data Manipulation/Calculation/Plotting
    methods
        function [ROI_image_array] = extract_ROI(self,image_array)
            %Returns an array cointaining the region of interest of the
            %given array
            local_ROI=self.ROI;
            ROI_image_array=image_array(local_ROI.row_min:local_ROI.row_max, local_ROI.col_min:local_ROI.col_max);
        end
        
        function [] = remove_background(self)
            %Removes the background from raw_data
            
            has_back_image=self.has_back_image;
            has_noise_image=self.has_noise_image;
            %Multiple choices for algorithms
            if has_back_image && has_noise_image
                %Subtract noise then do scaled subtraction
                self.back_noise_scaled_subtract();
            elseif has_back_image && ~has_noise_image
                %Don't have noise data
                self.back_scaled_subtract()
            elseif ~has_back_image && has_noise_image
                %Just subtract out the noise
                self.back_noise_subtract();
            elseif ~has_back_image && ~has_noise_image
                %Just use raw image
                self.back_nothing();
            end
        end
        
        function [] = compare_row_sums(self)
            %Plots the row sums of raw_image, back_image, and image
            sum_direction=2;
            self.compare_sums_helper(sum_direction);
        end
        
        function [] = compare_col_sums(self)
            %Plots the row sums of raw_image, back_image, and image
            sum_direction=1;
            self.compare_sums_helper(sum_direction);
        end
        
        function [] = show_image(self)
            %displays the image data as a figure
            %   Automatically calls self.calc_image() if necessary
            if isempty(self.image)
                self.calc_image();
            end
            figure('WindowStyle','docked');
            scale=[ max(self.image(:)), max(self.image(:)) ];
            imshow(self.image,scale);
        end
        
        function [] = imagesc(self,varargin)
            %Creates a plot of image_array.image using imagesc
            %  Optional additional arguments are passed on to imagesc
            figure();
            imagesc(self.image,varargin{:});
            colorbar();
            title(Image.get_prefix(self.image_name,self.index));
        end
        
        function [] = calc_image(self)
            %Loads data from the hard drive and calculates the image data
            self.load_images();
            self.remove_background();
            %self.free_RAM(); %keep that data around for plotting
        end
    end
    
    %Memmory management
    methods
        function [] = load_raw_image(self)
            %Loads the raw image data from the harddrive
            self.raw_image=Image.load_image_data(self.raw_image_filename);
            self.raw_image=self.extract_ROI(self.raw_image);
        end
        
        function [] = unload_raw_image(self)
            %Deletes the raw_image from memmory to free it up
            self.raw_image=[];
        end
        
        function [] = load_back_image(self)
            %Loads the background image data from the harddrive
            self.back_image=Image.load_image_data(self.back_image_filename);
            self.back_image=self.extract_ROI(self.back_image);
        end
        
        function [] = unload_back_image(self)
            %Deletes the back_image from memmory to free it up
            self.back_image=[];
        end
        
        function [] = load_noise_image(self)
            %Loads the noise image data from the harddrive
            self.noise_image=Image.load_image_data(self.noise_image_filename);
            self.noise_image=self.extract_ROI(self.noise_image);
        end
        
        function [] = unload_noise_image(self)
            %Deletes the noise_image from memmory to free it up
            self.noise_image=[];
        end
        
        function [] = load_images(self)
            %Loads the image data from the hard drive if they exist
            if self.has_raw_image
                self.load_raw_image();
            end
            if self.has_back_image
                self.load_back_image();
            end
            if self.has_noise_image
                self.load_noise_image();
            end
        end
        
        function [] = free_RAM(self)
            %Removes less-important data from memmory
            self.unload_raw_image();
            self.unload_back_image();
            self.unload_noise_image();
        end
        
        function [] = save(self)
            %saves the image instance to the hard drive
           save_object(self,self.self_filename); 
        end
    end
    
    %Hidden helper subfunctions
    methods (Hidden)
        function [] = set_file_names_helper(self,dir,image_name,index)
            %Helper function used to set the filenames with paths
            self.dir=dir;
            self.image_name=image_name;
            prefix=Image.get_prefix(image_name,index);
            %Determine the names of the actual files
            self.raw_image_string=[prefix,'_raw.ascii'];
            self.back_image_string=[prefix,'_back.ascii'];
            self.noise_image_string=[prefix,'_noise.ascii'];
            self.self_string=[prefix,'.mat'];
            %Set the filenames
            self.raw_image_filename=fullfile(self.dir,self.raw_image_string);
            self.back_image_filename=fullfile(self.dir,self.back_image_string);
            self.noise_image_filename=fullfile(self.dir,self.noise_image_string);
            self.self_filename=fullfile(self.dir,self.self_string);
        end
        
        function [] = compare_sums_helper(self,sum_direction)
            %Performs the plotting for compare_row_sums and
            %compare_col_sums
            
            %Plot raw_image and back_image
            figure('WindowStyle','docked');
            title('Camera Data');
            hold on;
            Image.plot_array_sums(self.raw_image,sum_direction);
            Image.plot_array_sums(self.back_image,sum_direction,'r');
            legend('raw','back');
            hold off;
            
            %Plot background-removed data
            figure('WindowStyle','docked');
            Image.plot_array_sums(self.image,sum_direction);
            scaling=(sum(self.raw_image,sum_direction)./sum(self.back_image,sum_direction));
            title('Background Removed');
            
            %Plot the scaling (raw/background)
            figure('WindowStyle','docked');
            plot(scaling);
            title('(raw\_data row sum)/(back\_data row sum)');
        end
    end
    
    %Background Removal algorithms
    methods (Hidden)
        function [] = back_simple_subtract(self)
            %Simply subtracts back_data from raw_data
            
            %load data form hard drive if necessary
            if isempty(self.raw_image)
                self.load_raw_image();
            end
            if isempty(self.back_image)
                self.load_back_image();
            end
            
            %Do the math
            self.image=self.raw_image-self.back_image;
        end
        
        function [] = back_scaled_subtract(self)
            %Scales back_data before subtracting it from raw_data to
            %account for fluctuations in laser power.
            %   Scaling factor is determined by summing the data over
            %   back_ROI for both raw_data and back_data then taking the
            %   ratio.  Therefore back_ROI should be a region in the image
            %   in which the the imaging beam is easily visible, but the
            %   shadow of the MOT is not present.
            
            %load data from hard drive if necessary
            if isempty(self.raw_image)
                self.load_raw_image();
            end
            if isempty(self.back_image)
                self.load_back_image();
            end
            
            %Do the math
            local_ROI=self.back_ROI;
            raw_region=self.raw_image(local_ROI.row_min:local_ROI.row_max, local_ROI.col_min:local_ROI.col_max);
            back_region=self.back_image(local_ROI.row_min:local_ROI.row_max, local_ROI.col_min:local_ROI.col_max);
            scaling=sum(raw_region(:))/sum(back_region(:));
            self.image=self.raw_image-scaling*self.back_image;
        end
        
        function [] = back_noise_scaled_subtract(self)
            %Subtracts the noise then does scaled subtraction of the
            %background
            
            %load data from hard drive if necessary
            if isempty(self.raw_image)
                self.load_raw_image();
            end
            if isempty(self.back_image)
                self.load_back_image();
            end
            if isempty(self.noise_image)
                self.load_back_image();
            end
            
            %Do the math
            raw_image_adjusted=self.raw_image-self.noise_image;
            back_image_adjusted=self.back_image-self.noise_image;
            local_ROI=self.back_ROI;
            raw_region=raw_image_adjusted(local_ROI.row_min:local_ROI.row_max, local_ROI.col_min:local_ROI.col_max);
            back_region=back_image_adjusted(local_ROI.row_min:local_ROI.row_max, local_ROI.col_min:local_ROI.col_max);
            scaling=sum(raw_region(:))/sum(back_region(:));
            self.image=raw_image_adjusted-scaling*back_image_adjusted;
        end
        
        function [] = back_noise_subtract(self)
            %Just subtracts the noise from the raw image
            
            %load data from hard drive if necessary
            if isempty(self.raw_image)
                self.load_raw_image();
            end
            if isempty(self.noise_image)
                self.load_back_image();
            end
            
            %Do the math
            self.image=self.raw_image-self.back_image;
        end
        
        function [] = back_nothing(self)
            %Just sets the image to be the raw data
            
            %load data from hard drive if necessary
            if isempty(self.raw_image)
                self.load_raw_image();
            end
            
            %Do the math
            self.image=self.raw_image;
        end
    end
    
    %Getters and Setters
    methods
        function [exists] = get.has_raw_image(self)
            %Getter that figures out if the raw image file exists
            exists=false;
            if exist(self.raw_image_filename,'file')==2
                exists=true;
            end
        end
        
        function [exists] = get.has_back_image(self)
            %Getter that figures out if the background image file exists
            exists=false;
            if exist(self.back_image_filename,'file')==2
                exists=true;
            end
        end
        
        function [exists] = get.has_noise_image(self)
            %Getter that figures out if the background image file exists
            exists=false;
            if exist(self.noise_image_filename,'file')==2
                exists=true;
            end
        end
        
        function [] = set_ROI(self,varargin)
            %Use this function to change the ROI.
            %  Give this function either an ROI struct with attributes
            %  row_min, row_max, col_min, and col_max, or give it an array with entries
            %  in that order, or just give it four separate arguments in
            %  that order.
            %  Ex: image.set_ROI(ROI); %ROI.row_max=25, etc.
            %  Ex: image.set_ROI([row_min,row_max,col_min,col_max]);
            %  Ex: image.set_ROI(row_min,row_max,col_min,col_max);
            nargs=nargin-1; %Don't want to count self as an argument
            
            %Interpret input arguments
            if nargs==1
                arg=varargin{1};
                if isstruct(arg)
                    self.ROI=arg;
                elseif isnumeric(arg)
                    self.ROI.row_min=arg(1);
                    self.ROI.row_max=arg(2);
                    self.ROI.col_min=arg(3);
                    self.ROI.col_max=arg(4);
                end
            elseif nargs==4
                self.ROI.row_min=varargin{1};
                self.ROI.row_max=varargin{2};
                self.ROI.col_min=varargin{3};
                self.ROI.col_max=varargin{4};
            else
                msgIdent='Image:set_ROI:InvalidFunctionCall';
                msgString='Invalid arguments for function, see docs';
                error(msgIdent,msgString);
            end
            
            %Update data if necessary
            if ~isempty(self.raw_image) && self.has_raw_image
                self.load_raw_image();
            end
            if ~isempty(self.back_image) && self.has_back_image
                self.load_back_image();
            end
            if ~isempty(self.noise_image) && self.has_noise_image
                self.load_noise_image();
            end
            if ~isempty(self.image);
                self.calc_image();
            end
            
        end
        
        function [] = set_dir(self,dir)
            %Use this function to set the directory containing this
            %instance's data files
            
            %Update paths
            self.set_file_names_helper(dir,self.image_name,self.index);
            
            %Update data if necessary
            if ~isempty(self.raw_image) && self.has_raw_image
                self.load_raw_image();
            end
            if ~isempty(self.back_image) && self.has_back_image
                self.load_back_image();
            end
            if ~isempty(self.noise_image) && self.has_noise_image
                self.load_noise_image();
            end
            if ~isempty(self.image);
                self.calc_image();
            end
        end
        
        function [raw_image_full] = get_raw_image_full(self)
            %Returns an array with the entire image
            raw_image_full=Image.load_image_data(self.raw_image_filename);
        end
        
        function [back_image_full] = get_back_image_full(self)
            %Returns an array with the entire image
            back_image_full=Image.load_image_data(self.back_image_filename);
        end
        
        function [noise_image_full] = get_noise_image_full(self)
            %Returns an array with the entire image
            noise_image_full=Image.load_image_data(self.noise_image_filename);
        end
        
        function [raw_image_ROI] = get_raw_image_ROI(self)
            %Returns an array with the image data in the ROI
            raw_image_full=self.get_raw_image_full();
            raw_image_ROI=self.extract_ROI(raw_image_full);
        end
        
        function [back_image_ROI] = get_back_image_ROI(self)
            %Returns an array with the image data in the ROI
            back_image_full=Image.load_image_data(self.back_image_filename);
            back_image_ROI=self.extract_ROI(back_image_full);
        end
        
        function [noise_image_ROI] = get_noise_image_ROI(self)
            %Returns an array with the image data in the ROI
            noise_image_full=Image.load_image_data(self.noise_image_filename);
            noise_image_ROI=self.extract_ROI(noise_image_full);
        end
        
        function [image] = get.image(self)
            %Returns the image data; calculates it if necessary
            if isempty(self.image) && self.has_raw_image
                self.calc_image();
            end
            image=self.image;
        end
    end
    
    %Static Class methods
    methods (Static)
        function [image_array] = load_image_data(filename)
            %Returns an array containing the data from filename
            image_array=importdata(filename);
        end
        
        function [] = plot_array_sums(array,sum_direction,varargin)
            %Sums up the values in each row or column and plots the results
            %  Set sum_direction=2 to sum up each row, or sum_direction=1
            %  to sum up each column.
            %  Additional arguments may be specified, which will be passed
            %  along to the plot function so that you can specify
            %  linestyle, color, etc.
            rows=sum(array,sum_direction);
            plot(rows,varargin{:});
        end
        
        function [prefix] = get_prefix(image_name,index)
            %Returns the prefix used when calculating filenames
            prefix=[image_name, '_',num2str(index)];
        end
    end
    
end

