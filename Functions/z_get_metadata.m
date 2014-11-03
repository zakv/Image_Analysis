function [ value, exists ] = z_get_metadata(object,name)
%Checks to see if the object has attribute name and returns its value
%  If the property exists, its value is returned as value.  If the property
%  does not exist, value=[] is returned. Returns exists=1 if the property
%  exists or 0 if it doesn't.
temp=object.findprop(name);
exists=0;
value=[];
if temp.isvalid()
    exists=1;
    value=object.(name);
end
end