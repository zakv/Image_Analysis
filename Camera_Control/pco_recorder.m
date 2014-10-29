function [errorCode,glvar] = pco_recorder(glvar,imacount)
%
%   [errorCode,glvar] = pco_recorder(glvar,imacount)
%
%	* Input parameters :
%		struct     glvar
%                  imacount
%	* Output parameters :
%                  errorCode
%       struct     glvar
%
%records 'imacount' images into the internal memory of the pco.camera 
%the actual setup of the camera is used
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
%function workflow
%parameters are checked
%camera recording parameters are set to
%STORAGE_MODE_RECORDER and RECORDER_SUBMODE_SEQUENCE
%first camera segment is set as active segment
%size of segment ram is adjusted to record exactly 'imacount' images
%camera is armed
%camera is started
%the function  does wait in a loop,until all images are done
%errorCode and if available glvar is returned
%
%remark:
%the camera will hold all setting and images in segment1 until power is switched off
%or new recording is done

%Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamExport.h','alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

if(~exist('imacount','var'))
 imacount = uint16(10);   
end

%imacount must be at least 2, this is the smallest size a segment can be
if(imacount <= 2)
 disp('Wrong image count, return')    
 errorCode=hex2int('A0004001');
 return;
end

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


%Declaration of variable CameraHandle 
%out_ptr is the CameraHandle, which must be used in all other libcalls
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

%test and print camera state
dwWarn=uint32(0);
dwErr=uint32(0);
dwStatus=uint32(0);
[errorCode,out_ptr,dwWarn,dwErr,dwStatus] = calllib('PCO_CAM_SDK', 'PCO_GetCameraHealthStatus', out_ptr,dwWarn,dwErr,dwStatus);

if(errorCode==0)
 if(bitand(dwStatus,hex2dec('00000001')))
  disp('PCO_CAMERA state is DEFAULT_STATE');
 end
 if(bitand(dwStatus,hex2dec('00000002')))
  disp('PCO_CAMERA state is SETTINGS_VALID');
 end
 if(bitand(dwStatus,hex2dec('00000004')))
  disp('PCO_CAMERA state is RECORDING_ON');
 end
else
 disp(['PCO_GetCameraHealthStatus failed with error ',num2str(errorCode,'%X')]);   
end

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
if(errorCode)
 disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%X')]);   
end

