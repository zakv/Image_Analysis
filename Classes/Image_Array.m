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
                self.aggreagate_metadata();
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
        
        function [] = aggregate_metadata(self)
            %If any properties are the same for all images in
            %self.image_array, this method adds them as properties of this
            %image_array instance.  Does not work for properties that are
            %structs
            if ~isempty(self.image_array) %Only do this if we have some images
                image=self.image_array(1);
                props=fieldnames(image);
                
                %Remove a few things that we don't want to include
                j1_max=length(props);
                removal_indices=[];
                for j1=1:j1_max
                    prop=props{j1};
                    if strcmp(prop,'image')
                        removal_indices(end+1)=j1; %#ok<AGROW>
                    elseif strcmp(prop,'image_name')
                        removal_indices(end+1)=j1; %#ok<AGROW>
                    end
                end
                props(removal_indices)=[]; %deletes those entries
                
                %now iterate over the rest of the images and keep track of
                %which properties are shared between all of them
                for j1=2:self.n_images
                    next_image=self.image_array(j1);
                    next_props=fieldnames(next_image);
                    %Drop any properties that only one image has.
                    common_props=intersect(props,next_props);
                    %Iterate over properties, only keep them if both images
                    %have the same value for that property
                    props={};
                    j2_max=length(common_props);
                    for j2=1:j2_max
                        prop=common_props{j2};
                        %Matlab can't compare structs, so we'll have to
                        %drop them
                        if ~isstruct(image.(prop))
                            if  image.(prop)==next_image.(prop)
                                props{end+1}=prop; %#ok<AGROW>
                            end
                        end
                    end
                end
                
                %Now have a list of properties that are shared between all
                %images and have the same values for all images.
                %add props to this image_array instance
                j1_max=length(props);
                for j1=1:j1_max
                    prop=props{j1};
                    self.set_metadata(prop,image.(prop));
                end
            end
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
    
    %Metadata Manipulation (mostly coppied from Image.m)
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
            %Copies all of the properties of object to this Image_Array
            %instance
            %   Copies the values of the object properties as well.
            %   Overwrites any existing properties of this Image_Array
            %   instance with the new data.
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
        
        function [] = set_all_metadata(self,name,value)
            %Sets image.(name) to be value for all images in image_array
            for j=1:self.n_images
                image=self.image_array(j);
                image.set_metadata(name,value);
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

