function [ metadata_object ] = metadata_table_to_object( metadata_table )
%Given the metadata table from the GUI, returns an object with the
%specified properties and values.

%Iterate over table rows
jmax=size(metadata_table,1);
for j=1:jmax
    prop=metadata_table{j,1};
    if ~isempty(prop) %ignore blank rows
        val=metadata_table{j,2};
        %convert val to number if possible
        val_number=str2num(val); %#ok<ST2NM> %returns an empty array if conversion fails
        if ~isempty(val_number)
            val=val_number;
        end
        %Put data into output object
        metadata_object.(prop)=val;
    end
end

end

