function [object3] = combine_metadata(object1,object2)
%Copies all of the properties of object1 to object2 and returns it as
%object3.
%   Copies the values of object1 properties as well. Overwrites any
%   existing properties of object2 with the new data.  The new object with
%   data from both objects is returned becuase object2 cannot be modified
%   if isn't a subclass of the handle class.
%   This probably isn't the best way to do this since object2 will get
%   modified if it is a subclass of the handle class, but my first effort
%   to deal with this didn't work and I need to move on.  Maybe I'll come
%   back later to fix this.

%Get a list of the object's properties
props=fieldnames(object1);
j_max=length(props);
for j=1:j_max
    prop=props{j};
    %Add property, or update property value if it already exists
    object2.(prop)=object1.(prop);
end
object3=object2;
end

