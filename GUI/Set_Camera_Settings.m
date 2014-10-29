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

% Last Modified by GUIDE v2.5 29-Oct-2014 03:10:20

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
handles.sensor_format=1;
handles.h_binning=2;
handles.v_binning=2;
handles.average=0;
handles.namefile='Savefile';

handles.h_binningAbs=2;
handles.v_binningAbs=2;
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
% Choose default command line output for Set_Camera_Settings
handles.output = hObject;

%Add paths to use other necessary classes, functions, etc.
project_root=fullfile('..');
addpath(fullfile(project_root,'Camera_Control'));
addpath(fullfile(project_root,'Classes'));
addpath(fullfile(project_root,'Functions'));
addpath(fullfile(project_root,'Scripts'));

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
val=get(hObject,'Value');
str=get(hObject,'String');
temp2=str2num(str);
handles.imacount=temp2;
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
run_config=handles;
run_config.double_image=0;
Main_PCO_Pixelfly_USB_07102014_flu(run_config);
Main_PCO_Pixelfly_USB_07102014_flu(handles.namefile,handles.imacount,handles.pixel_rate,0,handles.trigger,handles.exposure_time,handles.timebase,handles.IR,handles.backloader,handles.sensor_format,handles.h_binning,handles.v_binning,handles.average,handles.twoimage);
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
val=get(hObject,'Value');
str=get(hObject,'String');
temp3=str2num(str);
handles.h_binning=temp3;
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
val=get(hObject,'Value');
str=get(hObject,'String');
temp4=str2num(str);
handles.v_binning=temp4;
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
val=get(hObject,'Value');
str=get(hObject,'String');
temp4=str2num(str);
handles.v_binningAbs=temp4;
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
val=get(hObject,'Value');
str=get(hObject,'String');
temp3=str2num(str);
handles.h_binningAbs=temp3;
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
val=get(hObject,'Value');
str=get(hObject,'String');
temp2=str2num(str);
handles.imacountAbs=temp2;
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


% --- Executes when entered data in editable cell(s) in metadata.
function metadata_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to metadata (see GCBO)
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
        if ~isstrprop(name(1),'alpha')
            name=['a',name];
        end
        %Remove disallowed characters
        alphanum=isstrprop(name,'alphanum');
        underscores=name=='_';
        allowed_chars=or(alphanum,underscores);
        name=name(allowed_chars);
        indices=eventdata.Indices;
        metadata{indices(1),indices(2)}=name;
        handles.metadata=metadata;
        %Update GUI with name
        set(hObject,'Data',metadata);
    end
end


% --- Executes on button press in add_row.
function add_row_Callback(hObject, eventdata, handles)
% hObject    handle to add_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.metadata, 'data');
data(end+1,:) = cell(1,2);
set(handles.metadata,'Data',data)



function notes_Callback(hObject, eventdata, handles)
% hObject    handle to notes_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes_panel as text
%        str2double(get(hObject,'String')) returns contents of notes_panel as a double


% --- Executes during object creation, after setting all properties.
function notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
