function varargout = Set_Camera_Settings(varargin)
% SET_CAMERA_SETTINGS M-file for Set_Camera_Settings.fig
%      SET_CAMERA_SETTINGS, by itself, creates a new SET_CAMERA_SETTINGS or raises the existing
%      singleton*.
%
%      H = SET_CAMERA_SETTINGS returns the handle to a new SET_CAMERA_SETTINGS or the handle to
%      the existing singleton*.
%
%      SET_CAMERA_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SET_CAMERA_SETTINGS.M with the given input arguments.
%
%      SET_CAMERA_SETTINGS('Property','Value',...) creates a new SET_CAMERA_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Set_Camera_Settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Set_Camera_Settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Set_Camera_Settings

% Last Modified by GUIDE v2.5 11-Jul-2018 19:46:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Set_Camera_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @Set_Camera_Settings_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Set_Camera_Settings is made visible.
function Set_Camera_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Set_Camera_Settings (see VARARGIN)
handles.pixel_rate=2;
%handles.double_image=1;
handles.trigger=2;
handles.exposure_time=200;
handles.timebase=1;
handles.imacount=1;
handles.IR=1;
handles.backloader=0;
handles.sensor_format=0;
handles.h_binning=1;
handles.v_binning=1;
handles.average=0;
handles.namefile='Savefile';
handles.absorption_or_fluorescence=1;

handles.h_binningAbs=3;
handles.v_binningAbs=3;
handles.exposure_timeAbs=400;
handles.IRAbs=1;
handles.imacountAbs=1;
handles.pixel_rateAbs=2;
handles.timebaseAbs=1;
handles.triggerAbs=2;
handles.sensor_formatAbs=1;
handles.detuningAbs=0;
handles.filterAbs=0.35;
handles.beamAbs=0.713;

handles.twoimage=1;

handles.backloaderAbs=0;
handles.averageAbs=0;

handles.starting_index=1;
handles.notes='';
handles.metadata=cell(0,2);
temp=clock;
[~,hostname]= system('hostname');
hostname=strtrim(hostname);
if strcmp(hostname,'waveguide4');
    %handles.saving_path=sprintf('D:\\Matlab_Pixelfly_USB_07102014\\%4d%02d%02d',temp(1:3));
    %handles.saving_path=sprintf('C:\\Matlab_Pixelfly_USB_07102014\\%4d%02d%02d',temp(1:3));
    handles.saving_path=sprintf('D:\\Rb_Lab_Camera_Computer_Data\\%4d%02d%02d',temp(1:3));
else
    handles.saving_path=sprintf('F:\\Matlab_Pixelfly_USB_07102014\\%4d%02d%02d',temp(1:3));
end
set(handles.Saving_Path,'String',handles.saving_path);
% Choose default command line output for Set_Camera_Settings
handles.output = hObject;

