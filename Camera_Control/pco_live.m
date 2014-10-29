function pco_live(waittime)

glvar=struct('do_libunload',1,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('waittime','var'))
 waittime = 10;   
end

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamExport.h','alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

if((exist('glvar','var'))&& ...
   (isfield(glvar,'do_libunload'))&& ...
   (isfield(glvar,'do_close'))&& ...
   (isfield(glvar,'camera_open'))&& ...
   (isfield(glvar,'out_ptr')))
 unload=glvar.do_libunload;    
 cam_open=glvar.camera_open;
 do_close=1;
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

disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);

act_recstate = uint16(10); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
if(errorCode)
 disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%08X')]);   
end

%save actual RecoderSubmode
prev_rec_submode=uint16(10);
[errorCode,out_ptr,prev_rec_submode] = calllib('PCO_CAM_SDK', 'PCO_GetRecorderSubmode', out_ptr,prev_rec_submode);
if(errorCode)
 disp(['PCO_GetRecorderSubmode failed with error ',num2str(errorCode,'%X')]);   
end

%set RECORDER_SUBMODE_RING_BUFFER
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode', out_ptr,1);
if(errorCode)
 disp(['PCO_SetRecorderSubmode failed with error ',num2str(errorCode,'%X')]);   
end

%save active ram segment
prev_segment=uint16(10);
[errorCode,out_ptr,prev_segment] = calllib('PCO_CAM_SDK', 'PCO_GetActiveRamSegment', out_ptr,prev_segment);
if(errorCode)
 disp(['PCO_SetActiveRamSegment failed with error ',num2str(errorCode,'%X')]);   
end

%set active ram segment
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetActiveRamSegment', out_ptr,4);
if(errorCode)
 disp(['PCO_SetActiveRamSegment failed with error ',num2str(errorCode,'%X')]);   
end

%set memory size of 4. segment to allow recording of 2 images
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
if(rem((uint32(act_xsize)*uint32(act_ysize)),uint32(wPageSize))>0)
 dwImageMemsize=dwImageMemsize+1;
end

dwSegmentSize=dwImageMemsize*2;

if(dwRamSize<dwSegmentSize)
 disp('Not enough memory to allocate 2 images in segment 4');   
end

if(dwSegment(4)<dwSegmentSize)
 dwSegment(4)=dwSegmentSize;
end

if((dwSegment(4)+dwSegment(1))>dwRamSize)
 dwSegment(1)=dwRamSize-dwSegment(4);
end

[errorCode,out_ptr]  = calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize', out_ptr,dwSegment);
if(errorCode)
 disp(['PCO_SetCameraRamSegmentSize failed with error ',num2str(errorCode,'%X')]);   
end

arm_done=0;
%all the previous settings are not done if the camera is actually in
%recording state ON
if(act_recstate==0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
 if(errorCode)
  disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
 else 
  arm_done=1;
 
  [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 1);
  if(errorCode)
   disp('PCO_SetRecordingState failed with error ',num2str(errorCode,'%08X'));
  end
 end

 [errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',glvar.out_ptr,act_recstate);
 if(errorCode)
  disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%08X')]);   
 end
 disp(['camera_recording_state is now ',int2str(act_recstate)]);
end 

if(act_recstate==1)
 disp('get single images')
 tic;
 for n=1:2000   
  [err,ima,glvar]=pco_get_image(glvar,0,1);
  if(err)
   disp(['pco_get_image returned error ',num2str(errorCode,'%X')]);
   break;   
  end
  m=max(max(ima(:,10:end)));
  [xs,ys]=size(ima);
  xmax=600;
  ymax=400;
  if((xs>xmax)&&(ys>ymax))
   ima=ima(1:xmax,1:ymax);
  elseif(xs>xmax)
   ima=ima(1:xmax,:);
  elseif(ys>ymax)
   ima=ima(:,1:ymax);
  end        
  imshow(ima',[0,m+100]);
  pause(0.050);
  t=toc;
  disp(['loop ',int2str(n),' time: ',int2str(t),' max: ',int2str(m)]);
  if(t>waittime)
   break;
  end 
 end 
 disp('Press "Enter" to close window and proceed')
 pause();
 close();
 pause(1);
 clear ima;
end

if(arm_done==1)
%set changed values back
%set saved RecoderSubmode
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', glvar.out_ptr, 0);
 if(errorCode)
  disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%08X')]);
 end
 
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode', out_ptr,prev_rec_submode);
 if(errorCode)
  disp(['PCO_SetRecorderSubmode failed with error ',num2str(errorCode,'%X')]);   
 end

%set active ram segment
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetActiveRamSegment', out_ptr,prev_segment);
 if(errorCode)
  disp(['PCO_SetActiveRamSegment failed with error ',num2str(errorCode,'%X')]);   
 end

 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
 if(errorCode)
  disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
 end
end 
 
if((do_close==1)&&(cam_open==1))
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
 if(errorCode)
  disp(['PCO_CloseCamera ',num2str(errorCode,'%08X')]);   
 else
  disp('PCO_CloseCamera done');  
  cam_open=0;
  if((exist('glvar','var'))&& ...
    (isfield(glvar,'out_ptr')))
   glvar.out_ptr=[];
  end
 end    
end

if((unload==1)&&(cam_open==0))
 unloadlibrary('PCO_CAM_SDK');
 disp('PCO_CAM_SDK unloadlibrary done');
end 

if((exist('glvar','var'))&& ...
   (isfield(glvar,'camera_open')))
 glvar.camera_open=cam_open;
end

clear glvar;
clear ima;

end
   

