function [errorCode,image_stack,glvar] = pco_get_image(glvar,first_image,imacount)
%
%   [errorCode,glvar,image_stack] = pco_get_image(glvar,first_image,imacount)
%
%	* Input parameters :
%		struct     glvar
%                  first_image
%                  imacount
%	* Output parameters :
%                  errorCode
%       struct     glvar
%       uint16(,,) image_stack
%
%does readout of 'imacount' images from the internal memory of the pco.camera 
%into the labview array image_stack starting from number 'first_image' 
%if 'first_image' is set to '0' and camera is recording, live images are
%readout
%
%
%structure glvar is used to set different modes for
%load/unload library
%open/close camera SDK
%
%glvar.do_libunload: 1 unload lib at end
%glvar.do_close:     1 close camera SDK at end
%glvar.camera_open:  open status of camera SDK
%glvar.out_ptr:      libpointer to camera SDK handle
%
%if glvar does not exist,
%the library is loaded at begin and unloaded at end
%the SDK is opened at begin and closed at end
%
%if first_image does not exist it is set to '1' for a stopped camera and
%set to '0' for a running camera
%
%if imacount does not exist, it is set to '1'
%
%function workflow
%parameters are checked
%Alignment for the image data is set to LSB
%the size of the images in the actual segment is readout from the camera
%labview arry is build
%allocate buffer(s) in camera SDK 
%to readout single images PCO_GetImageEx function is used
%to readout multiple images
%PCO_AddBufferEx and PCO_WaitforBuffer functions are used in a loop
%free previously allocated buffer(s) in camera SDK 
%errorCode, if available glvar, and the image_stack with uint16 image data is returned
%
%remark:
%the camera will hold all setting and images in segment1, until power is switched off
%or new recording is done

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamExport.h','alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

% Declaration of internal variables
if(~exist('imacount','var'))
 imacount = uint16(1);   
end

%if(~exist('first_image','var'))
% first_image = uint16(1);   
%end

if((exist('glvar','var'))&& ...
   (isfield(glvar,'do_libunload'))&& ...
   (isfield(glvar,'do_close'))&& ...
   (isfield(glvar,'camera_open'))&& ...
   (isfield(glvar,'out_ptr')))
 unload=glvar.do_libunload;    
 cam_open=glvar.camera_open;
 do_close=glvar.do_close;
else
 unload=1;   
 cam_open=0;
 do_close=1;
end


ph_ptr = libpointer('voidPtrPtr');

