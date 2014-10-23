classdef Image < dynamicprops
    %Stores the image data for one imaging
    %   This includes the raw_image, background image (back_image), the
    %   image (with background removed), and appropriate metadata.
    
    properties
        %Region of Interest
        ROI %will have xmin xmax, ymin, ymax attributes
        back_ROI %Region to use for scaling background signal (coordinates relative to ROI)
        
        %Actual Image data
        raw_image_filename=''; %image with signal over background
        raw_image=[];
        back_image_filename=''; %image of background signal
        back_image=[];
        image=[]; %image with background removed
        
        %Notes
        notes=''; %String that can be used to store notes about this acquisition
    end
    
    %Initialization
    methods
        function [self]=Image(image_name)
            %Initializes and image instance
            %   image_name should be the name (with path but without
            %   extension) of the image data.  The raw_image should have
            %   the name image_name.ascii and the background data should
            %   have the name image_name_back.ascii
            if nargin > 0
                %Determine file names
                self.set_file_names(image_name);
                
                %Set default values for initial parameters
                self.set_default_values();
                
                %Load data
                self.load_raw_image();
                self.load_back_image();
                
                %Remove background
                self.remove_background();
                
                %Free up memmory %Change of plans, let's keep this data
                %around for now for debugging purposes.
                %                 self.unload_raw_image();
                %                 self.unload_back_image();
            end
        end
        
        function [] = set_file_names(self,image_name)
            %Determines the file names for raw_data and back_data
            self.raw_image_filename=[image_name,'.ascii'];
            self.back_image_filename=[image_name,'_back.ascii'];
        end
        
        function [] = set_default_values(self)
            %This function sets default values when an Image instance is
            %initialized.
            
            %Set Region of Interest
            self.ROI.xmin=71; %51;
            self.ROI.xmax=260; %250;
            self.ROI.ymin=101;
            self.ROI.ymax=270;
            
            %Set background Region of Interest
            %  Coordinates are relative to the ROI, not the original image.
            %  This region is used to figure out how to scale the
            %  background before subtracting it from raw_data.
            self.back_ROI.xmin=131;
            self.back_ROI.xmax=180;
            self.back_ROI.ymin=110;
            self.back_ROI.ymax=140;
        end
    end
    
    %Metadata Manipulation
    methods
        function [] = add_metadata(self,name,value)
            %Adds a new attribute called name and assigns it to be value
            %   name should be a string
            addprop(self,name);
            self.(name)=value;
        end
        
        function [] = set_metadata(self,name,value)
            %Sets the value of the given metadata
            %   name should be a string giving the name of the property and
            %   value should be the desired value of that property
            self.(name)=value;
        end
        
        function [ value, exists ] = get_metadata(self,name)
            %Checks to see if the instance has attribute name and returns
            %its value
            %  If the property exists, its value is returned as value.  If
            %  the property does not exist, value=[] is returned.
            %  Returns exists=1 if the property exists or 0 if it doesn't.
            temp=self.findprop(name);
            exists=0;
            value=[];
            if temp.isvalid()
                exists=1;
                value=self.(name);
            end
        end
    end
    
    %Data Manipulation/Calculation
    methods
        function [ROI_image_array] = extract_ROI(self,image_array)
            %Returns an array cointaining the region of interest of the
            %given array
            local_ROI=self.ROI;
            ROI_image_array=image_array(local_ROI.xmin:local_ROI.xmax, local_ROI.ymin:local_ROI.ymax);
        end
        
        function [] = remove_background(self)
            %Removes the background from raw_data
            
            %Multiple choices for algorithms
            %self.back_simple_subtract();
            self.back_scaled_subtract();
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
    end
    
    %Hidden helper subfunctions
    methods (Hidden)
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
            local_ROI=self.back_ROI;
            raw_region=self.raw_image(local_ROI.xmin:local_ROI.xmax, local_ROI.ymin:local_ROI.ymax);
            back_region=self.back_image(local_ROI.xmin:local_ROI.xmax, local_ROI.ymin:local_ROI.ymax);
            scaling=sum(raw_region(:))/sum(back_region(:));
            self.image=self.raw_image-scaling*self.back_image;
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
    end
    
end

