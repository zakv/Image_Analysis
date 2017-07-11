function [ OD ] = quick_back_removal_eig( saving_path, image_in, row_min, row_max, col_min, col_max, back_image )
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

max_input_backs=50; %Maximum number of background images to use

%First get the most recent files, up to max_input_backs of them
ls_pattern=fullfile(saving_path,'*_back.ascii');
file_list=get_recent_file_list(ls_pattern,max_input_backs);

%Turns out the saved fluorescence images have different dimensions, which
%messes up the code.  We'll tell the make_basis_eig() to only use images
%the same size as image_in
desired_size=size(image_in);

%The eigenfaces code doesn't like it when too few images are used to make a
%basis, so if we have too few files we'll fall back to the naive background
%subtraction algorithm
OD_old=-1*log(abs(image_in)./abs(back_image));
if length(file_list)<=2
    OD=OD_old;
else
    
    %Make background region
    back_region = make_back_region(image_in,row_min,row_max,col_min,col_max);
    
    %Make a basis
    max_vectors = 20; %20 is typically a good number for this
    %Disable this inconsequential warning that seems to only occur for old
    %Matlab versions
    warning('off','MATLAB:eigs:TooManyRequestedEigsForRealSym');
    [basis_eig, mean_back] = make_basis_eig(file_list,back_region,max_vectors,desired_size);
    warning('on','MATLAB:eigs:TooManyRequestedEigsForRealSym');
    
    %Use the basis to get the atomic cloud's optical depth
    OD = get_OD_eig(image_in,basis_eig,mean_back,back_region);
    
    %The eigenfaces algorithm can go crazy if the camera misbehaves.  In
    %such cases the reconstructed background can have negative values,
    %which causes the calculated OD to be complex instead of purely real.
    %If that happens, we'll just fall back to the old simple algorithm.
    if ~isreal(OD)
        disp('Eigenfaces had some issues, using old method instead');
        OD=OD_old;
    end
    
end

end

