function [object3] = combine_metadata(object1,object2)
%Copies all of the properties of object1 to object2 and returns it as
%object3.  If both objects have the same property, object1's data is used.

object3=struct();
object_list={object2,object1}; %object1 second so it's data takes priority
for j1=1:length(object_list)
    %Get a list of the object's properties
    object=object_list{j1};
    props=fieldnames(object);
    j_max=length(props);
    for j2=1:j_max
        prop=props{j2};
        %Add property, or update property value if it already exists
        object3.(prop)=object.(prop);
    end
end
end

