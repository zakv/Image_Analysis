function [] = z_add_metadata(object,name,value)
%Adds a new attribute called name to object and assigns it to be value
%   name should be a string
addprop(object,name);
object.(name)=value;
end

