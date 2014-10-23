classdef Image < dynamicprops
    %Stores the image data for one imaging
    %   This includes the raw_image, background image (back_image), the
    %   image (with background removed), and appropriate metadata.
    %To implement: metadata support (maybe use dynamic properties?)
    
    properties
        %Region of Interest
        ROI %will have xmin xmax, ymin, ymax attributes
        
        %Actual Image data
        raw_image_filename=''; %image with signal over background
        raw_image=[];
        back_image_filename=''; %image of background signal
        back_image=[];
        image=[]; %image with background removed
    end
    
    methods
        function [self]=Image(image_name)
            %Initializes and image instance
            %   image_name should be the name (with path but without
            %   extension) of the image data.  The raw_image should have
            %   the name image_name.ascii and the background data should
            %   have the name image_name_back.ascii
            if nargin > 0
                %Determine file names
                self.raw_image_filename=[image_name,'.ascii'];
                self.back_image_filename=[image_name,'_back.ascii'];
                
                %Set default values for initial parameters
                self.ROI.xmin=50;
                self.ROI.xmax=250;
                self.ROI.ymin=100;
                self.ROI.ymax=250;
                
                %Load data
                self.load_raw_image();
                self.load_back_image();
                
                %Remove background
                self.remove_background();
                
                %Free up memmory
                self.unload_raw_image();
                self.unload_back_image();
            end
        end
        
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
        
        function [ROI_image_array] = extract_ROI(self,image_array)
            %Returns an array cointaining the region of interest of the
            %given array
            local_ROI=self.ROI;
            ROI_image_array=image_array(local_ROI.xmin:local_ROI.xmax, local_ROI.ymin:local_ROI.ymax);
        end
        
        function [] = remove_background(self)
            %Subtracts the background from the raw image data
            %   In the future this algorithm should be improved
            self.image=self.raw_image-self.back_image;
        end
    end
    
    methods (Static)    
        function [image_array] = load_image_data(filename)
            %Returns an array containing the data from filename
            image_array=importdata(filename);
        end
    end
    
end

