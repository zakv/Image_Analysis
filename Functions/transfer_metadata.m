function [] = transfer_metadata(object1,object2)
%Copies all of the properties of object1 to object2
%   Copies the values of the object1 properties as well. Overwrites any
%   existing properties of object2 with the new data.

%Get a list of the object1's properties
props=fieldnames(object1);
j_max=length(props);
for j=1:j_max
    prop=props{j};
    %Add property, or update property value if it already exists
    set_metadata(object2,prop,object1.(prop));
end
end