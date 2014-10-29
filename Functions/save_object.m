function [ ] = save_object( object, file_name ) %#ok<INUSL>
%Saves an object to the hard drive
%   Paired with load_obj().  Can be used to easily save and load arbitrary
%   objects without having to deal with getting them into/out of  a
%   workspace to use a .mat 

if length(file_name)<4 || ~strcmp(file_name(end-3:end),'.mat')
    file_name=strcat(file_name,'.mat');
end
save(file_name,'object');

end