%Add paths to use other necessary classes, functions, etc.
GUI_dir=fileparts( mfilename('fullpath') ); %Returns full path to directory "GUI"
project_root=fullfile(GUI_dir,'..'); %Returns full path to directory "Image_Analysis"
addpath(fullfile(project_root,'Camera_Control'));
addpath(fullfile(project_root,'Classes'));
addpath(fullfile(project_root,'Functions'));
addpath(fullfile(project_root,'GUI'));
addpath(fullfile(project_root,'Scripts'));
%Add path for eigenbasis imaging.  Assume that the parent directory for
%that project is in the same directory as this project (Currently both are
%on the desktop of the Camera Computer
addpath(fullfile(project_root,'..','AbsorptionImageProcessing','AbsorptionImageProcessing'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Set_Camera_Settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Set_Camera_Settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in SelectPixelRate.
function SelectPixelRate_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPixelRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'High (25 MHz)'
        handles.pixel_rate=2;
    case 'Low (12 MHz)'
        handles.pixel_rate=1;
end
guidata(hObject,handles)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectPixelRate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPixelRate


% --- Executes during object creation, after setting all properties.
function SelectPixelRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPixelRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTriggerMode.
function SelectTriggerMode_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTriggerMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'External Trigger'
        handles.trigger=2;
    case 'Software Trigger'
        handles.trigger=1;
    case 'Auto Trigger'
        handles.trigger=0;
end
guidata(hObject,handles);


% Hints: contents = cellstr(get(hObject,'String')) returns SelectTriggerMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTriggerMode


% --- Executes during object creation, after setting all properties.
function SelectTriggerMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTriggerMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTimebase.
function SelectTimebase_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTimebase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'mili seconds'
        handles.timebase=2;
    case 'micro seconds'
        handles.timebase=1;
    case 'nano seconds'
        handles.timebase=0;
end
guidata(hObject,handles);



% Hints: contents = cellstr(get(hObject,'String')) returns SelectTimebase contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTimebase


% --- Executes during object creation, after setting all properties.
function SelectTimebase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTimebase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IndicateExposureTime_Callback(hObject, eventdata, handles)
% hObject    handle to IndicateExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
temp=str2num(str); 
handles.exposure_time=temp;
guidata(hObject,handles);


% Hints: get(hObject,'String') returns contents of IndicateExposureTime as text
%        str2double(get(hObject,'String')) returns contents of IndicateExposureTime as a double


% --- Executes during object creation, after setting all properties.
function IndicateExposureTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IndicateExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectDoubleImageMode.
function SelectDoubleImageMode_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDoubleImageMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'ON'
        handles.double_image=1;
    case 'OFF'
        handles.double_image=0;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns SelectDoubleImageMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectDoubleImageMode


% --- Executes during object creation, after setting all properties.
function SelectDoubleImageMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectDoubleImageMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SelectNumberOfImages_Callback(hObject, eventdata, handles)
% hObject    handle to SelectNumberOfImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=handles.imacount; %Reset to previous value if someone enters something that's not a number
end
handles.imacount=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of SelectNumberOfImages as text
%        str2double(get(hObject,'String')) returns contents of SelectNumberOfImages as a double


% --- Executes during object creation, after setting all properties.
function SelectNumberOfImages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectNumberOfImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Main_PCO_Pixelfly_USB_28062012(handles.imacount,handles.pixel_rate,handles.double_image,handles.trigger,handles.exposure_time,handles.timebase,handles.IR,handles.backloader,handles.sensor_format,handles.h_binning,handles.v_binning);

%Set the run_config parameters that control how Main_PCO... runs
run_config=handles;
run_config.double_image=0;

%Get data that will be stored in the Image instance
image_instance_data.notes=handles.notes;
metadata_cells = get(handles.Metadata, 'data');
metadata_object=metadata_table_to_object(metadata_cells);
image_instance_data=z_combine_metadata(metadata_object,image_instance_data);

%Create data directory if it does not exist
if exist(handles.saving_path,'dir')~=7
    display(handles.saving_path);
   mkdir(handles.saving_path) 
end

%Run the camera data acquisition software
if handles.absorption_or_fluorescence==1
    %Absorption image
    Main_PCO_Pixelfly_USB_flu(run_config,image_instance_data);
%     Main_PCO_Pixelfly_USB_flu_Synth_Ramp(run_config,image_instance_data); %For detuning scan
elseif handles.absorption_or_fluorescence==2
    %Fluorescence image
    Main_PCO_Pixelfly_USB_flu1110_TwoImagesTrap(run_config,image_instance_data);
end

%Main_PCO_Pixelfly_USB_07102014_flu(handles.namefile,handles.imacount,handles.pixel_rate,0,handles.trigger,handles.exposure_time,handles.timebase,handles.IR,handles.backloader,handles.sensor_format,handles.h_binning,handles.v_binning,handles.average,handles.twoimage);
%Main_PCO_Pixelfly_USB_07082012_flu_double(handles.imacount,handles.pixel_rate,0,handles.trigger,handles.exposure_time,handles.timebase,handles.IR,handles.backloader,handles.sensor_format,handles.h_binning,handles.v_binning,handles.average);
%save_file=sprintf('Log-image-%04d-%02d-%02d-%02d-%02d-%2.2g.txt',clock);
%Logo=['Flurescence image: Pixel rate: ' num2str(handles.pixel_rate)  '; trigger: ' num2str(handles.trigger) ...,
    %'; expossure time and time base: ' num2str(handles.exposure_time) ' ' num2str(handles.timebase) '; # of images: ' num2str(handles.imacount) ...,
    %'; IR sensitivity: ' num2str(handles.IR) '; sensor format: ' num2str(handles.sensor_format) '; Binning: ' num2str(handles.h_binning) ' ' num2str(handles.v_binning) ';Average:' num2str(handles.average)];
%dlmwrite(fullfile('.',save_file), Logo,'delimiter', '');

% --- Executes on selection change in IRSensitivity.
function IRSensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to IRSensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'ON'
        handles.IR=1;
    case 'OFF'
        handles.IR=0;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns IRSensitivity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IRSensitivity


% --- Executes during object creation, after setting all properties.
function IRSensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IRSensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in backgroundloader.
function backgroundloader_Callback(hObject, eventdata, handles)
% hObject    handle to backgroundloader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'NO'
        handles.backloader=0;
    case 'YES'
        handles.backloader=1;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns, backgroundloader contents as cell array
%        contents{get(hObject,'Value')} returns selected item from backgroundloader


% --- Executes during object creation, after setting all properties.
function backgroundloader_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundloader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Sensor.
function Sensor_Callback(hObject, eventdata, handles)
% hObject    handle to Sensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case '800*600'
        handles.sensor_format=1;
    case '1392*1040'
        handles.sensor_format=0;
    otherwise
        disp('did not match');
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns Sensor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sensor


% --- Executes during object creation, after setting all properties.
function Sensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HBinning_Callback(hObject, eventdata, handles)
% hObject    handle to HBinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=handles.h_binning; %Reset to 2 if someone enters something that's not a number
end
handles.h_binning=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of HBinning as text
%        str2double(get(hObject,'String')) returns contents of HBinning as a double


% --- Executes during object creation, after setting all properties.
function HBinning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HBinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VBinning_Callback(hObject, eventdata, handles)
% hObject    handle to VBinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=handles.v_binning; %Reset to 2 if someone enters something that's not a number
end
handles.v_binning=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);



% Hints: get(hObject,'String') returns contents of VBinning as text
%        str2double(get(hObject,'String')) returns contents of VBinning as a double


% --- Executes during object creation, after setting all properties.
function VBinning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VBinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Average.
function Average_Callback(hObject, eventdata, handles)
% hObject    handle to Average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Average contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Average
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'NO'
        handles.average=0;
    case 'YES'
        handles.average=1;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runAbs.
function runAbs_Callback(hObject, eventdata, handles)
% hObject    handle to runAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Main_PCO_Pixelfly_USB_23082012_gain_measurement(handles.imacountAbs,handles.pixel_rateAbs,1,handles.triggerAbs,handles.exposure_timeAbs,handles.timebaseAbs,handles.IRAbs,handles.backloaderAbs,handles.sensor_formatAbs,handles.h_binningAbs,handles.v_binningAbs,handles.detuningAbs,handles.filterAbs,handles.beamAbs);
%Main_PCO_Pixelfly_USB_09082012_abs_one_trigger(handles.imacountAbs,handles.pixel_rateAbs,1,handles.triggerAbs,handles.exposure_timeAbs,handles.timebaseAbs,handles.IRAbs,handles.backloaderAbs,handles.sensor_formatAbs,handles.h_binningAbs,handles.v_binningAbs,handles.detuningAbs,handles.filterAbs,handles.beamAbs);
%Main_PCO_Pixelfly_USB_31072012_abs(handles.imacountAbs,handles.pixel_rateAbs,1,handles.triggerAbs,handles.exposure_timeAbs,handles.timebaseAbs,handles.IRAbs,handles.backloaderAbs,handles.sensor_formatAbs,handles.h_binningAbs,handles.v_binningAbs,handles.detuningAbs,handles.filterAbs,handles.beamAbs);
Main_PCO_Pixelfly_USB_29082012_abs_processdata(handles.imacountAbs,handles.pixel_rateAbs,1,handles.triggerAbs,handles.exposure_timeAbs,handles.timebaseAbs,handles.IRAbs,handles.backloaderAbs,handles.sensor_formatAbs,handles.h_binningAbs,handles.v_binningAbs,handles.detuningAbs,handles.filterAbs,handles.beamAbs,handles.averageAbs);
save_file=sprintf('Log-image-%04d-%02d-%02d-%02d-%02d-%2.2g.txt',clock);
Logo=['Absorption image: Pixel rate: ' num2str(handles.pixel_rate)  '; trigger: ' num2str(handles.trigger) ...,
    '; expossure time and time base: ' num2str(handles.exposure_time) ' ' num2str(handles.timebase) '; # of images: ' num2str(handles.imacount) ...,
    '; IR sensitivity: ' num2str(handles.IR) '; sensor format: ' num2str(handles.sensor_format) '; Binning: ' num2str(handles.h_binning) ' ' num2str(handles.v_binning) '; Detuning:' num2str(handles.detuningAbs) '; Filter: ' num2str(handles.filterAbs) '; Beam intensity: ' num2str(handles.beamAbs)];
dlmwrite(fullfile('.',save_file), Logo,'delimiter', '');


% --- Executes on selection change in SensorAbs.
function SensorAbs_Callback(hObject, eventdata, handles)
% hObject    handle to SensorAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case '800*600'
        handles.sensor_formatAbs=1;
    case '1392*1040'
        handles.sensor_formatAbs=0;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns SensorAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SensorAbs


% --- Executes during object creation, after setting all properties.
function SensorAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SensorAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VBinningAbs_Callback(hObject, eventdata, handles)
% hObject    handle to VBinningAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=2; %Reset to 2 if someone enters something that's not a number
end
handles.v_binningAbs=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of VBinningAbs as text
%        str2double(get(hObject,'String')) returns contents of VBinningAbs as a double


% --- Executes during object creation, after setting all properties.
function VBinningAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VBinningAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HBinningAbs_Callback(hObject, eventdata, handles)
% hObject    handle to HBinningAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=2; %Reset to 2 if someone enters something that's not a number
end
handles.h_binningAbs=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of HBinningAbs as text
%        str2double(get(hObject,'String')) returns contents of HBinningAbs as a double


% --- Executes during object creation, after setting all properties.
function HBinningAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HBinningAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IRSensitivityAbs.
function IRSensitivityAbs_Callback(hObject, eventdata, handles)
% hObject    handle to IRSensitivityAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'ON'
        handles.IRAbs=1;
    case 'OFF'
        handles.IRAbs=0;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns IRSensitivityAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IRSensitivityAbs


% --- Executes during object creation, after setting all properties.
function IRSensitivityAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IRSensitivityAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SelectNumberOfImagesAbs_Callback(hObject, eventdata, handles)
% hObject    handle to SelectNumberOfImagesAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=1; %Reset to 1 if someone enters something that's not a number
end
handles.imacountAbs=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of SelectNumberOfImagesAbs as text
%        str2double(get(hObject,'String')) returns contents of SelectNumberOfImagesAbs as a double


% --- Executes during object creation, after setting all properties.
function SelectNumberOfImagesAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectNumberOfImagesAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTriggerModeAbs.
function SelectTriggerModeAbs_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTriggerModeAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'External Trigger'
        handles.triggerAbs=2;
    case 'Software Trigger'
        handles.triggerAbs=1;
    case 'Auto Trigger'
        handles.triggerAbs=0;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns SelectTriggerModeAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTriggerModeAbs


% --- Executes during object creation, after setting all properties.
function SelectTriggerModeAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTriggerModeAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IndicateExposureTimeAbs_Callback(hObject, eventdata, handles)
% hObject    handle to IndicateExposureTimeAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
temp=str2num(str); 
handles.exposure_timeAbs=temp;
guidata(hObject,handles);


% Hints: get(hObject,'String') returns contents of IndicateExposureTimeAbs as text
%        str2double(get(hObject,'String')) returns contents of IndicateExposureTimeAbs as a double


% --- Executes during object creation, after setting all properties.
function IndicateExposureTimeAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IndicateExposureTimeAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTimebaseAbs.
function SelectTimebaseAbs_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTimebaseAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'mili seconds'
        handles.timebaseAbs=2;
    case 'micro seconds'
        handles.timebaseAbs=1;
    case 'nano seconds'
        handles.timebaseAbs=0;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns SelectTimebaseAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTimebaseAbs


% --- Executes during object creation, after setting all properties.
function SelectTimebaseAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTimebaseAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectPixelRateAbs.
function SelectPixelRateAbs_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPixelRateAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'High (25 MHz)'
        handles.pixel_rateAbs=2;
    case 'Low (12 MHz)'
        handles.pixel_rateAbs=1;
end
guidata(hObject,handles)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectPixelRateAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPixelRateAbs


% --- Executes during object creation, after setting all properties.
function SelectPixelRateAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPixelRateAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function detuning_Callback(hObject, eventdata, handles)
% hObject    handle to detuning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
temp=str2num(str); 
handles.detuningAbs=temp*4096;
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of detuning as text
%        str2double(get(hObject,'String')) returns contents of detuning as a double


% --- Executes during object creation, after setting all properties.
function detuning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detuning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_Callback(hObject, eventdata, handles)
% hObject    handle to filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
temp=str2num(str); 
handles.filterAbs=temp/100;
guidata(hObject,handles);

% Hints: get(hObject,'String') returns contents of filter as text
%        str2double(get(hObject,'String')) returns contents of filter as a double


% --- Executes during object creation, after setting all properties.
function filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function beamIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to beamIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
temp=str2num(str); 
handles.beamAbs=temp;
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of beamIntensity as text
%        str2double(get(hObject,'String')) returns contents of beamIntensity as a double


% --- Executes during object creation, after setting all properties.
function beamIntensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in AverageAbs.
function AverageAbs_Callback(hObject, eventdata, handles)
% hObject    handle to AverageAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'NO'
        handles.averageAbs=0;
    case 'YES'
        handles.averageAbs=1;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns AverageAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AverageAbs


% --- Executes during object creation, after setting all properties.
function AverageAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AverageAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in backgroundloaderAbs.
function backgroundloaderAbs_Callback(hObject, eventdata, handles)
% hObject    handle to backgroundloaderAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'NO'
        handles.backloaderAbs=0;
    case 'YES'
        handles.backloaderAbs=1;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns backgroundloaderAbs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from backgroundloaderAbs


% --- Executes during object creation, after setting all properties.
function backgroundloaderAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backgroundloaderAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in TwoImage.
function TwoImage_Callback(hObject, eventdata, handles)
% hObject    handle to TwoImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
switch str{val}
    case 'NO'
        handles.twoimage=0;
    case 'YES'
        handles.twoimage=1;
end
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns TwoImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TwoImage


% --- Executes during object creation, after setting all properties.
function TwoImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TwoImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
handles.namefile=str;
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of save as text
%        str2double(get(hObject,'String')) returns contents of save as a double


% --- Executes during object creation, after setting all properties.
function save_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in Metadata.
function Metadata_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Metadata (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
metadata=get(hObject,'Data');
%Remove any disallowed characters from property names
if eventdata.Indices(2)==1 %if editing first (property) column
    name=eventdata.NewData;
    if ~strcmp(name,'')%if the user did not just delete the property
        %Make sure first character is a letter
        if ~isempty(name) && ~isstrprop(name(1),'alpha')
            name=['a',name];
        end
        %Remove disallowed characters
        alphanum=isstrprop(name,'alphanum');
        underscores=name=='_';
        allowed_chars=or(alphanum,underscores);
        name=name(allowed_chars);
        indices=eventdata.Indices;
        metadata{indices(1),indices(2)}=name;
        %Update GUI with name
        set(hObject,'Data',metadata);
    end
end
handles.metadata=metadata;
guidata(hObject,handles);


% --- Executes on button press in Add_Row.
function Add_Row_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
metadata = get(handles.Metadata, 'data');
metadata(end+1,:) = {'',''}; %empty strings to make data type char
handles.metadata=metadata;
set(handles.Metadata,'Data',metadata)
guidata(hObject,handles);



function Notes_Callback(hObject, eventdata, handles)
% hObject    handle to notes_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes_panel as text
%        str2double(get(hObject,'String')) returns contents of notes_panel as a double
handles.notes=get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Starting_Index_Callback(hObject, eventdata, handles)
% hObject    handle to Starting_Index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Starting_Index as text
%        str2double(get(hObject,'String')) returns contents of Starting_Index as a double
str=get(hObject,'String');
temp2=str2num(str);
if isempty(temp2) %Can happen if someone enters something that's not a number
    temp2=handles.starting_index; %Reset to 1 if someone enters something that's not a number
end
handles.starting_index=temp2;
temp2=num2str(temp2);
set(hObject,'String',temp2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Starting_Index_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Starting_Index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Saving_Path_Callback(hObject, eventdata, handles)
% hObject    handle to Saving_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Saving_Path as text
%        str2double(get(hObject,'String')) returns contents of Saving_Path as a double
saving_path=get(hObject,'String');
handles.saving_path=saving_path;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Saving_Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Saving_Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Reset_Camera.
function Reset_Camera_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_Camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Based off of pco_live.m
if libisloaded('PCO_CAM_SDK')
    out_ptr=[]; %Seems to be what pco_live.m uses
    %[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
    %[errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
    unloadlibrary('PCO_CAM_SDK');
    disp('PCO_CAM_SDK unloadlibrary done');
end


% --- Executes on selection change in AbsorptionOrFluorescence.
function AbsorptionOrFluorescence_Callback(hObject, eventdata, handles)
% hObject    handle to AbsorptionOrFluorescence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'Value');
str=get(hObject,'String');
% temp2=num2str(temp2);
% set(hObject,'String',temp2);
% set(handles.Saving_Path,'String',handles.saving_path);
switch str{val}
    case 'Absorption'
        handles.absorption_or_fluorescence=1;
        %Also set default options in GUI for other parameters
        handles.h_binning=1; %Sets internal data
        handles.v_binning=1;
        handles.exposure_time=200;
        handles.timebase=1;
    case 'Fluorescence'
        handles.absorption_or_fluorescence=2;
        %Also set default options in GUI for other parameters
        handles.h_binning=2;
        handles.v_binning=2;
        handles.exposure_time=5;
        handles.timebase=2;
end
%Update displayed values in GUI
set(handles.HBinning,'String', num2str(handles.h_binning) );
set(handles.VBinning,'String', num2str(handles.v_binning) );
set(handles.IndicateExposureTime,'String', num2str(handles.exposure_time) );
set(handles.SelectTimebase,'Value',handles.timebase);
guidata(hObject,handles)

% Hints: contents = cellstr(get(hObject,'String')) returns AbsorptionOrFluorescence contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AbsorptionOrFluorescence


% --- Executes during object creation, after setting all properties.
function AbsorptionOrFluorescence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AbsorptionOrFluorescence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Free_Run.
function Free_Run_Callback(hObject, eventdata, handles)
% hObject    handle to Free_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Edit the values in this copy of handles for free run mode
date_string=num2str(now,12); %12 digits is enough to be unique
date_string=strrep(date_string,'.','p'); %replace decimal with 'p'
handles.namefile=strcat('freeRun',date_string);
handles.imacount=1e5; %Effectively run forever

%Call the run button callback, but with the modified handles
run_Callback(hObject, eventdata, handles);
