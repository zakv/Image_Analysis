function Main_PCO_Pixelfly_USB_31072012_flu(savingname,imacount,PR,DI,TR,EX,TI,IR,BL,SF,HB,VB,average,twoimage)
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
SNumber=1;
DI=0;
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

if(act_recstate~=0)
    [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecordingState', out_ptr, 0);
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
    
    save_file8=sprintf('AveragedImage-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',n,clock);
    save_file9=sprintf('ProcessedFluorescenceImage-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.ascii',n,clock);
    save_file10=sprintf('Number_ofatoms-image%04d-%04d-%02d-%02d-%02d-%02d-%2.2g.txt',n,clock);
    %save_file1=sprintf('test_%04d.tif',n);
    %save_file2=sprintf('test_%04d.bmp',n);
    %save_file3=sprintf('test_%04d.ascii',n);
    %save_file3=save('test_%04d','-ascii');

    %control external components
    %next line simulates control call
    %pause(0.5);

    % [errorCode,out_ptr,wtrigdone] = calllib('PCO_CAM_SDK', 'PCO_ForceTrigger', out_ptr,wtrigdone);
    % if(errorCode)
    %     disp(['PCO_ForceTrigger failed with error ',num2str(errorCode,'%X')]);   
    %  end
 
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
            dlmwrite(fullfile('.',save_file7), result_image1','delimiter', '\t');
            dlmwrite(fullfile('.',save_file71), result_image2','delimiter', '\t');
            dlmwrite(fullfile('.',save_file72), result_image3','delimiter', '\t');
        end
        %total_image1=double(total_image1) + double(result_image1');
        %total_image2=double(total_image2) + double(result_image2');
        part1=double(result_image1');
        part2=double(result_image2');
        part3=double(result_image3');
        part1=part1(50:200,100:250);
        part2=part2(50:200,100:250);
        part3=part3(50:200,100:250);
        figure(2)
        imshow(result_image1',[0,40000]);colorbar()
        figure(3)
        imshow(result_image2',[0,40000]);colorbar()
        figure(4)
        imshow(result_image3',[0,40000]);colorbar()
        figure(6)
        imagesc(-1*log(abs(part1-part3)./abs(part2-part3))/log(10),[-0.15,0.15]);colorbar()
    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%For another new picture in the same for sequence.%%%%%%%%
    if (twoimage==0)
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (average==0)
            dlmwrite(fullfile('.',save_file7), result_image1','delimiter', '\t');
        end
        %total_image1=double(total_image1) + double(result_image1');
        %total_image2=double(total_image2) + double(result_image2');
        part1=MatrixCopy(double(result_image1'),3);
        
        figure(2)
        imshow(part1,[300,450]);colorbar()
       
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
   

