function [ OD_eig ] = quick_back_removal_eig( saving_path, image_in, row_min, row_max, col_min, col_max, back_image )
%Does a quick background removal and returns a 2D array giving the cloud OD
%   This function uses the 50 most recent background images in saving_path
%   (or fewer if there are less than 50 in that directory) with the
%   eigenfaces absorption imaging code to calculate the cloud's optical
%   depth.
%
%   saving_path should be a string giving the path to the directory of
%   images
%
%   raw_image_filename should be a string giving the name (without the
%   path) of the image to remove the background from.
%
%   row_min etc. should be indices specifying where in image_in the atoms
%   are located.  The should be contained within the square of the image
%   specified by these indices
%
%   back_image should be a 2D array of the background image.  It is not
%   used unless there are not enough background images available in
%   saving_path to use the eigenfaces code.  If there are too few images
%   there, then back_image is used to do the naive background subtraction
%   algorithm.
%
%   temppart will be a 2D array giving the OD of the cloud (after the
%   background has been removed)

%First get the most recent files, up to 50 of them
all_files=dir( fullfile(saving_path,'*_back.ascii') );
[~, sorting_indices]=sort([all_files.datenum],'descend');
all_files=all_files(sorting_indices); %all the '*_back.ascii' files sorted
recent_files=all_files( 1:min(50,end) ); %Take up to 50 most recent files
file_list={recent_files.name}'; %Convert to cell array of strings
file_list=fullfile(saving_path,file_list); %Include directory in filenames

%The eigenfaces code doesn't like it when too few images are used to make a
%basis, so if we have too few files we'll fall back to the naive background
%subtraction algorithm
if length(file_list)<=2
    OD_eig=-1*log(abs(image_in)./abs(back_image));
else
    
    %Make background region
    back_region = make_back_region(image_in,row_min,row_max,col_min,col_max);
    
    %Make a basis
    max_vectors = 20; %20 is typically a good number for this
    %Disable this inconsequential warning that seems to only occur for old
    %Matlab versions
    warning('off','MATLAB:eigs:TooManyRequestedEigsForRealSym');
    [basis_eig, mean_back] = make_basis_eig(file_list,back_region,max_vectors);
    warning('on','MATLAB:eigs:TooManyRequestedEigsForRealSym');
    
    %Use the basis to get the atomic cloud's optical depth
    OD_eig = get_OD_eig(image_in,basis_eig,mean_back,back_region);
    
end

end

