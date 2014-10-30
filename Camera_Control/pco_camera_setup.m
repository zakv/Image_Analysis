function [errorCode,glvar] = pco_camera_setup(glvar,set_default,PR,EX,TI)
%
%   [errorCode,glvar] = pco_camera_setup(glvar)
%
%	* Input parameters :
%		struct     glvar
%	* Output parameters :
%                  errorCode
%       struct     glvar
%
%does setup of camera, change any parameters as needed
%binning, roi, exposuretime, triggermode ...
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
%camera recording is stopped
%parameters are set
%camera is armed
%errorCode and if available glvar is returned
%
%remark:
%the camera will hold all parameters until power is switched off
%or new settings will be sent
%
%internal used variables to setup camera
%if one of the variables does not exist, camera default setting is used
%the following variables are just main parameters
%for other parameters see camera and SDK manual
%
%PixelRate: select one of the values in the camera descriptor
%           1: lowest Rate first value of descriptor (12MHz, readout time
%           137ms)
%           2: highest Rate second value of descriptor (25MHz, readout time
%           74ms)
%         3,4: not available at the moment   
PixelRate=PR; 

%TimeStamp:
%           0: no timestamp
%           1: only binary timestamp
%           2: binary and ASCII Timestamp
%           3: only ASCII Timestamp
TimeStamp=2;

%NumADC: select number of ADC used in CCD-Readout
%           1: one ADC is used
%           2: two ADC's are used, if availalbe
NumADC=1;

%ROI: select region of interest, the given values are for binning 1x1 
%     if binning is set to other values, new ROI values are calculated
%     if DualADC is selected, the horizontal ROI must be symetric
%     stepping of roi values depends on camera model, see descriptor
%     roi_x1, roi_x2 range is from 1 to maximal horizontal resolution of camera
%     roi_y1, roi_y2 range is from 1 to maximal vertical resolution of camera
%     the following values set a ROI of 1024 pixel x 512 lines in the center of a pco.2000 camera
%     see also ROI calculation before ROI setting
%roi_x1=uint16(512+1);
%roi_x2=uint16(1536);
%roi_y1=uint16(768+1);
%roi_y2=uint16(1280);

%for pixelfly usb: "The ROI (region of interest) selects only a part of the sensor 
%to be read out,in order to speed up the frame rate and to save memory (not available for
%the pco.pixelfly usb)." !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%roi_x1=uint16(50);
%roi_x2=uint16(1342);
%roi_y1=uint16(50);
%roi_y2=uint16(980);

%Binning: select horizontal and/or vertical binning on the pixels
%         stepping of binning values depends on camera model, see descriptor
%         the following values set no binning 
bin_x=uint16(1);
bin_y=uint16(1);

%Trigger: select trigger mode of camera
%            0: TRIGGER_MODE_AUTOTRIGGER    
%            1: TRIGGER_MODE_SOFTWARETRIGGER
%            2: TRIGGER_MODE_EXTERNALTRIGGER
%            3: TRIGGER_MODE_EXTERNALEXPOSURECONTROL:
trigger=uint16(1);

%Timebase and times: set time and timebase for delay and exposure times
%Timebase:
%            0: TIMEBASE ns
%            1: TIMEBASE �s
%            2: TIMEBASE ms
%Delay and Exposure time: range of values depends on camera model, see descriptor 
%                         the following values set no Delay and 10ms exposure time
del_timebase=uint32(1);
del_time=uint32(0);
exp_timebase=uint32(TI);
exp_time=uint32(EX);

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % Check if we want 32bit or 64bit libraries
    arch=computer('arch');
    if strcmp(arch(end-1:end),'64')
        dir_name='64bit';
    else
        dir_name='32bit';
    end
    %Get path to include
    includepath=fullfile(mfilename('fullpath'),dir_name);
	loadlibrary('SC2_Cam','SC2_CamExport.h','alias','PCO_CAM_SDK','includepath',includepath);
	disp('PCO_CAM_SDK library is loaded!');
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

if(~exist('set_default','var'))
 set_default=1;   
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

%if set_default is set, reset camera to default values
if(set_default==1)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ResetSettingsToDefault', out_ptr);
 if(errorCode)
  disp(['PCO_ResetSettingsToDefault failed with error ',num2str(errorCode,'%X')]);   
 end
end

%get Camera Description
ml_cam_desc.wSize=uint16(436);
cam_desc=libstruct('PCO_Description',ml_cam_desc);

