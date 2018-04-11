function varargout = developer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @developer_OpeningFcn, ...
                   'gui_OutputFcn',  @developer_OutputFcn, ...
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

function developer_OpeningFcn(hObject, eventdata, handles, varargin)
%% personal photo
%% logo
a=imread('Mostafa Farrag.jpg');
axes(handles.axes1);
imshow(a);
%% background
ha=axes('units','normalized','position',[0 0 1 1]);
uistack(ha,'down')
II=imread('bgdeveloper.jpg');
image(II)
colormap gray
set(ha,'handlevisibility','off','visible','off');




handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = developer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;



function close_Callback(hObject, eventdata, handles)
close(developer)
