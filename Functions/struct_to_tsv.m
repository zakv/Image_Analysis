function [ output_args ] = struct_to_tsv( input_struct, filename )
%Takes a struct and saves it as a tsv with the first column being the
%property names and the second being the corresponding property value
%
%   Inputs:
%   *input_struct should be a struct which you would like to save.  It's
%   property values must be able to be converted to strings with num2str.
%   Note that num2str is ok with accepting strings as inputs as well as
%   numbers.  To avoid conflicts with the .tsv format, we'll strip any
%   tab characters from the data
%   *filename should give the name of the file to be saved, including path
%   and file extension
%
%   Notes:
%   *This function converts the struct to a 2-column cell array and then
%   calls metadata_to_tsv();

%First get the properties of the struct
properties=fieldnames(input_struct);

%Convert to cell array
nRows=length(properties);
metadata=cell(nRows,2); %preallocate
for row=1:nRows
    property_string=properties{row};
    metadata{row,1}=property_string; %first column is property
    metadata{row,2}=input_struct.(property_string); %second column is property value
end

%Call metadata_to_tsv to actually write the file
metadata_to_tsv(metadata,filename);

end

