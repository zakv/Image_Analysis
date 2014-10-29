function pco_display(waittime)

glvar=struct('do_libunload',1,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('waittime','var'))
 waittime = 0.200;   
end

[err,glvar]=pco_camera_setup(glvar,0);
if(err~=0)
 disp(['pco_camera_setup failed with error ',num2str(err,'%X')]);   
end
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(err==0)
 [err,glvar]=pco_recorder(glvar,20);
 if(err~=0)
  disp(['pco_recorder failed with error ',num2str(err,'%X')]);   
 end
end
if(err==0) 
 disp('get single images')
 for n=1:3   
  [err,ima,glvar]=pco_get_image(glvar,n,1);
  imshow(ima',[0,8000]);
  pause(waittime);
 end 
 disp('Press "Enter" to close window and proceed')
 pause();
 close();
 pause(1);
 clear ima;
end

if(err==0) 
 disp('get multi images')
 nr=9;
 [err,ima,glvar]=pco_get_image(glvar,5,nr);
 if(err==0)
  for n=1:nr   
   imshow(ima(:,:,n)',[0,8000],'InitialMagnification',100);
   pause(waittime);
  end 
 end
 disp('Press "Enter" to close window and camera SDK')
 pause();
 close();
 clear ima;
end

if(glvar.camera_open==1)
 glvar.do_close=1;
% glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clear glvar;
clear ima;

end
   