%libcall PCO_OpenCamera
if(cam_open==0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_OpenCamera', ph_ptr, 0);
 if(errorCode == 0)
  disp('PCO_OpenCamera done');
  cam_open=1;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'camera_open'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.camera_open=1;
   glvar.out_ptr=out_ptr;
  end 
 else
  disp(['PCO_OpenCamera failed with error ',num2str(errorCode,'%X')]);   
  if(unload)
   unloadlibrary('PCO_CAM_SDK');
   disp('PCO_CAM_SDK unloadlibrary done');
  end 
  return ;   
 end
else
 if(isfield(glvar,'out_ptr'))
  out_ptr=glvar.out_ptr;   
 end
end


act_recstate = uint16(10); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
if(errorCode)
 disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%08X')]);   
end

if(~exist('first_image','var'))
 if(act_recstate==0)    
  first_image=uint16(1);
 else
  first_image=uint16(0);
 end
else     
 if((act_recstate~=0)&&(first_image>0))
  [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
  if(errorCode)
   disp('PCO_SetRecordingState failed with error ',num2str(errorCode,'%08X'));
  end
 end
end

%set bitalignment LSB
bitalign=uint16(1);
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', out_ptr,bitalign);
if(errorCode)
 int32(errorCode)
end

%size of structure from file structsize.txt
%this file must be generated again if an other SC2_CAM.dll with new Header files is used
ml_cam_desc.wSize=uint16(436);
cam_desc=libstruct('PCO_Description',ml_cam_desc);
[errorCode,out_ptr,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
if(errorCode)
 disp(['PCO_GetCameraDescription failed with error ',num2str(errorCode,'%08X')]);   
end
bitpix=uint16(cam_desc.wDynResDESC);
bytepix=fix(double(bitpix+7)/8);

ml_cam_type.wSize=uint16(1364);
cam_type=libstruct('PCO_CameraType',ml_cam_type);
[errorCode,out_ptr,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
if(errorCode)
 disp(['PCO_GetCameraType failed with error ',num2str(errorCode,'%08X')]);   
end
interface=uint16(cam_type.wInterfaceType);

dwValidImageCnt=uint32(0);
dwMaxImageCnt=uint32(0);
[errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,1,dwValidImageCnt,dwMaxImageCnt);
if(errorCode)
 disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%08X')]);   
end

if(((first_image>0)&&(dwValidImageCnt==0))||(dwMaxImageCnt==0))
 disp('No images in Camera\n Close Camera and return');   
 if((do_close==1)&&(cam_open==1))
  errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
  if(errorCode)
   disp(['PCO_CloseCamera ',num2str(errorCode,'%08X')]);   
  else
   disp('PCO_CloseCamera done');
   cam_open=0;
   if((exist('glvar','var'))&& ...
      (isfield(glvar,'camera_open'))&& ...
      (isfield(glvar,'out_ptr')))
    glvar.out_ptr=[];
    glvar.camera_open=0;
   end
  end    
 end
 if((unload==1)&&(cam_open==0))
  unloadlibrary('PCO_CAM_SDK');
  disp('PCO_CAM_SDK unloadlibrary done');
 end 
 return;   
end    

act_xsize=uint16(0);
act_ysize=uint16(0);
max_xsize=uint16(0);
max_ysize=uint16(0);
%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,out_ptr,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,max_xsize,max_ysize);
if(errorCode)
 disp(['PCO_GetSizes failed with error ',num2str(errorCode,'%08X')]);   
end

%limit allocation of memory to 500Mbyte
if(double(imacount)*double(act_xsize)*double(act_ysize)*bytepix>500*1024*1024)     
 imacount=uint16(double(500*1024*1024)/(double(act_xsize)*double(act_ysize)*bytepix));
end

if(first_image>0)
 if(first_image>dwValidImageCnt)
  first_image=dwValidImageCnt;
 end
 if(first_image+imacount>dwValidImageCnt)
  imacount=dwValidImageCnt-first_image+1; 
 end
else
 if(imacount>1)
  imacount=1;
 end 
end 

disp(['Number of valid images:   ',int2str(dwValidImageCnt)]);
disp(['Number of first image:    ',int2str(first_image)]);
disp(['Number of images to grab: ',int2str(imacount)]);
disp(['Interface Type is:        ',int2str(interface)]);

if(imacount == 1)
 [errorCode,image_stack] = pco_get_image_single(out_ptr,first_image,bitpix,interface);
else
 [errorCode,image_stack] = pco_get_image_multi(out_ptr,first_image,imacount,bitpix,interface);
end

if(errorCode)
 disp(['pco_get_image_... failed with error ',num2str(errorCode,'%08X')]);   
end

%alignment was set to LSB
disp('Timestamp data of image: ');
if(imacount == 1)
 print_timestamp(image_stack,bitalign,bitpix);
else 
 for n=1:imacount   
  print_timestamp(image_stack(:,:,n),bitalign,bitpix);
 end
end

if((do_close==1)&&(cam_open==1))
 errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
 if(errorCode)
  disp(['PCO_CloseCamera failed with error ',num2str(errorCode,'%08X')]);   
 else
  disp('PCO_CloseCamera done');  
  cam_open=0;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'camera_open'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.out_ptr=[];
   glvar.camera_open=0;
  end
 end    
end

if((unload)&&(cam_open==0))
 unloadlibrary('PCO_CAM_SDK');
 disp('PCO_CAM_SDK unloadlibrary done');
end 

if((exist('glvar','var'))&& ...
   (isfield(glvar,'camera_open')))
 glvar.camera_open=cam_open;
end

end

function [errorCode,image_stack] = pco_get_image_single(out_ptr,first_image,bitpix,interface)

act_segment = uint16(0); 
[errorCode,out_ptr,act_segment] = calllib('PCO_CAM_SDK', 'PCO_GetActiveRamSegment', out_ptr,act_segment);
if(errorCode)
 disp(['PCO_GetActiveRamSegment failed with error ',num2str(errorCode,'%08X')]);   
 return;
end
disp(['Active Segment ',int2str(act_segment)]);

act_align = uint16(0); 
[errorCode,out_ptr,act_align] = calllib('PCO_CAM_SDK', 'PCO_GetBitAlignment', out_ptr,act_align);
if(errorCode)
 disp(['PCO_GetBitAlignment failed with error ',num2str(errorCode,'%08X')]);   
 return;
end
disp(['Actual Alignment ',int2str(act_align)]);

ml_strSegment.wSize=uint16(108);
strSegment=libstruct('PCO_Segment',ml_strSegment);
[errorCode,out_ptr,strSegment] = calllib('PCO_CAM_SDK', 'PCO_GetSegmentStruct', out_ptr,act_segment,strSegment);
if(errorCode)
 disp(['PCO_GetSegmentStruct failed with error ',num2str(errorCode,'%08X')]);   
 return;
end
disp(['Segmentstruct XRes ',int2str(strSegment.wXRes),'  YRes ',int2str(strSegment.wYRes)]);

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_CamLinkSetImageParameters', out_ptr,strSegment.wXRes,strSegment.wYRes);
if(errorCode)
 disp(['PCO_CamLinkSetImageParameters failed with error ',num2str(errorCode,'%08X')]);   
 return;
end

%get the memory for the images
%need special code for firewire interface
imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(strSegment.wYRes)* uint32(strSegment.wXRes); 
imasize=imas;

%only for firewire add always some lines
%to ensure enough memory is allocated for the transfer
if(interface==1)
  i=floor(double(imas)/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-double(imas);
  xs=uint32(fix((double(bitpix)+7)/8));
  xs=xs*strSegment.wXRes;
  i=floor(i/double(xs));
  i=i+1;
  lineadd=i;
 disp(['imasize is: ',int2str(imas),' aligned: ',int2str(imasize)]); 
 disp([int2str(lineadd),' additional lines must be allocated ']);   
else
 lineadd=0;   
end

image_stack=ones(strSegment.wXRes,strSegment.wYRes+lineadd,'uint16');

sBufNr=int16(-1);
im_ptr = libpointer('uint16Ptr',image_stack);
ev_ptr = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr,image_stack,ev_ptr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
if(errorCode)
 disp(['PCO_AllocateBuffer failed with error ',num2str(errorCode,'%08X')]);   
 return;
end

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,act_segment,first_image,first_image,sBufNr,strSegment.wXRes,strSegment.wYRes,bitpix);
if(errorCode)
 disp(['PCO_GetImageEx failed with error ',num2str(errorCode,'%08X')]);   
else
 disp(['pco_get_image_single: GetImageEx imagenumber ',int2str(first_image),' done']);
end

[errorCode,out_ptr,image_stack]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
if(errorCode)
 disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
end

for n=1:lineadd
% disp(['delete ',int2str(n), '. line at end']);
 image_stack(:,end)=[];
end

errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
if(errorCode)
 disp(['PCO_FreeBuffer failed with error ',num2str(errorCode,'%08X')]);   
end

clear ev_ptr;

end

function [errorCode,image_stack] = pco_get_image_multi(out_ptr,first_image,imacount,bitpix,interface)

if(imacount<2)
 disp('Wrong image count, must be 2 or greater, return')    
 errorCode=hex2int('A0004001');
 return;
end

act_segment = uint16(0); 
[errorCode,out_ptr,act_segment] = calllib('PCO_CAM_SDK', 'PCO_GetActiveRamSegment', out_ptr,act_segment);
if(errorCode)
 disp(['PCO_GetActiveRamSegment failed with error ',num2str(errorCode,'%08X')]);   
 return;
end

disp(['Active Segment ',int2str(act_segment)]);

act_align = uint16(0); 
[errorCode,out_ptr,act_align] = calllib('PCO_CAM_SDK', 'PCO_GetBitAlignment', out_ptr,act_align);
if(errorCode)
 disp(['PCO_GetBitAlignment failed with error ',num2str(errorCode,'%08X')]);   
 return;
end
disp(['Actual Alignment ',int2str(act_align)]);

ml_strSegment.wSize=uint16(108);
strSegment=libstruct('PCO_Segment',ml_strSegment);
[errorCode,out_ptr,strSegment] = calllib('PCO_CAM_SDK', 'PCO_GetSegmentStruct', out_ptr,act_segment,strSegment);
if(errorCode)
 disp(['PCO_GetSegmentStruct failed with error ',num2str(errorCode,'%08X')]);   
 return;
end
disp(['Segmentstruct XRes ',int2str(strSegment.wXRes),'  YRes ',int2str(strSegment.wYRes)]);

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_CamLinkSetImageParameters', out_ptr,strSegment.wXRes,strSegment.wYRes);
if(errorCode)
 disp(['PCO_CamLinkSetImageParameters failed with error ',num2str(errorCode,'%08X')]);   
 return;
end

%get the memory for the images
%need special code for firewire interface
imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(strSegment.wYRes)* uint32(strSegment.wXRes); 
imasize=imas;

%only for firewire
if(interface==1)
  i=floor(double(imas)/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-double(imas);
  xs=uint32(fix((double(bitpix)+7)/8));
  xs=xs*strSegment.wXRes;
  i=floor(i/double(xs));
  i=i+1;
  lineadd=i;
 disp(['imasize is: ',int2str(imas),' aligned: ',int2str(imasize)]); 
 disp([int2str(lineadd),' additional lines must be allocated ']);   
else
 lineadd=0;   
end

image_stack=ones(strSegment.wXRes,(strSegment.wYRes+lineadd),imacount,'uint16');

%Allocate 2 SDK buffer and set address of buffers in stack
sBufNr_1=int16(-1);
im_ptr_1 = libpointer('uint16Ptr',image_stack(:,:,1));
ev_ptr_1 = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr_1,image_stack(:,:,1),ev_ptr_1]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_1,imasize,im_ptr_1,ev_ptr_1);
if(errorCode)
 disp(['PCO_AllocateBuffer failed with error ',num2str(errorCode,'%08X')]);   
 return;
end

sBufNr_2=int16(-1);
im_ptr_2 = libpointer('uint16Ptr',image_stack(:,:,2));
ev_ptr_2 = libpointer('voidPtr');

[errorCode,out_ptr,sBufNr_2,image_stack(:,:,2),ev_ptr_2]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_2,imasize,im_ptr_2,ev_ptr_2);
if(errorCode)
 disp(['PCO_AllocateBuffer failed with error ',num2str(errorCode,'%08X')]);   
 errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr_1);
 if(errorCode)
  disp(['PCO_FreeBuffer failed with error ',num2str(errorCode,'%08X')]);   
 end
 return;
