function [] = update_metadata(object,name,value)
%Updates the value of the given metadata
%   name should be a string giving the name of the property and value
%   should be the desired value of that property. This function errors out
%   if the instance does not already have the given property.
if isprop(object,name)
    object.(name)=value;
else
    msgIdent='Image:update_metadata:Nonexistent_Property';
    msgString='The given object does not have property %s';
    error(msgIdent,msgString,name);
end
end