[errorCode,out_ptr,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
if(errorCode)
 disp(['PCO_GetCameraDescription failed with error ',num2str(errorCode,'%X')]);   
end

%set PixelRate for Sensor
if(exist('PixelRate','var'))
 if(cam_desc.dwPixelRateDESC(PixelRate))
  [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetPixelRate', out_ptr,cam_desc.dwPixelRateDESC(PixelRate));
  if(errorCode)
   disp(['PCO_SetPixelRate failed with error ',num2str(errorCode,'%X')]);   
  end
 end
end

%set Timestamp 
if(exist('TimeStamp','var'))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTimestampMode', out_ptr,TimeStamp);
 if(errorCode)
   disp(['PCO_SetTimesatmpMode failed with error ',num2str(errorCode,'%X')]);   
 end
end

%calculation of Roi with horizontal and vertical size as input
%calculation can be used
horizontal_Size=uint16(800);
vertical_Size=uint16(600);
center_roi_x1=(uint16(cam_desc.wMaxHorzResStdDESC)-horizontal_Size)/2;
center_roi_x2=uint16(cam_desc.wMaxHorzResStdDESC)-center_roi_x1;
center_roi_x1=center_roi_x1+1;
center_roi_y1=(uint16(cam_desc.wMaxVertResStdDESC)-vertical_Size)/2;
center_roi_y2=uint16(cam_desc.wMaxVertResStdDESC)-center_roi_y1;
center_roi_y1=center_roi_y1+1;

%set ROI 
if((~exist('roi_x1','var'))||(~exist('roi_x2','var'))||(~exist('roi_y1','var'))||(~exist('roi_y2','var')))
 roi_x1=uint16(center_roi_x1);
 roi_x2=uint16(center_roi_x2);
 roi_y1=uint16(center_roi_y1);
 roi_y2=uint16(center_roi_y2);
end   

%[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetROI', out_ptr,roi_x1,roi_y1,roi_x2,roi_y2);
%if(errorCode)
% disp(['PCO_SetROI failed with error ',num2str(errorCode,'%X')]);   
%end

[errorCode,out_ptr,roi_x1,roi_y1,roi_x2,roi_y2] = calllib('PCO_CAM_SDK', 'PCO_GetROI', out_ptr,roi_x1,roi_y1,roi_x2,roi_y2);
if(errorCode)
 disp(['PCO_GetROI failed with error ',num2str(errorCode,'%X')]);   
end

disp(['PCO_ROI ',int2str(roi_x1),' ',int2str(roi_x2),' ',int2str(roi_y1),' ',int2str(roi_y2),' ',]);   

%set DualADC if possible
%horizontal ROI must be symetric for DualADC mode
if(exist('NumADC','var'))
 if((cam_desc.wNumADCsDESC>0)&&(NumADC>1))
  [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetADCOperation', out_ptr,cam_desc.wNumADCsDESC);
  if(errorCode)
   disp(['PCO_SetADCOperation failed with error ',num2str(errorCode,'%X')]);   
  end
  a=roi_x2-(roi_x1-1);
  if(a+(2*(roi_x1-1))~=cam_desc.wMaxHorzResStdDESC)
   disp('Wrong ROI settings');   
  end
 end
end

%set binning 
if((exist('bin_x','var'))&&(exist('bin_y','var')))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetBinning', out_ptr,bin_x,bin_y);
 if(errorCode)
  disp(['PCO_SetBinning failed with error ',num2str(errorCode,'%X')]);   
 end
end

[errorCode,out_ptr,bin_x,bin_y] = calllib('PCO_CAM_SDK', 'PCO_GetBinning', out_ptr,bin_x,bin_y);
if(errorCode)
 disp(['PCO_GetBinning failed with error ',num2str(errorCode,'%X')]);   
end

%must adapt ROI to binning
if((bin_x>1)||(bin_y>1))
 if(roi_x1>1)   
  roi_x1=((roi_x1-1)/bin_x)+1;
 end
 if(roi_y1>1)
  roi_y1=((roi_y1-1)/bin_y)+1;
 end
 roi_x2=roi_x2/bin_x;
 roi_y2=roi_y2/bin_y;

% [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetROI', out_ptr,roi_x1,roi_y1,roi_x2,roi_y2);
% if(errorCode)
%  disp(['PCO_SetROI failed with error ',num2str(errorCode,'%X')]);   
% end
end

%set trigger
if(exist('trigger','var'))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', out_ptr,trigger);
 if(errorCode)
  disp(['PCO_SetTriggerMode failed with error ',num2str(errorCode,'%X')]);   
 end
end


%set delay and exposure time  
if((exist('del_timebase','var'))&&(exist('del_time','var'))&&(exist('exp_timebase','var'))&&(exist('exp_time','var')))
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetDelayExposureTime', out_ptr,del_time,exp_time,del_timebase,exp_timebase);
 if(errorCode)
  disp(['PCO_PCO_SetDelayExposureTime failed with error ',num2str(errorCode,'%X')]);   
 end
end

clear cam_desc;    

[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode)
 disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);   
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

end




