function Main_PCO_Pixelfly_USB_flu(run_config,image_instance_data)
%This function takes a lot of arguments, so it's easier to pass them as one
%big object.  Below are the meanings of some of that object's attributes.
%image_instance_data should be a structure whose attributes will be
%transferred to the saved Image instances.
%Here PR means pixel rate.
%DI means double image mode and 1 is on and 0 is off.
%TR means trigger and 0 auto 1 software 2 external.
%EX means exposure time.
%TI means the time base for the exposure time. 0 ns 1 us 2 ms.
%IR means IR sensitivity. 1 is on and 0 is off.
%BL means loading the background data for processing.
%SF means Sensor Format. 1 is 800*600 and 0 is 1392*1040.

%This code is modified by Jiazhong Hu on 7-31-2012 for the flourescence
%image.
%   pco_rec2file_swtrig(imacount)
%
%	* Input parameters :
%                  imacount
%	* Output parameters :
%
%records and saves to disk 'imacount' images
%the actual setup of the camera is used, with the fiollowing modifications
%storage mode is set to STORAGE_MODE_FIFO
%recorder submode is set to RECORDER_SUBMODE_RINGBUFFER
%trigger mode is set to SOFTWARE_TRIGGER/ EXTERNAL_TRIGGER
%
%function workflow
%parameters are checked
%camera parameters are set
%camera is armed
%camera is started
%memory for one image is allocated
%
%the function does the following loop until imacount  images are done
%
%control external components
%send force trigger, one image is done
%wait until image is in camera memory
%get image from camera
%save image to disk
%
%free allocated memory
%stop camera

%The background removal needs to know which part of the image has
%atoms so that region can be ignored.  Specify that region in the
%line below
% %Region that may have atoms
row_min=10; row_max=120; col_min=50; col_max=280; % usual values
% row_min=35; row_max=75; col_min=125; col_max=230; % TEMPORARY for Pump/Flip/Pump... scan 1.5ms TOF
% row_min=35; row_max=65; col_min=170; col_max=200; % TEMPORARY for in situ (feel free to delete)
% row_min=40; row_max=100; col_min=150; col_max=220; % TEMPORARY for 5ms TOF (feel free to delete)
% row_min=70; row_max=120; col_min=150; col_max=225; % TEMPORARY for 7ms TOF (feel free to delete)
% row_min=90; row_max=155; col_min=150; col_max=220; % TEMPORARY for 9ms TOF (feel free to delete)
% row_min=60; row_max=190; col_min=125; col_max=250; % for 9ms TOF
% row_min=10; row_max=200; col_min=75; col_max=275; % for in situ to 9ms TOF Scan
% row_min=10; row_max=250; col_min=75; col_max=275; % TEMPORARY for ODToAtomNumber calibration
% row_min=10; row_max=250; col_min=75; col_max=275; % TEMPORARY for ODToAtomNumber calibration Round 2
% row_min=10; row_max=50; col_min=10; col_max=70; % TEMPORARY for PSF (feel free to delete)
% row_min=50; row_max=500; col_min=100; col_max=250; % for long TOF adiabatic release
% row_min=30; row_max=250; col_min=30; col_max=120; % for long TOF of cold clouds
% row_min=10; row_max=601; col_min=75; col_max=250; % for Stern Gerlach in YS
% row_min=20; row_max=100; col_min=1; col_max=1001; % for Stern Gerlach in YS
% row_min=20; row_max=250; col_min=125; col_max=250; % for Stern Gerlach
% row_min=20; row_max=471; col_min=75; col_max=225; % for long TOF Stern Gerlach
% row_min=1; row_max=21; col_min=75; col_max=225; % for fine precision aligning X to Y
% row_min=10; row_max=40; col_min=1; col_max=81; % for looking at oscillations in crossed ODT
% row_min=110; row_max=160; col_min=1; col_max=301; % for Raman Kick Sequence with 9ms TOF
% row_min=1; row_max=501; col_min=1; col_max=501; % for Imaging the cMOT
% row_min=10; row_max=40; col_min=1; col_max=1392; % for Imaging full length to Y beams
% row_min=10; row_max=200; col_min=50; col_max=250; % for 301x301 pixel square
% row_min=150; row_max=300; col_min=125; col_max=250; % for 18ms TOF
row_min=25; row_max=75; col_min=25; col_max=75; % for 11ms TOF (For BEC many-shot average)
% row_min=15; row_max=136; col_min=15; col_max=136; % for X2 many shot average %row_min=15; row_max=86; col_min=15; col_max=86;

