function [ obj ] = load_object( file_name )
%Loads object that was saved with save_object()
%   Returns the object saved in the file of the given name.

if length(file_name)<4 || ~strcmp(file_name(end-3:end),'.mat')
    file_name=strcat(file_name,'.mat');
end
returned_object=load(file_name,'data');
obj=returned_object.object;

end

