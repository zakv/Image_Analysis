function [ pic ] = load_image( file_name )
%Loads the image instance from the hard drive
%   Use this function to load saved image instances.  It takes care of
%   setting the image.path attribute after the data has been loaded (in
%   case the data has moved)
%   file_name should include the path (relative or absolute) of the file if
%   it is not in the current working directory.  Including the '.mat'
%   extension is optional

pic=load_object(file_name);
pic.dir=zfileparts( fullfile(pwd,file_name) );

end