%Set region of interest for analysis [row_min,row_max;col_min,col_max]
%(Note semicolon between row and columns indices)
analysis_ROI=[470,640;546,846]; % usual values
% analysis_ROI=[490,550;696,776]; % TEMPORARY for PSF (feel free to delete)
% analysis_ROI=[470,770;546,846]; % for 9ms TOF
% analysis_ROI=[470,770;546,846]; % for in situ to 9ms TOF Scan
% analysis_ROI=[370,770;546,846]; % TEMPORARY for ODToAtomNumber calibration
% analysis_ROI=[370,720;546,846]; % TEMPORARY for ODToAtomNumber calibration Round 2
% analysis_ROI=[440,1040;546,846]; % for long TOF adiabatic release
% analysis_ROI=[470,770;646,796]; % for long TOF of cold clouds
% analysis_ROI=[470,590;200,1200]; % for Stern Gerlach in YS
% analysis_ROI=[470,770;5469846]; % for Stern Gerlach
% analysis_ROI=[470,940;546,846]; % for long TOF Stern Gerlach
% analysis_ROI=[510,530;546,846]; % for fine precision aligning X to Y
% analysis_ROI=[500,550;666,746]; % for looking at oscillations in crossed ODT
% analysis_ROI=[470,640;546,846]; % for Raman Kick Sequence with 9ms TOF
% analysis_ROI=[250,750;500,1000]; % for Imaging the cMOT
% analysis_ROI=[500,560;1,1392]; % for Imaging full length to Y beams
% analysis_ROI=[470,770;585,885]; % for 301x301 pixel square
% analysis_ROI=[570,970;546,846]; % for 18ms TOF
analysis_ROI=[568,667;665,764]; % for 11ms TOF (For BEC many-shot average)
% analysis_ROI=[463,612;638,787]; % for X2 many shot average %[488,587;663,762]

%Set range for colobar scale of atom OD plot
OD_colorbar_range=[-0.1,0.5]*1.2;
% OD_colorbar_range=[-0.1,0.5]*0.5;
% OD_colorbar_range=[-0.1,2.];
% OD_colorbar_range=[-0.1,0.4];

% Define constants for the evaluation of the on-the-fly fit
% Values taken from the M20180807.nb notebook
tempT = 0.327953;
ODToAtomNumber = 277.275;

% Define other constants
%Arduino COM port. To check this, open the Arduino IDE, Click Tools->Port
%and see what port has an Arduino
arduino_com_port='COM4';
arduino_trigger_pin=13; %Pin number for pin controlling trigger output
allow_trigger=0; %Define pin output that allows sequence to be triggered
hold_trigger=1; %Define pin output that stops sequence from getting triggered


%unpack data from argument object
savingname=run_config.namefile;
saving_path=run_config.saving_path;
imacount=run_config.imacount;
PR=run_config.pixel_rate;
DI=run_config.double_image;
TR=run_config.trigger;
EX=run_config.exposure_time;
TI=run_config.timebase;
IR=run_config.IR;
BL=run_config.backloader;
SF=run_config.sensor_format;
HB=run_config.h_binning;
VB=run_config.v_binning;
average=run_config.average;
twoimage=run_config.twoimage;
SNumber=run_config.starting_index;

%Prepare Arduino
%Make trigger_arduino a global variable so we can access it from other
%functions. This is definitely not the smartest way to do this, but this
%program should be rebuilt from scratch anyway.
%To access this global variable in other functions or from the command
%line, run "global trigger_arduino".
global trigger_arduino;
%Connect to the arduino if the connection does not already exist.
if isempty(trigger_arduino)
    trigger_arduino=arduino(arduino_com_port); %Conect to it
    pinMode(trigger_arduino,arduino_trigger_pin,'output'); %Make pin an output
