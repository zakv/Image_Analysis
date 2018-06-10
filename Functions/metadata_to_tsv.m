function [  ] = metadata_to_tsv( metadata, filename )
%Takes the metadata from the GUI and saves it to disk
%   The data in metadata is converted into strings then saved as a
%   tab-delimited file.  This function makes use of the fact that metadata
%   always has two columns.
%
%   Inputs:
%   *metadata should be 2-column cell array of data for the images.  It can
%   have any number of rows and can hold any data that can be represented
%   as a string.  To avoid conflicts with the .tsv format, we'll strip any
%   tab characters from the data
%   *filename should be the name
%
%   TODO:
%   *filename should have path and/or file extension?

%First let's get the metadata into the right form, i.e. strings without tab
[nRows,nCols] = size(metadata);
metadata_string=cell(nRows,nCols);
for row=1:nRows
    for col=1:nCols
        %Note: num2str doesn't cause issues if you give it a string
        string_version=num2str(metadata{row,col});
        %Remove any tab characters
        metadata_string{row,col}=strrep(string_version,sprintf('\t'),'');
    end
end

%Open the file for writing
fileID = fopen(filename,'w');

%Format for each row of the tsv: string, tab character, string, newline
formatSpec = '%s\t%s\n';

%Iterate over each row, writing it to the file
for row = 1:nRows
    fprintf(fileID,formatSpec,metadata_string{row,:});
end

%close the file when finished
fclose(fileID);
end