if(act_recstate~=0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
 if(errorCode)
  disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%X')]);   
 end    
end

%set STORAGE_MODE_RECORDER
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetStorageMode', out_ptr,0);
if(errorCode)
 disp(['PCO_SetStorageMode failed with error ',num2str(errorCode,'%X')]);   
end

%set RECORDER_SUBMODE_SEQUENCE
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode', out_ptr,0);
if(errorCode)
 disp(['PCO_SetRecorderSubmode failed with error ',num2str(errorCode,'%X')]);   
end

%set active ram segment
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetActiveRamSegment', out_ptr,1);
if(errorCode)
 disp(['PCO_SetActiveRamSegment failed with error ',num2str(errorCode,'%X')]);   
end

%arm camera, return if error
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode)
 disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
 if((do_close==1)&&(cam_open==1))
  disp('Close Camera and return');
  [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
  if(errorCode)
   disp(['PCO_CloseCamera ',num2str(errorCode,'%08X')]);   
  else
   disp('PCO_CloseCamera done');  
   if((exist('glvar','var'))&& ...
      (isfield(glvar,'camera_open'))&& ...
      (isfield(glvar,'out_ptr')))
    glvar.out_ptr=[];
    glvar.camera_open=0;
   end
   cam_open=0;
  end    
  if((unload==1)&&(cam_open==0))
   unloadlibrary('PCO_CAM_SDK');
   disp('PCO_CAM_SDK unloadlibrary done');
  end 
  return;   
 end
end

%set memory size of first segment to allow recording of imacount images
act_xsize=uint16(0);
act_ysize=uint16(0);
ccd_xsize=uint16(0);
ccd_ysize=uint16(0);

%use PCO_GetSizes because this always returns accurat image size for next recording
[errorCode,out_ptr,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,ccd_xsize,ccd_ysize);
if(errorCode)
 disp(['PCO_GetSizes failed with error ',num2str(errorCode,'%X')]);   
end

disp(['sizes: horizontal ',int2str(act_xsize),' vertical ',int2str(act_ysize)]);

%get Size of installed Camera memory
dwRamSize=uint32(0);
wPageSize=uint16(0);
[errorCode,out_ptr,dwRamSize,wPageSize]  = calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSize', out_ptr,dwRamSize,wPageSize);
if(errorCode)
 disp(['PCO_GetCameraRamSize failed with error ',num2str(errorCode,'%X')]);   
end

%get actual sizes of Segments
dwSegment=zeros(1,4,'uint32');
[errorCode,out_ptr,dwSegment]  = calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSegmentSize', out_ptr,dwSegment);
if(errorCode)
 disp(['PCO_GetCameraRamSegmentSize failed with error ',num2str(errorCode,'%X')]);   
end

dwImageMemsize=uint32((uint32(act_xsize)*uint32(act_ysize))/uint32(wPageSize));
if(rem(dwImageMemsize,uint32(wPageSize))>0)
 dwImageMemsize=dwImageMemsize+1;
end

dwSegmentSize=dwImageMemsize*uint32(imacount);

if(dwRamSize<dwSegmentSize)
 disp(['Not enough memory to record ',int2str(imacount),' images ']);   
 imacount=dwRamSize/dwImageMemsize;
 disp(['imagecount is set to ',int2str(imacount)]);
end

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSegmentSize', out_ptr,dwSegment);
if(errorCode)
 disp(['PCO_GetCameraRamSegmentSize failed with error ',num2str(errorCode,'%X')]);   
end

dwSegment(1)=dwSegmentSize;

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize', out_ptr,dwSegment);
if(errorCode)
 disp(['PCO_SetCameraRamSegmentSize failed with error ',num2str(errorCode,'%X')]);   
end

[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode)
 disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
 if((do_close==1)&&(cam_open==1))
  disp('Close Camera and return');
  [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
  if(errorCode)
   disp(['PCO_CloseCamera ',num2str(errorCode,'%08X')]);   
  else
   disp('PCO_CloseCamera done');  
   if((exist('glvar','var'))&& ...
      (isfield(glvar,'camera_open'))&& ...
      (isfield(glvar,'out_ptr')))
    glvar.out_ptr=[];
    glvar.camera_open=0;
   end
   cam_open=0;
  end    
  if((unload==1)&&(cam_open==0))
   unloadlibrary('PCO_CAM_SDK');
   disp('PCO_CAM_SDK unloadlibrary done');
  end 
  return;   
 end
end

%now we look if enough memory is assigned to the memory segment
dwValidImageCnt=uint32(0);
dwMaxImageCnt=uint32(0);
[errorCode,h,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,1,dwValidImageCnt,dwMaxImageCnt);
if(errorCode)
 disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);   
end

%increase or decrease segment_size to adjust for correct dwMaxImageCnt
if(dwMaxImageCnt<uint32(imacount))
 disp('dwMaxImageCnt<imacount');   
 while(dwMaxImageCnt<imacount)
  dwSegmentSize=dwSegmentSize+wPageSize/32;
  dwSegment(1)=dwSegmentSize;
  [errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize', out_ptr,dwSegment);
  if(errorCode)
   disp(['PCO_SetCameraRamSegmentSize failed with error ',num2str(errorCode,'%X')]);   
  end
  [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
  if(errorCode)
   disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
  end
%now we look if enough memory is assign to the memory segment
  [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,1,dwValidImageCnt,dwMaxImageCnt);
  if(errorCode)
   disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);   
  end
 end
elseif(dwMaxImageCnt>uint32(imacount))
 disp('dwMaxImageCnt>imacount');   
 while(dwMaxImageCnt>imacount)
%decrease segment_size a little bit to get enough memory
  dwSegmentSize=dwSegmentSize-wPageSize/32;
  dwSegment(1)=dwSegmentSize;
  [errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize', out_ptr,dwSegment);
  if(errorCode)
   disp(['PCO_SetCameraRamSegmentSize failed with error ',num2str(errorCode,'%X')]);   
  end
  [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
  if(errorCode)
   disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
  end
%now we look if enough memory is assign to the memory segment
  [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,1,dwValidImageCnt,dwMaxImageCnt);
  if(errorCode)
   disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);   
  end
 end
end
  
disp(['segment 1:  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);

%clear all data in active segment
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ClearRamSegment', out_ptr);
if(errorCode)
 disp(['PCO_ClearRamSegment failed with error ',num2str(errorCode,'%X')]);   
end

%get time in ms, which is used for one image
dwSec=uint32(0);
dwNanoSec=uint32(0);
[errorCode,out_ptr,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
if(errorCode)
 disp(['PCO_GetCOCRuntime failed with error ',num2str(errorCode,'%X')]);   
end

waittime_s = double(dwNanoSec);
waittime_s = waittime_s / 1000000000;
waittime_s = waittime_s + double(dwSec);

disp(sprintf('one frame needs %6.6fs, maximal frequency %6.3fHz',waittime_s,1/waittime_s));

%now we start the camera and wait until all images are done
%camera does stop of recording automatically
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 1);
if(errorCode)
 disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%X')]);   
end    

[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
if(errorCode)
 disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%X')]);   
end

waittime_s = double(uint32((waittime_s+ 0.001)*1000))/1000;
pause(waittime_s);

while((act_recstate)&&(errorCode==0))
 [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,1,dwValidImageCnt,dwMaxImageCnt);
 if(errorCode)
  disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);   
 end
 disp(['segment 1:  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);
 pause(waittime_s);
 [errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
 if(errorCode)
  disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%X')]);   
 end
end

disp([int2str(imacount),' images done ']);

%camera returns a warning, because recording is already stopped
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
if(bitand(dwStatus,hex2dec('C0000000'))==hex2dec('80000000'))
 disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%X')]);   
else
 errorCode=0;    
end    

if((do_close==1)&&(cam_open==1))
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
 if(errorCode)
  disp(['PCO_CloseCamera failed with error ',num2str(errorCode,'%X')]);   
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

clear ph_ptr;
clear dwWarn dwErr dwStatus;
clear dwSec dwNanoSec waittime_s;
clear act_xsize act_ysize ccd_xsize ccd_ysize;
clear dwRamSize wPageSize;
clear dwSegment dwSegmentSize;
clear dwValidImageCnt dwMaxImageCnt;

if((unload)&&(cam_open==0))
 unloadlibrary('PCO_CAM_SDK');
 disp('PCO_CAM_SDK unloadlibrary done');
end

if((exist('glvar','var'))&& ...
  (isfield(glvar,'camera_open')))
 glvar.camera_open=cam_open;
end

end 