end
%Stop sequence until camera is ready
digitalWrite(trigger_arduino,arduino_trigger_pin,hold_trigger);
%Note that sequence may already be running, so this stop might be ignored.


NumberOfAtomTotal=zeros(1,imacount);
if (DI==0)&&(BL==1)
    %Background_Image=load('AveragedImage-image0050-2012-07-23-13-19-58.ascii');
    Background_Image=load('background_image.ascii');
end

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);
%Image_time=struct('FrameTime_ns',10000,'FrameTims_s',0,'ExposureTime_ns',0,'ExposureTime_s',0,'TriggerSystemDelay_ns',0,'TriggerSystemDelay_s',0,'TriggerSystemJitter_ns',0,'TriggerSystemJitter_s',0,'TriggerDelay_ns',0,'TriggerDelay_s',0);

if(~exist('imacount','var'))
    imacount = 1;
end

[err,glvar]=pco_camera_setup(glvar,0,PR,EX,TI);
if(err~=0)
    disp(['pco_camera_setup failed with error ',num2str(err,'%X')]);
    return;
end

disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);

out_ptr=glvar.out_ptr;

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0);
[errorCode,out_ptr,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState', out_ptr,act_recstate);
if(errorCode)
    disp(['PCO_GetRecordingState failed with error ',num2str(errorCode,'%X')]);
end

%Vendeiro 64bit version had trouble here
if(act_recstate~=0)
    [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, int32(0));
    if(errorCode)
        disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%X')]);
    end
end

%set STORAGE_MODE_FIFO
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetStorageMode', out_ptr,1);
if(errorCode)
    disp(['PCO_SetStorageMode failed with error ',num2str(errorCode,'%X')]);
end

%set RECORDER_SUBMODE_RINGBUFFER
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode', out_ptr,1);
if(errorCode)
    dsip(['PCO_SetRecorderSubmode failed with error ',num2str(errorCode,'%X')]);
end

%set TRIGGER_MODE_ExternalTRIGGER
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', out_ptr,TR);
if(errorCode)
    disp(['PCO_SetTriggerMode failed with error ',num2str(errorCode,'%X')]);
end

%set TRIGGER_MODE_SOFTWARETRIGGER
%[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetTriggerMode', out_ptr,1);
%if(errorCode)
% disp(['PCO_SetTriggerMode failed with error ',num2str(errorCode,'%X')]);
%end

%Set IR SENSITIVITY ON = 1, OFF= 0
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetIRSensitivity', out_ptr,IR);
if(errorCode)
    disp(['PCO_SetIRSensitivity failed with error ',num2str(errorCode,'%X')]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0=standard (uses effective pixels); 1=extended (shows all pixels, sensor format 800 x 600)
[errorCode,out_ptr]=calllib('PCO_CAM_SDK', 'PCO_SetSensorFormat',out_ptr,SF);
if(errorCode)
    disp(['SetSensorFormat failed with error',num2str(errorCode,'%X')]);
end


[errorCode,out_ptr]=calllib('PCO_CAM_SDK', 'PCO_SetBinning',out_ptr,HB,VB);
if(errorCode)
    disp(['SetBinning failed with error',num2str(errorCode,'%X')]);
end

%ROI cannot be set for pixelfly usb!!!!
%[errorCode,out_ptr]=calllib('PCO_CAM_SDK', 'PCO_SetROI',out_ptr,50,1342,50,980);
%if(errorCode)
%    disp(['SetROI failed with error', num2str(errorCode,'%X')]);
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set DOUBLE IMAGE MODE ON = 1, OFF= 0
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetDoubleImageMode', out_ptr,DI);
if(errorCode)
    disp(['PCO_SetDoubleImageMode failed with error ',num2str(errorCode,'%X')]);
end

%[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetAcquireMode', out_ptr, 0);
%if(errorCode)
% disp(['PCO_SetAcquireMode failed with error ',num2str(errorCode,'%X')]);
%end

[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode)
    disp(['PCO_ArmCamera failed with error ',num2str(errorCode,'%X')]);
end

%Vendeiro 64bit version had trouble here
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 1);
if(errorCode)
    disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%X')]);
end



%declare some variables and get some information from camera
dwValidImageCnt=uint32(0); %#ok<NASGU>
dwMaxImageCnt=uint32(0);
wtrigdone=uint16(0); %#ok<NASGU>
dwSec=uint32(0);
dwNanoSec=uint32(0);

ml_cam_desc.wSize=uint16(436);
cam_desc=libstruct('PCO_Description',ml_cam_desc);
[errorCode,out_ptr,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
if(errorCode)
    disp(['PCO_GetCameraDescription failed with error ',num2str(errorCode,'%08X')]);
end
bitpix=uint16(cam_desc.wDynResDESC);

ml_cam_type.wSize=uint16(1364);
cam_type=libstruct('PCO_CameraType',ml_cam_type);
[errorCode,out_ptr,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
if(errorCode)
    disp(['PCO_GetCameraType failed with error ',num2str(errorCode,'%08X')]);
end
interface=uint16(cam_type.wInterfaceType);



%get time in ms, which is used for one image
[errorCode,out_ptr,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
if(errorCode)
    disp(['PCO_GetCOCRuntime failed with error ',num2str(errorCode,'%X')]);
end

waittime_s = double(dwNanoSec);
waittime_s = waittime_s / 1000000000;
waittime_s = waittime_s + double(dwSec);

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

%get the memory for the image
%need special code for firewire interface

imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(strSegment.wYRes)* uint32(strSegment.wXRes);
imasize=imas;

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
    disp([int2str(lineadd),' additional lines have been allocated ']);
else
    lineadd=0;
end

image_stack=ones(strSegment.wXRes,strSegment.wYRes+lineadd,'uint32');

sBufNr=int16(-1);
im_ptr = libpointer('uint16Ptr',image_stack);
ev_ptr = libpointer('voidPtr');

%Vendeiro 64bit version had trouble here
[errorCode,out_ptr,sBufNr,image_stack,ev_ptr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
if(errorCode)
    disp(['PCO_AllocateBuffer failed with error ',num2str(errorCode,'%08X')]);
    return;
end


if (VB==1)&&(HB==1)&&(SF==1)
    total_image=zeros(600,800);
end

if (VB==1)&&(HB==1)&&(SF==0)
    total_image=zeros(1392,1040);
end

if (VB==2)&&(HB==2)&&(SF==0)
    total_image=zeros(696,520);
end

%here is the loop
n=1;
while n<=imacount
    timed_out=false;
    %Set arduino to allow sequence to trigger
    digitalWrite(trigger_arduino,arduino_trigger_pin,allow_trigger);
    
    %First image for this shot
    dwValidImageCnt=0;
    errorCode=0;
    a=0;
    while((dwValidImageCnt<1)&&(errorCode==0))
        [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,act_segment,dwValidImageCnt,dwMaxImageCnt);
        if(errorCode)
            disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);
        end
        % disp(['segment ',int2str(act_segment),':  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);
        pause(waittime_s);
        a=a+1;
        if(a>500)
            disp('timeout in waiting for images');
            errorCode=1;
            timed_out=true;
        end
    end
    
    if(errorCode==0)
        [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,act_segment,0,0,sBufNr,strSegment.wXRes,strSegment.wYRes,bitpix);
        if(errorCode)
            disp(['PCO_GetImageEx failed with error ',num2str(errorCode,'%08X')]);
        else
            disp(['PCO_GetImageEx image ' int2str(n) ' done']);
        end
    end
    
    if(errorCode==0)
        [errorCode,out_ptr,image_stack]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
        if(errorCode)
            disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);
        end
    end
    
    
    result_image1=image_stack;
    
    
    
    %sums all background images
    if (average==1)
        total_image=double(total_image) + double(result_image1');
    end
    
    %substracts Background from single pictures
    if (DI==0)&&(BL==1)
        Processed_Data=double(result_image1')-double(Background_Image);
        figure(4)
        subplot(1,2,1);imshow(Processed_Data,[-20,150]);colorbar()
        title('Processed data')
        dlmwrite(fullfile('.',save_file9), Processed_Data,'delimiter', '\t');
        
        %define ROI for calculating atom number
        ROI_Processed_Data=Processed_Data(141:308,217:440);
        subplot(1,2,2);imshow(ROI_Processed_Data,[-20,150]);colorbar()
        title('Processed data in ROI')
        
        %number_of_atoms=total_number_of_counts/(Gamma/2*exposure_time*solid_an
        %gel*Quantum_efficiency)
        if (TI==0)
            timebase=10^(-9);
        end
        if(TI==1)
            timebase=10^(-6);
        end
        if(TI==2)
            timebase=10^(-3);
        end
        
        exptime=EX*timebase;
        number_of_atoms=4*pi*sum(sum(ROI_Processed_Data))/(pi*6.066618*10^6*exptime*0.1000202602*0.3);
        dlmwrite(fullfile('.',save_file10), number_of_atoms,'delimiter', '\t');
        NumberOfAtomTotal(1,n)=number_of_atoms;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%For another new picture in the same for sequence.%%%%%%%%
    if (twoimage==1)
        %Second image for this shot
        if timed_out==false
            dwValidImageCnt=0;
            errorCode=0;
            a=0;
            while((dwValidImageCnt<1)&&(errorCode==0)&&(timed_out==false))
                [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,act_segment,dwValidImageCnt,dwMaxImageCnt);
                if(errorCode)
                    disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);
                end
                % disp(['segment ',int2str(act_segment),':  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);
                pause(waittime_s);
                a=a+1;
                if(a>500)
                    disp('timeout in waiting for images');
                    errorCode=1;
                    timed_out=true;
                end
            end
            
            if(errorCode==0)
                [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,act_segment,0,0,sBufNr,strSegment.wXRes,strSegment.wYRes,bitpix);
                if(errorCode)
                    disp(['PCO_GetImageEx failed with error ',num2str(errorCode,'%08X')]);
                else
                    disp(['PCO_GetImageEx image ' int2str(n) ' done']);
                end
            end
            
            if(errorCode==0)
                [errorCode,out_ptr,image_stack]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
                if(errorCode)
                    disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);
                end
            end
            
            
            result_image2=image_stack;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Third image for this shot
        if timed_out==false
            dwValidImageCnt=0;
            a=0;
            while((dwValidImageCnt<1)&&(errorCode==0))
                [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,act_segment,dwValidImageCnt,dwMaxImageCnt);
                if(errorCode)
                    disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);
                end
                % disp(['segment ',int2str(act_segment),':  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);
                pause(waittime_s);
                a=a+1;
                if(a>500)
                    disp('timeout in waiting for images');
                    errorCode=1;
                    timed_out=true;
                end
            end
            
            %Got the last image, stop sequence until camera is ready again
            digitalWrite(trigger_arduino, arduino_trigger_pin, hold_trigger);
            
            if(errorCode==0)
                [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,act_segment,0,0,sBufNr,strSegment.wXRes,strSegment.wYRes,bitpix);
                if(errorCode)
                    disp(['PCO_GetImageEx failed with error ',num2str(errorCode,'%08X')]);
                else
                    disp(['PCO_GetImageEx image ' int2str(n) ' done']);
                end
            end
            
            if(errorCode==0)
                [errorCode,out_ptr,image_stack]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
                if(errorCode)
                    disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);
                end
            end
            
            
            result_image3=image_stack;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if timed_out==false
            part1=result_image1';
            part2=result_image2';
            part3=result_image3';
            rmin=analysis_ROI(1,1);rmax=analysis_ROI(1,2);
            cmin=analysis_ROI(2,1);cmax=analysis_ROI(2,2);
            part1=part1(rmin:rmax,cmin:cmax);
            part2=part2(rmin:rmax,cmin:cmax);
            part3=part3(rmin:rmax,cmin:cmax);
            
            %Subtract noise image on the fly
            part1=part1-part3;
            part2=part2-part3;
            
            %Generate file names for saving
            prefix=[savingname,'_',num2str(SNumber+n-1)];
            prefix=fullfile(saving_path,prefix);
            raw_image_filename=[prefix,'_raw.png'];
            back_image_filename=[prefix,'_back.png'];
            noise_image_filename=[prefix,'_noise.png'];
            metadata_filename=[prefix,'_metadata.tsv'];
            
            %Save the data
            imwrite(part1,raw_image_filename);
            imwrite(part2,back_image_filename);
            %imwrite(part3,noise_image_filename);
            struct_to_tsv(image_instance_data,metadata_filename);
            
            %Vendeiro New background removal stuff as of July 5th 2017
            %Clear image data cache in case we use the same file name twice
            try
                load_image('',true); %Throws and error since '' is not a real file name
            catch
            end
            temppart=quick_back_removal_eig(saving_path,double(part1),row_min,row_max,col_min,col_max,double(part2));
            %Vendeiro End of new background removal stuff
            
            %Urvoy slightly less hacky way of making cross sections only
            %integrate atom region (integrating over the atom region but 
            %showing the full curve)
            back_region = make_back_region(temppart,row_min,row_max,col_min,col_max);
            image_zeroed_background = temppart(not(logical(back_region(:)))); 
            image_zeroed_background = reshape(image_zeroed_background,row_max-row_min+1,[]);
            hProfile = sum(image_zeroed_background,1); hProfile = reshape(hProfile,1,[]);
            vProfile = sum(image_zeroed_background,2); vProfile = reshape(vProfile,1,[]);

            %Urvoy slightly less hacky way of making cross sections only
            %integrate atom region (integrating over the atom region but 
            %showing the full curve)
%             back_region = make_back_region(temppart,row_min,row_max,col_min,col_max);
%             hProfile = sum(temppart(row_min:row_max,:),1); hProfile = reshape(hProfile,1,[]);
%             vProfile = sum(temppart(:,col_min:col_max),2); vProfile = reshape(vProfile,1,[]);
            
            %Vendeiro hacky way of making cross sections only integrate
            %atom region
%             back_region = make_back_region(temppart,row_min,row_max,col_min,col_max);
%             image_zeroed_background = (1-back_region).*temppart;
%             hProfile = sum(image_zeroed_background,1); hProfile = reshape(hProfile,1,[]);
%             vProfile = sum(image_zeroed_background,2); vProfile = reshape(vProfile,1,[]);
            
            % Urvoy Beginning of on-the-fly fitting
%             hProfile = sum(temppart,1); hProfile = reshape(hProfile,1,[]);
%             vProfile = sum(temppart,2); vProfile = reshape(vProfile,1,[]);
            
            % Preparation of the fits
            gaussian = @(x,xdata)x(3)*exp(-(xdata-x(1)).^2./(2*(x(2)).^2))+x(4);
            options = optimoptions('lsqcurvefit','Display','off');
            
            % Moving average smoothing of the profile for the 1st fit
            windowSize = 5;
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            
            hProfileSmooth = filtfilt(b,a,hProfile);
            vProfileSmooth = filtfilt(b,a,vProfile);
            
            % Determination of the initial guesses for the gaussian fit on the top half of the curve
            [hmax,himax] = max(hProfileSmooth); [vmax,vimax] = max(vProfileSmooth); % maximum and center of the gaussian
            hoff = mean(hProfileSmooth([1 end])); voff = mean(vProfileSmooth([1 end])); % offset for the fit
            hmax = hmax-hoff; vmax = vmax-voff;
            % indices for the top half of the horizontal cross section defined as the first point that drops below half the peak on each side
            hi1 = find(hProfileSmooth(1:himax)-hoff<hmax/2,1,'last'); hi2 = (himax-1) + find(hProfileSmooth(himax:end)-hoff<hmax/2,1,'first');
            if isempty(hi1)
                hi1=1;
            end
            if isempty(hi2)
                hi2=numel(hProfileSmooth);
            end
            % indices for the top half of the vertical cross section defined as the first point that drops below half the peak on each side
            vi1 = find(vProfileSmooth(1:vimax)-voff<vmax/2,1,'last'); vi2 = (vimax-1) + find(vProfileSmooth(vimax:end)-voff<vmax/2,1,'first');
            if isempty(vi1)
                vi1=1;
            end
            if isempty(vi2)
                vi2=numel(vProfileSmooth);
            end
            
            % Defining upper and lower bounds, and initial guesses for the 1st fit
            hub = [ hi2 , numel(hProfileSmooth)/2 , 2*hmax , hoff+1 ]; % upper bounds
            hlb = [ hi1 , 0 , 0 , hoff ]; % lower bounds
            h0 = [ himax , abs(hi2-hi1)/2 , hmax-hoff , hoff ]; % initial guesses
            vub = [ vi2 , numel(vProfileSmooth)/2 , 2*vmax , voff+1 ]; % upper bounds
            vlb = [ vi1 , 0 , 0 , voff ];  % lower bounds
            v0 = [ vimax , abs(vi2-vi1)/2 , vmax-voff , voff ]; % initial guesses
            
            % Perform the 1st fit
            try
                hfit = lsqcurvefit(gaussian,h0,hi1:hi2,hProfileSmooth(hi1:hi2),hlb,hub,options);
            catch
                warning('Problem during the 1st horizontal fit. Assigning the initial guesses.');
                hfit = h0;
            end
            try
                vfit = lsqcurvefit(gaussian,v0,vi1:vi2,vProfileSmooth(vi1:vi2),vlb,vub,options);
            catch
                warning('Problem during the 1st vertical fit. Assigning the initial guesses.');
                vfit = v0;
            end
            
            % Defining upper and lower bounds, and initial guesses for the 2nd fit
            hub = [ numel(hProfile) , numel(hProfile) , 2*hmax , max(hProfile) ]; % upper bounds
            hlb = [ 1 , 0 , 0 , min(hProfile) ]; % lower bounds
            h0 = hfit; % initial guesses
            vub = [ numel(vProfile) , numel(vProfile) , 2*vmax , max(vProfile) ]; % upper bounds
            vlb = [ 1 , 0 , 0 , min(vProfile) ];  % lower bounds
            v0 = vfit; % initial guesses
            
            % Perform the 2nd fit
            try
                hfit = lsqcurvefit(gaussian,h0,1:numel(hProfile),hProfile,hlb,hub,options);
            catch
                warning('Problem during the 2nd horizontal fit. Assigning the initial guesses.');
                hfit = h0;
            end
            try
                vfit = lsqcurvefit(gaussian,v0,1:numel(vProfile),vProfile,vlb,vub,options);
            catch
                warning('Problem during the 2nd vertical fit. Assigning the initial guesses.');
                vfit = v0;
            end
            
            % Defining the text strings with the fit results
            TOF = getfield(image_instance_data, 'TOF');
            if isempty(TOF) || ischar(TOF)
                %isnan(str2double(TOF)) is necessary for when TOF is
                %ramped, e.g. '1To10Steps10'
                TOF = 1.5;
                warning(sprintf('No TOF given in metadata, set by default to %f ms',TOF));
            end
            txtFitResults = { sprintf('TOF = %0.1f ms',TOF) ,
                sprintf('w_H = %0.1f pix',hfit(2)) ,
                sprintf('w_V = %0.1f pix',vfit(2)) ,
                sprintf('T_H = %0.2f uK',hfit(2)^2/TOF^2*tempT) ,
                sprintf('T_V = %0.2f uK',vfit(2)^2/TOF^2*tempT)
                };
            % Urvoy End of on-the-fly fitting
            
            %figure(2)
            %imagesc(doub2le(result_image2')-double(result_image3'),[0,1100]);colorbar();colormap jet;
            figure(3)
            imagesc(result_image1',[0,7500]);colorbar();colormap jet;
            figure(4)
            imagesc(result_image2',[0,7500]);colorbar();colormap jet;

            
            % Urvoy Beginning of new plotting code with direct fitting 20180910
            figure(6),clf
            back_region=make_back_region(temppart,row_min,row_max,col_min,col_max);
            atompart=temppart.*(1-back_region); %Image with all pixels in the back region set to 0
            axBox = [0.1300 0.1100 0.7750 0.75]; imageWidth = .7;
            pos1 = [ axBox(1)+(1-imageWidth)*axBox(3) axBox(2)+(1-imageWidth)*axBox(4) imageWidth*axBox(3) imageWidth*axBox(4) ];
            pos2 = [ axBox(1)+(1-imageWidth)*axBox(3) axBox(2) imageWidth*axBox(3) (1-imageWidth)*axBox(4) ];
            pos3 = [ axBox(1) axBox(2)+(1-imageWidth)*axBox(4) (1-imageWidth)*axBox(3) imageWidth*axBox(4) ];
            pos4 = [ axBox(1) axBox(2) (1-imageWidth)*axBox(3) (1-imageWidth)*axBox(4) ];
            
            axes('Position',axBox,'Visible', 'off')
            set(get(gca,'Title'),'Visible','on')
            total_OD=sum(sum(atompart));
            title_string=sprintf('Integrated OD is %0.2f',total_OD);
            title(title_string,'FontSize',30),hold on
            
            axes('Position',pos1)
            imagesc(temppart,OD_colorbar_range); hold on
            plot([ col_min col_min col_max col_max col_min ],[ row_min row_max row_max row_min row_min ],'w')
            hcb = colorbar('location','east','YAxisLocation','right');
            poscb = get(hcb,'Position');
            poscb(1) = pos1(1)+1.02*pos1(3); poscb(3) = poscb(3)/2;
            poscb(2) = pos1(2); poscb(4) = pos1(4);
            set(hcb,'Position',poscb);
            set(gca,'XTickLabel',{},'YTickLabel',{})
            
            axes('Position',pos2)
            plot(col_min:col_max,hProfile,col_min:col_max,gaussian(hfit,1:numel(hProfile)))
            xlim([1 size(temppart,2)])
            hmin = min(hProfile); hmax = max(hProfile);
            yLims = [ (hmin - 0.1*(hmax-hmin)) (hmax + 0.1*(hmax-hmin)) ];
            ylim(yLims)
            hold on
            plot(col_min*[1 1],yLims,'--k',col_max*[1 1],yLims,'--k')
            set(gca,'YTickLabel',{})
            
            axes('Position',pos3)
            plot(vProfile,row_min:row_max,gaussian(vfit,1:numel(vProfile)),row_min:row_max)
            ylim([1 size(temppart,1)])
            vmin = min(vProfile); vmax = max(vProfile);
            xLims = ([ (vmin - 0.1*(vmax-vmin)) (vmax + 0.1*(vmax-vmin)) ]);
            xlim(xLims)
            hold on
            plot(xLims,row_min*[1 1],'--k',xLims,row_max*[1 1],'--k')
            set(gca,'XTickLabel',{},'YDir','reverse')
            
            axes('Position',pos4,'Visible', 'off')
            %         mTextBox = uicontrol('style','text','Position',pos4);
            %         set(mTextBox,'String',[sprintf('%d atoms',round(ODToAtomNumber*total_OD));txtFitResults])
            text(0,1,[sprintf('%0.2e atoms',round(ODToAtomNumber*total_OD)) ; ...
                txtFitResults], ...
                'HorizontalAlignment','Left', ...
                'VerticalAlignment','Top')
            
            % Urvoy End of new plotting code with direct fitting 20180910
        end
    end
    n=n+1;
end



errorCode  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
if(errorCode)
    disp(['PCO_FreeBuffer failed with error ',num2str(errorCode,'%08X')]);
end



%close();
clear image_stack;
clear result_image;

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
if(errorCode)
    disp(['PCO_SetRecordingState failed with error ',num2str(errorCode,'%X')]);
end

%Set IR SENSITIVITY ON = 1, OFF= 0
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetIRSensitivity', out_ptr,0);
if(errorCode)
    disp(['PCO_SetIRSensitivity failed with error ',num2str(errorCode,'%X')]);
end

if(glvar.camera_open==1)
    glvar.do_close=1;
    % glvar.do_libunload=1;
    pco_camera_open_close(glvar);
end


%unloadlibrary('PCO_CAM_SDK');
%disp('PCO_CAM_SDK unloadlibrary done');


end