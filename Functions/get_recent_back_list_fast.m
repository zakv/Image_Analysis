function [ file_list ] = get_recent_back_list_fast( saving_path, max_files )
%Returns a list of the most recent "*_back.ascii" files in saving_path
%   === Inputs ===
%   saving_path should be a string that specifies the directory in which to
%   look for the background image files.
%
%   max_files is the maximum number of file names to return.  Fewer than
%   max_files may be returned if not enough file names match ls_pattern.
%   If you don't want to limit the number of returned files, use the
%   function get_file_list() instead.
%
%   === Outputs ===
%   file_list is a linear cell array (a column vector) with a filename in
%   each cell.  The list will include the most recently modified files
%   based on the files' modification date returned by dir().  The length of
%   the list will be at most max_files.
%
%   === Notes ===
%   The modification times of the files correspond to when the files were
%   written to the hard drive.  This may not correspond to when the time
%   the images were taken with the camera.  For example, if the files are
%   copied from one computer to another, the modification times will
%   correspond to when each of the files were copied over.  If they are
%   copied in one big batch, they may not be copied written to the hard
%   drive in the order in which they were taken.
%
%   === Example Usage ===
%   >> saving_path = 'C:\Matlab_Pixelfly_USB_07102014\20180812';
%   >> max_files = 100;
%   >> file_list = get_recent_file_list(saving_path, max_files);

%First get the struct array of back files from dir
dir_string=fullfile(saving_path,'*_back.ascii');
file_list=dir(dir_string);

%Extract the modification times for sorting
mod_times={file_list.datenum}';
mod_times=cell2mat(mod_times);

%Make the file list into a cell array since that is the expected output
%type
file_list={file_list.name}';

%Now let's figure out the ordering of the modification times
[~, sorting_indices]=sort(mod_times,'descend');

%Now rearrange the files in file_list so that they are sorted
file_list=file_list(sorting_indices);

%Now let's trim file_list to be at most max_files long
file_list=file_list( 1:min(end,max_files) );

%Prepend path to all file names
file_list=fullfile(saving_path,file_list);

end