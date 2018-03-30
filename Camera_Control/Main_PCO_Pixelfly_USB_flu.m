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
% row_min=50; row_max=350; col_min=1; col_max=171; %Region that may have atoms
% row_min=35; row_max=135; col_min=1; col_max=301; %Region that may have atoms
% row_min=10; row_max=70; col_min=1; col_max=800; %Region that may have atoms
row_min=35; row_max=135; col_min=1; col_max=171; %Region that may have atoms

%Set range for colobar scale of atom OD plot
OD_colorbar_range=[-0.1,0.5]*1.2;
% OD_colorbar_range=[-0.1,2.];
% OD_colorbar_range=[-0.1,0.4];

%Set region of interest for analysis [row_min,row_max;col_min,col_max]
%(Note semicolon between row and columns indices)
% analysis_ROI=[1,405;298,468];
% analysis_ROI=[248,418;233,533];
% analysis_ROI=[260,340;1,800];
% analysis_ROI=[215,385;295,465];
analysis_ROI=[215,385;345,515];

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

Total=zeros(1,imacount);
StandD=zeros(1,imacount);
meanofROI=zeros(1,imacount);

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
dwValidImageCnt=uint32(0);
dwMaxImageCnt=uint32(0);
wtrigdone=uint16(0);
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


if (VB==2)&&(HB==2)&&(SF==1)
    total_image1=zeros(300,400);
    total_image2=zeros(300,400);
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
for n=1:imacount
    %save_file1=sprintf('image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.tif',n,clock);
    %save_file3=sprintf('Double-minus-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',n,clock);
    save_file4=sprintf('Raw1-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',n,clock);
    save_file5=sprintf('Raw2-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',n,clock);
    save_file6=sprintf('All-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.tif',n,clock);
    
    tempclockRecord=clock;
    %save_file7=strcat(savingname,sprintf('-%04d-%04d%02d-%02d.ascii',n,tempclockRecord(1),tempclockRecord(2),tempclockRecord(3)));
    %save_file71=strcat(savingname,sprintf('back-%04d-%04d%02d-%02d.ascii',n,tempclockRecord(1),tempclockRecord(2),tempclockRecord(3)));
    save_file7=strcat(savingname,'-',num2str(SNumber+n-1),'.ascii');
    save_file71=strcat(savingname,'back-',num2str(SNumber+n-1),'.ascii');
    save_file72=strcat(savingname,'noise-',num2str(SNumber+n-1),'.ascii');
    
   
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%One image cleaning the buffer%%%%%%
%  dwValidImageCnt=0;
%         a=0;
%         while((dwValidImageCnt<1)&&(errorCode==0))
%             [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,act_segment,dwValidImageCnt,dwMaxImageCnt);
%          if(errorCode)
%              disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);   
%          end
%           % disp(['segment ',int2str(act_segment),':  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);
%            pause(waittime_s);
%            a=a+1;
%            if(a>500)
%                 disp('timeout in waiting for images');   
%                 errorCode=1;
%            end
%         end
% 
%         if(errorCode==0)
%             [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,act_segment,0,0,sBufNr,strSegment.wXRes,strSegment.wYRes,bitpix);
%             if(errorCode)
%                 disp(['PCO_GetImageEx failed with error ',num2str(errorCode,'%08X')]);   
%             else
%                 disp(['PCO_GetImageEx image ' int2str(n) ' done']);
%             end
%         end
% 
%         if(errorCode==0)
%             [errorCode,out_ptr,image_stackTemp]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
%             if(errorCode)
%                 disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
%             end
%         end


        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        [errorCode,out_ptr,image_stack1]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
        if(errorCode)
            disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
        end
    end


    result_image1=image_stack1;
    if (average==0)
        %dlmwrite(fullfile('.',save_file7), result_image1','delimiter', '\t');
    end
    
   
    
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
            [errorCode,out_ptr,image_stack2]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
            if(errorCode)
                disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
            end
        end


        result_image2=image_stack2;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            [errorCode,out_ptr,image_stack3]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
            if(errorCode)
                disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
            end
        end


        result_image3=image_stack3;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (average==0)
            pic=Image(savingname,SNumber+n-1);
            pic.set_dir(saving_path);
            pic.timestamp=clock();
            pic.run_config=run_config;
            pic.transfer_metadata(image_instance_data);
            pic.save();
%             dlmwrite(pic.raw_image_filename, result_image1','delimiter', '\t');
%             dlmwrite(pic.back_image_filename, result_image2','delimiter', '\t');
%             dlmwrite(pic.noise_image_filename, result_image3','delimiter', '\t');
          % dlmwrite(pic.raw_image_filename, result_image1','delimiter', '\t');
          % dlmwrite(pic.back_image_filename, result_image2','delimiter', '\t');
          % dlmwrite(pic.noise_image_filename, result_image3','delimiter', '\t');
        end
        %total_image1=double(total_image1) + double(result_image1');
        %total_image2=double(total_image2) + double(result_image2');
        part1=double(result_image1');
        part2=double(result_image2');
        part3=double(result_image3');
        rmin=analysis_ROI(1,1);rmax=analysis_ROI(1,2);
        cmin=analysis_ROI(2,1);cmax=analysis_ROI(2,2);
        part1=part1(rmin:rmax,cmin:cmax);
        part2=part2(rmin:rmax,cmin:cmax);
        part3=part3(rmin:rmax,cmin:cmax);
        dlmwrite(pic.raw_image_filename, part1,'delimiter', '\t');
        dlmwrite(pic.back_image_filename, part2,'delimiter', '\t');
        dlmwrite(pic.noise_image_filename, part3,'delimiter', '\t');
%         temppart=-1*log(abs(part1-part3)./abs(part2-part3));
        
        %Vendeiro New background removal stuff as of July 5th 2017
        %Clear image data cache in case we use the same file name twice
        try
            load_image('',true); %Throws and error since '' is not a real file name
        catch
        end
        temppart=quick_back_removal_eig(saving_path,part1,row_min,row_max,col_min,col_max,part2);
        %Vendeiro End of new background removal stuff
        
        %temppart=temppart(40:80,40:80);
        %figure(2)
        %imagesc(doub2le(result_image2')-double(result_image3'),[0,1100]);colorbar();colormap jet;
        figure(3)
        imagesc(result_image1',[0,7500]);colorbar();colormap jet;
        figure(4)
        imagesc(result_image2',[0,7500]);colorbar();colormap jet;
        figure(6)
        imagesc(temppart,OD_colorbar_range);colorbar();
        back_region=make_back_region(temppart,row_min,row_max,col_min,col_max);
        atompart=temppart.*(1-back_region); %Image with all pixels in the back region set to 0
        peak_OD=max(max(atompart));
        total_OD=sum(sum(atompart));
        title_string=sprintf('Peak OD is %0.2f \n Integrated OD is %0.2f', peak_OD,total_OD);
        title(title_string,'FontSize',30);
        %imagesc(temppart(40:80,40:80),[-0.5,0.5]);colorbar()
        %figure(2)
        %imagesc(part1-part2,[0,100]);colorbar();colormap jet;
    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%For another new picture in the same for sequence.%%%%%%%%
    if (twoimage==0)
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          dwValidImageCnt=0;
%         a=0;
%         while((dwValidImageCnt<1)&&(errorCode==0))
%             [errorCode,out_ptr,dwValidImageCnt,dwMaxImageCnt]  = calllib('PCO_CAM_SDK', 'PCO_GetNumberOfImagesInSegment', out_ptr,act_segment,dwValidImageCnt,dwMaxImageCnt);
%          if(errorCode)
%              disp(['PCO_GetNumberOfImagesInSegment failed with error ',num2str(errorCode,'%X')]);   
%          end
%           % disp(['segment ',int2str(act_segment),':  valid images: ',int2str(dwValidImageCnt),' max images ',int2str(dwMaxImageCnt)]);
%            pause(waittime_s);
%            a=a+1;
%            if(a>500)
%                 disp('timeout in waiting for images');   
%                 errorCode=1;
%            end
%         end
% 
%         if(errorCode==0)
%             [errorCode,out_ptr]  = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,act_segment,0,0,sBufNr,strSegment.wXRes,strSegment.wYRes,bitpix);
%             if(errorCode)
%                 disp(['PCO_GetImageEx failed with error ',num2str(errorCode,'%08X')]);   
%             else
%                 disp(['PCO_GetImageEx image ' int2str(n) ' done']);
%             end
%         end
% 
%         if(errorCode==0)
%             [errorCode,out_ptr,image_stack4]  = calllib('PCO_CAM_SDK','PCO_GetBuffer',out_ptr,sBufNr,im_ptr,ev_ptr);
%             if(errorCode)
%                 disp(['PCO_GetBuffer failed with error ',num2str(errorCode,'%08X')]);   
%             end
%         end
% 
% 
%         result_image4=image_stack4;
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (average==0)
            pic=Image(savingname,SNumber+n-1);
            pic.set_dir(saving_path);
            pic.timestamp=clock();
            pic.run_config=run_config;
            pic.transfer_metadata(image_instance_data);
            pic.save();
                      
            
            dlmwrite(pic.raw_image_filename, result_image1','delimiter', '\t');
            %dlmwrite(pic.back_image_filename, result_image4','delimiter', '\t');
        end
        %total_image1=double(total_image1) + double(result_image1');
        %total_image2=double(total_image2) + double(result_image2');
        part1=MatrixCopy(double(result_image1'),3);
        %part1back=MatrixCopy(double(result_image4'),3);
        
        %figure(2)
        %imagesc(part1,[1300,1500]);colorbar()
        %imagesc(part1-part1back,[0,800]);colorbar()
        %imagesc(part1-part1back,[0,40000]);colorbar()
        figure(3)
        imagesc(part1,[0,40000]);colorbar()
        %figure(4)
        %imagesc(part1back,[0,40000]);colorbar()
       
    end 
end

%save_file700=sprintf('Total-image-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',clock);
%save_file7001=sprintf('Total2-image-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',clock);
%dlmwrite(fullfile('.',save_file700), total_image1,'delimiter', '\t');
%dlmwrite(fullfile('.',save_file7001), total_image2,'delimiter', '\t');


%save_file11=sprintf('Number_of_atoms-whole_images%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.txt',n,clock);
if (DI==0)&&(BL==1)
   % dlmwrite(fullfile('.',save_file11),NumberOfAtomTotal,'delimiter','\t');
end
 %devides sumed background images by total number of background images
if(DI==0)&&(average==1)
    average_image=total_image./imacount;
    figure(3) 
    imshow(average_image,[100,1000]);colorbar()
    dlmwrite(fullfile('.',save_file8), average_image,'delimiter', '\t');
    dlmwrite(fullfile('.','background_image.ascii'), average_image,'delimiter', '\t');
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
   