end
disp(['bufnr1: ',int2str(sBufNr_1),' bufnr2: ',int2str(sBufNr_2)]);
ml_buflist_1.sBufNr=sBufNr_1;
buflist_1=libstruct('PCO_Buflist',ml_buflist_1);
ml_buflist_2.sBufNr=sBufNr_2;
buflist_2=libstruct('PCO_Buflist',ml_buflist_2);

disp(['bufnr1: ',int2str(buflist_1.sBufNr),' bufnr2: ',int2str(buflist_2.sBufNr)]);

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,first_image,first_image,sBufNr_1,strSegment.wXRes,strSegment.wYRes,bitpix);
if(errorCode)
 disp(['PCO_AddBufferEx failed with error ',num2str(errorCode,'%08X')]);   
end
 
[errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,first_image+1,first_image+1,sBufNr_2,strSegment.wXRes,strSegment.wYRes,bitpix);
if(errorCode)
 disp(['PCO_AddBufferEx failed with error ',num2str(errorCode,'%08X')]);   
end

for n=1:imacount
 s='';
 if(rem(n,2)==1)
  disp(['Wait for buffer 1 n: ',int2str(n)]);   
  [errorCode,out_ptr,buflist_1]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,1,buflist_1,500);
  if(errorCode)
   disp(['PCO_WaitforBuffer 1 failed with error ',num2str(errorCode,'%08X')]);   
   break;
  end 
  disp(['statusdll: ',num2str(buflist_1.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_1.dwStatusDrv,'%08X')]);   
  if((bitand(buflist_1.dwStatusDll,hex2dec('00008000')))&&(buflist_1.dwStatusDrv==0))
   s=strcat(s,'Event buf_1, image ',int2str(first_image+n-1),' done, StatusDrv ',num2str(buflist_1.dwStatusDrv,'%08X'));
  %this will copy our data to image_stack
   [errorCode,out_ptr,image_stack(:,:,n)]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr_1,im_ptr_1,ev_ptr_1);
   if(errorCode)
    disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
   end
   buflist_1.dwStatusDll= bitand(buflist_1.dwStatusDll,hex2dec('FFFF7FFF'));
   if(n+2<=imacount)
    im_ptr_1 = libpointer('uint16Ptr',image_stack(:,:,n+2));
    [errorCode,out_ptr,sBufNr_1,image_stack(:,:,n+2),ev_ptr_1]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_1,imasize,im_ptr_1,ev_ptr_1);
    if(errorCode)
     disp(['PCO_AllocateBuffer failed with error ',num2str(errorCode,'%08X')]);   
     break; 
    end
    [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,first_image+n+1,first_image+n+1,sBufNr_1,strSegment.wXRes,strSegment.wYRes,bitpix);
    if(errorCode)
     disp(['PCO_AddBufferEx failed with error ',num2str(errorCode,'%08X')]);   
     break;
    end
    s=strcat(s,' set in queue again');
   end
   disp(s);
  end
 else 
  disp(['Wait for buffer 2 n: ',int2str(n)]);   
  [errorCode,out_ptr,buflist_2]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,1,buflist_2,500);
  if(errorCode)
   disp(['PCO_WaitforBuffer 2 failed with error ',num2str(errorCode,'%08X')]);   
   break;
  end 
  disp(['statusdll: ',num2str(buflist_2.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_2.dwStatusDrv,'%08X')]);   
  if(bitand(buflist_2.dwStatusDll,hex2dec('00008000'))&&(buflist_2.dwStatusDrv==0))
   s=strcat(s,'Event buf_2, image ',int2str(first_image+n-1),' done, StatusDrv ',num2str(buflist_2.dwStatusDrv,'%08X'));
  %this will copy our data to image_stack
   [errorCode,out_ptr,image_stack(:,:,n)]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr_2,im_ptr_2,ev_ptr_2);
   if(errorCode)
    disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
    break;
   end
   buflist_2.dwStatusDll= bitand(buflist_2.dwStatusDll,hex2dec('FFFF7FFF'));
   if(n+2<=imacount)
    im_ptr_2 = libpointer('uint16Ptr',image_stack(:,:,n+2));
    [errorCode,out_ptr,sBufNr_2,image_stack(:,:,n+2),ev_ptr_2]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr_2,imasize,im_ptr_2,ev_ptr_2);
    if(errorCode)
     disp(['PCO_AllocateBuffer failed with error ',num2str(errorCode,'%08X')]);   
     break; 
    end
    [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,first_image+n+1,first_image+n+1,sBufNr_2,strSegment.wXRes,strSegment.wYRes,bitpix);
    if(errorCode)
     disp(['PCO_AddBufferEx failed with error ',num2str(errorCode,'%08X')]);   
     break;
    end
    s=strcat(s,' set in queue again');
   end 
   disp(s);
  end
 end
