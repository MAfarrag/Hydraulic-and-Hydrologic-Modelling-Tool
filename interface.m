function varargout = interface(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
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



function interface_OpeningFcn(hObject, eventdata, handles, varargin)
%% add path
addpath(genpath('Backwater'));
addpath(genpath('FSF'));
addpath(genpath('HBV'));
addpath(genpath('Developer'));
handles.output = hObject;
%% background
ha=axes('units','normalized','position',[0 0 1 1]);
uistack(ha,'down')
II=imread('bginterface.jpg');
image(II)
colormap gray
set(ha,'handlevisibility','off','visible','off');
%% logo
a=imread('logo.jpg');
axes(handles.axes1);
imshow(a);

% Update handles structure
guidata(hObject, handles);


function varargout = interface_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% Back water curve
function BWC_Callback(hObject, eventdata, handles)
Back
%% HBV
function HBV_Callback(hObject, eventdata, handles)
HBVGUIDE
%% FSF
function FSF_Callback(hObject, eventdata, handles)
FSF



function close_Callback(hObject, eventdata, handles)
close(interface)


function developer_Callback(hObject, eventdata, handles)
developer
