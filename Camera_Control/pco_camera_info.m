function [errorCode,glvar] = pco_camera_info(glvar)
%
%   [errorCode,glvar] = pco_camera_setup(glvar)
%
%	* Input parameters :
%		struct     glvar
%	* Output parameters :
%                  errorCode
%       struct     glvar
%
%does retrive some information of the connected camera
%especially ty of interface
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
%camera information is readout
%errorCode and if available glvar is returned
%

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

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0); 
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
if(errorCode)
 disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%X')]);   
end

ml_cam_type.wSize=uint16(1364);
cam_type=libstruct('PCO_CameraType',ml_cam_type);
[errorCode,out_ptr,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
if(errorCode)
 disp(['PCO_GetCameraType failed with error ',num2str(errorCode,'%08X')]);   
end
interface=uint16(cam_type.wInterfaceType);

disp(['interface is: ',int2str(interface)]);
disp(['record state is: ',int2str(act_recstate)]);

disp(' ');
disp('Camera Hardware versions:');
z=1;
for n=1:10
 a=strfind(cam_type.strHardwareVersion(z:z+15),0);
 a=a(1);
 if(a+((n-1)*62)>z)
  b=char(cam_type.strHardwareVersion(z:z+a-1));
  batch=uint16(cam_type.strHardwareVersion(z+17:z+17))*256;
  batch=batch+uint16(cam_type.strHardwareVersion(z+16:z+16));
  rev=uint16(cam_type.strHardwareVersion(z+19:z+19))*256;
  rev=rev+uint16(cam_type.strHardwareVersion(z+18:z+18));
  var=uint16(cam_type.strHardwareVersion(z+21:z+21))*256;
  var=var+uint16(cam_type.strHardwareVersion(z+20:z+20));
  disp([b,blanks(16-a),':',int2str(batch),'.',int2str(rev),'.',int2str(var)]);
 end 
 z=z+62; 
end
disp(' ');
disp('Camera Firmware versions:');
z=7;
for n=1:10
 a=strfind(cam_type.strFirmwareVersion(z:z+15),0);
 a=a(1);
 if(a+((n-1)*64)>z)
  b=char(cam_type.strFirmwareVersion(z:z+a-1));
  minor=uint8(cam_type.strFirmwareVersion(z+16:z+16));
  major=uint8(cam_type.strFirmwareVersion(z+17:z+17));
  variant=uint16(cam_type.strFirmwareVersion(z+19:z+19))*256;
  variant=variant+uint16(cam_type.strFirmwareVersion(z+18:z+18));
  disp([b,blanks(16-a),':',int2str(variant),'  ',int2str(major),'.',int2str(minor)]);
 end 
 z=z+64; 
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