end

for m=1:lineadd
 image_stack(:,end,:)=[];
end

%this will remove all pending buffers in the queue
%[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
%if(errorCode)
% disp(['PCO_CancelImages failed with error ',num2str(errorCode,'%08X')]);   
% return;
%end

%free buffers
errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr_1);
if(errorCode)
 disp(['PCO_FreeBuffer failed with error ',num2str(errorCode,'%08X')]);   
end
   
errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr_2);
if(errorCode)
 disp(['PCO_FreeBuffer failed with error ',num2str(errorCode,'%08X')]);   
end

end

function time=print_timestamp(ima,act_align,bitpix)

%ts=zeros(14,1,'double');  
if(act_align==0)
 ts=fix(double(ima(1:14,1))/(2^(16-bitpix)));   
else
 ts=double(ima(1:14,1));  
end

b='';
for x = 1:4
 b=[b,int2str(fix(ts(x,1)/16)),int2str(bitand(ts(x,1),15))];
end

b=[b,' '];
%year
b=[b,int2str(fix(ts(5,1)/16)),int2str(bitand(ts(5,1),15))];   
b=[b,int2str(fix(ts(6,1)/16)),int2str(bitand(ts(6,1),15))];   
b=[b,'-'];
%month
b=[b,int2str(fix(ts(7,1)/16)),int2str(bitand(ts(7,1),15))];   
b=[b,'-'];
%day
b=[b,int2str(fix(ts(8,1)/16)),int2str(bitand(ts(8,1),15))];   
b=[b,' '];

%hour   
c=[int2str(fix(ts(9,1)/16)),int2str(bitand(ts(9,1),15))];   
b=[b,c,':'];
time=str2double(c)*60*60;
%min   
c=[int2str(fix(ts(10,1)/16)),int2str(bitand(ts(10,1),15))];   
b=[b,c,':'];
time=time+(str2double(c)*60);
%sec   
c=[int2str(fix(ts(11,1)/16)),int2str(bitand(ts(11,1),15))];   
b=[b,c,'.'];
time=time+str2double(c);
%us   
c=[int2str(fix(ts(12,1)/16)),int2str(bitand(ts(12,1),15))];   
b=[b,c];
time=time+(str2double(c)/100);
c=[int2str(fix(ts(13,1)/16)),int2str(bitand(ts(13,1),15))];   
b=[b,c];
time=time+(str2double(c)/10000);
c=[int2str(fix(ts(14,1)/16)),int2str(bitand(ts(14,1),15))];   
b=[b,c];
time=time+(str2double(c)/1000000);
disp(b)
end

