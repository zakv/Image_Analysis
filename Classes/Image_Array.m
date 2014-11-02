classdef Image_Array < dynamicprops
    %Class to handle an array of Images corresponding to the same data
    %point
    %   For example, this class can be used for looking at the results of a
    %   series of measurements taken at one particular detuning that you
    %   would like to average together.  Comparing data from a series of
    %   different detunings should be handled by the Image_Series class
    
    %Public properties
    properties
        image_array %Actual array of image instances
        image_name %Name of images without index, file extension, or anything, Ex: 'SampleData'
    end
    
    %Private properties
    properties (SetAccess=private)
        n_images %Number of images in the array
        image %Averaged image data
    end
    
    %Initialization methods
    methods
        function [self] = Image_Array(image_name)
            %Initializes an Image_Array instance
            %   image_name should be the name of the series of iamges,
            %   without 'raw', index, file extenstion or anything like that.
            %   Ex: 'SampleData'
            %   This will automatically search through the current
            %   directory and look for the corresponding data files.
            if nargin>0
                self.image_name=image_name;
                self.create_image_array();
            end
        end
        
        function [] = create_image_array(self)
            %Creates the image array by searching the hard drive for data
            %corresponding to self.image_array
            
            %Figure out what data exists (i.e. what indices are available)
            prefix=Image.get_prefix(self.image_name,'*');
            expression=[prefix,'.mat'];
            file_list=dir(expression);
            j_max=length(file_list);
            index_list=zeros(1,j_max);
            for j=1:j_max
                file_name=file_list(j).name;
                reg_exp=Image.get_prefix(self.image_name,'(\d)');
                index=regexp(file_name,reg_exp,'tokens');
                index_list(j)=str2num(char(index{1})); %#ok<ST2NM>
            end
            
            %Iterate over the available indices to create the array
            self.n_images=j_max;
            image_array(j_max)=Image(); %#ok<*PROP>
            for j=1:j_max
                index=index_list(j);
                image_array(j)=Image(self.image_name,index);
            end
            self.image_array=image_array;
        end
    end
    
    %Data Manipulation/Calculation/Plotting
    methods
        function [] = calc_image(self)
            %Averages the images from the entries in self.image_array and
            %stores it as self.image
            
            %Only do calculation if the image_array is not empty
            if ~isempty(self.image_array)
                total=self.image_array(1).image;
                for j=2:self.n_images
                    total=total+self.image_array(j).image;
                end
                self.image=total/self.n_images();
            end
        end
    end
    
    %Getters and Setters
    methods
        function [image] = get.image(self)
            %Get method for self.image.  Calls self.calc_image() if
            %necesary.
            if isempty(self.image)
                self.calc_image();
            end
            image=self.image;
        end
    end
    
end

