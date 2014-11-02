function [] = set_metadata(object,name,value)
%Sets the value of the given metadata of object
%   name should be a string giving the name of the property and value
%   should be the desired value of that property. This function will add
%   the property to the instance if needed.
if isprop(object,name)
    object.(name)=value;
else
    object.add_metadata(name,value);
end
end