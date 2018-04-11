function varargout = Back(varargin)
% Back MATLAB code for Back.fig
%      Back, by itself, creates a new Back or raises the existing
%      singleton*.
%
%      H = Back returns the handle to a new Back or the handle to
%      the existing singleton*.
%
%      Back('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Back.M with the given input arguments.
%
%      Back('Property','Value',...) creates a new Back or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Back_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Back_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Back

% Last Modified by GUIDE v2.5 12-Mar-2017 16:58:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Back_OpeningFcn, ...
                   'gui_OutputFcn',  @Back_OutputFcn, ...
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

function Back_OpeningFcn(hObject, eventdata, handles, varargin)
%% add path
addpath(genpath('FunctionsBWC'));
%% preloading to the data
handles.filename='bw.inp';
set(handles.edit9,'String',handles.filename)
[handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I]=readf(handles.filename);
set(handles.edit1,'String',num2str(handles.b));
set(handles.edit2,'String',num2str(handles.ho));
set(handles.edit3,'String',num2str(handles.dx));
set(handles.edit4,'String',num2str(handles.Q));
set(handles.edit5,'String',num2str(handles.C));
set(handles.edit6,'String',num2str(handles.I));
%% validation of the inputs
if isnan(handles.b) 
    msgbox('Please enter the value of b')
    return
elseif isnan(handles.ho)
    msgbox('Please enter the value of ho')
    return
elseif isnan(handles.dx)
    msgbox('Please enter the value of dx')
    return
elseif isnan(handles.Q)
    msgbox('Please enter the value of Q')
    return
elseif isnan(handles.C)
    msgbox('Please enter the value of C')
    return
elseif isnan(handles.I)
    msgbox('Please enter the value of I')
    return
end
set(handles.edit7,'String',10);
%% 
cla(handles.axes1)
axis off
set( findall(handles.uitable1, '-property', 'visible'), 'visible', 'off') % make the table  invisible
%% background
ha=axes('units','normalized','position',[0 0 1 1]);
uistack(ha,'down')
II=imread('bgBWC.jpg');
image(II)
colormap gray
set(ha,'handlevisibility','off','visible','off');
%% variable that its value will increase if calculate button has been pressed 
handles.calculatevalidate=0;

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


function varargout = Back_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;




%% select the file
function pushbutton1_Callback(hObject, eventdata, handles)
[handles.filename,handles.path] = uigetfile('*.inp','File Selector','Select the bw file');
if (handles.filename~=0)
    handles.path=[handles.path handles.filename];
else
   return
end
set(handles.edit9,'String',handles.filename)
[handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I]=readf(handles.path);
set(handles.edit1,'String',num2str(handles.b));
set(handles.edit2,'String',num2str(handles.ho));
set(handles.edit3,'String',num2str(handles.dx));
set(handles.edit4,'String',num2str(handles.Q));
set(handles.edit5,'String',num2str(handles.C));
set(handles.edit6,'String',num2str(handles.I));
guidata(hObject, handles);

%% Calculate
function pushbutton2_Callback(hObject, eventdata, handles)
%% increase the validation variable
handles.calculatevalidate=1;

%% reread the data agin from the screen
handles.b=str2double(get(handles.edit1,'String'));  % read them again from the gui as the user might change any value
handles.ho=str2double(get(handles.edit2,'String'));
handles.dx=str2double(get(handles.edit3,'String'));
handles.Q=str2double(get(handles.edit4,'String'));
handles.C=str2double(get(handles.edit5,'String'));
handles.I=str2double(get(handles.edit6,'String'));
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
%% validation of the inputs
if isnan(handles.b) 
    msgbox('Please enter the value of b')
    return
elseif isnan(handles.ho)
    msgbox('Please enter the value of ho')
    return
elseif isnan(handles.dx)
    msgbox('Please enter the value of dx')
    return
elseif isnan(handles.Q)
    msgbox('Please enter the value of Q')
    return
elseif isnan(handles.C)
    msgbox('Please enter the value of C')
    return
elseif isnan(handles.I)
    msgbox('Please enter the value of I')
    return
end
%% calculation
handles.approach=get(handles.radiobutton1,'Value');
% valdation of N or convergence value
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n');
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
%--------------------------------------------------------------------------
% predefined no of steps
if handles.approach==1
    [handles.R]=calc(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
%--------------------------------------------------------------------------
% convergence condition
else
    [handles.R,handles.n]=convergence(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end
% Update handles structure
guidata(hObject, handles);

%% plotting
function pushbutton3_Callback(hObject, eventdata, handles)
%% Validation
if handles.calculatevalidate~= 1
    msgbox('please press run first');
    return
end
    
%% read them again from the gui as the user might change any value
b1=str2double(get(handles.edit1,'String'));  
ho1=str2double(get(handles.edit2,'String'));
dx1=str2double(get(handles.edit3,'String'));
Q1=str2double(get(handles.edit4,'String'));
C1=str2double(get(handles.edit5,'String'));
I1=str2double(get(handles.edit6,'String'));
n1=str2double(get(handles.edit7,'String'));
acc1=str2double(get(handles.edit8,'String'));
%% validation
if b1~=handles.b        % handles.b is the value of b stored in the load the file pushbutton & bi is the newly read value 
    msgbox(['you have changed the value of b without recalculating please press run'])
    return
elseif ho1~=handles.ho
    msgbox('you have changed the value of ho without recalculating please press run')
    return
elseif dx1~=handles.dx
    msgbox('you have changed the value of dx without recalculating please press run')
    return
elseif Q1~=handles.Q
    msgbox('you have changed the value of Q without recalculating please press run')
    return
elseif C1~=handles.C
    msgbox('you have changed the value of C without recalculating please press run')
    return
elseif I1~=handles.I
    msgbox('you have changed the value of I without recalculating please press run')
    return
elseif handles.approach==1 && n1~=handles.n  %% approach=1 if user chose predefined no of points
    msgbox('you have changed the value of n without recalculating please press run')
    return
elseif handles.approach==0 && acc1~=handles.accuracy  %% approach=0 if user chose convergence
    msgbox('you have changed the value of accuracy without recalculating please press calculate')
    return
end

%% plotting
axes(handles.axes1)
plott(handles.R)      % function to plot the entire matrix
%h=animatedline;
%  for i=1:length(handles.R(2,:))
%      addpoints(h,handles.R(2,i),handles.R(5,i)) % plotting water level
%      drawnow
%      hold on
%      addpoints(h,handles.R(2,i),handles.R(4,i)) % % plotting bed level
%      drawnow
%      addpoints(h,handles.R(2,i),handles.R(3,i)) % % plotting water depth
%      drawnow
%      legend('Water level','Bed level','Water depth','Location','east')
% end
%% table
set( findall(handles.uitable1, '-property', 'visible'), 'visible', 'on') % make the table  invisible
set(handles.uitable1,'Data',handles.R);

%% clear data
function pushbutton4_Callback(hObject, eventdata, handles)
set(handles.edit1,'String','');
set(handles.edit2,'String','');
set(handles.edit3,'String','');
set(handles.edit4,'String','');
set(handles.edit5,'String','');
set(handles.edit6,'String','');
set(handles.edit7,'String','');
set(handles.edit8,'String','');

%% save results
function pushbutton5_Callback(hObject, eventdata, handles)
writef(handles.R,handles.n)

%% clear figure & table
function pushbutton6_Callback(hObject, eventdata, handles)
axes(handles.axes1)
cla(handles.axes1)
set(handles.uitable1,'Data',[])

%% save figure
function pushbutton9_Callback(hObject, eventdata, handles)
[Filename,Pathname] = uiputfile({ '*.jpg'}, 'Save plots');
if Filename==0
    return;
else
    
str=strcat(Pathname,Filename);
im=getframe(handles.axes1);     % stores the frame in a struct cdata
im1=[im.cdata];
imwrite(im1,str)
end


%% close
function pushbutton8_Callback(hObject, eventdata, handles)
close(Back)

%% table
function uitable1_CreateFcn(hObject, eventdata, handles)



%% b
function slider1_Callback(hObject, eventdata, handles)
%% read the value of the slider
set(handles.slider1,'Max',handles.b+50,'Min',0,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
%% set the value of the slider in the edit text
set(handles.edit1,'String',num2str(sliderval)) % set the value of the slider to the edit text
handles.b=get(handles.slider1,'Value');        % read the value of the b from the value of the slider

handles.approach=get(handles.radiobutton1,'Value');
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n')
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
if handles.approach==1
    [handles.R]=calcslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
else
    [handles.R,handles.n]=convergenceslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end

plott(handles.R)
set(handles.uitable1,'Data',handles.R)
guidata(hObject, handles);

function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% ho 
function slider2_Callback(hObject, eventdata, handles)
%set(handles.slider2,'Max',handles.ho+10,'Min',1,'SliderStep',[0.01 0.01]);
set(handles.slider2,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.edit2,'String',num2str(sliderval))
handles.ho=get(handles.slider2,'Value');

handles.approach=get(handles.radiobutton1,'Value');
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n')
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
if handles.approach==1
    [handles.R]=calcslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
else
    [handles.R,handles.n]=convergenceslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end

plott(handles.R)
set(handles.uitable1,'Data',handles.R)
guidata(hObject, handles);

function slider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% dx
function slider3_Callback(hObject, eventdata, handles)
%set(handles.slider3,'Max',handles.dx+10000,'Min',0,'SliderStep',[0.01 0.01]);
set(handles.slider3,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.edit3,'String',num2str(sliderval))
handles.dx=get(handles.slider3,'Value');

handles.approach=get(handles.radiobutton1,'Value');
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n')
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
if handles.approach==1
    [handles.R]=calcslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
else
    [handles.R,handles.n]=convergenceslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end

plott(handles.R)
set(handles.uitable1,'Data',handles.R)
guidata(hObject, handles);

function slider3_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% Q
function slider4_Callback(hObject, eventdata, handles)
%set(handles.slider4,'Max',handles.Q+200,'Min',0,'SliderStep',[0.01 0.01]);
set(handles.slider4,'SliderStep',[0.0010 0.0001]);
sliderval=get(hObject,'Value');
set(handles.edit4,'String',num2str(sliderval))
handles.Q=get(handles.slider4,'Value');

handles.approach=get(handles.radiobutton1,'Value');
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n')
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
if handles.approach==1
    [handles.R]=calcslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
else
    [handles.R,handles.n]=convergenceslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end

plott(handles.R)
set(handles.uitable1,'Data',handles.R)
guidata(hObject, handles);

function slider4_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% C
function slider5_Callback(hObject, eventdata, handles)
%set(handles.slider5,'Max',handles.C+50,'Min',0,'SliderStep',[0.01 0.01]);
set(handles.slider5,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.edit5,'String',num2str(sliderval))
handles.C=get(handles.slider5,'Value');

handles.approach=get(handles.radiobutton1,'Value');
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n')
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
if handles.approach==1
    [handles.R]=calcslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
else
    [handles.R,handles.n]=convergenceslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end
plott(handles.R)
set(handles.uitable1,'Data',handles.R)
guidata(hObject, handles);
function slider5_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% I
function slider6_Callback(hObject, eventdata, handles)
%set(handles.slider6,'Max',1,'Min',0,'SliderStep',[0.00001 0.000001]);
set(handles.slider6,'SliderStep',[0.01 0.01]);
set(handles.slider6,'SliderStep',[0.00000001 0.0000001]);
sliderval=get(hObject,'Value');
set(handles.edit6,'String',num2str(sliderval))
handles.I=get(handles.slider6,'Value');

handles.approach=get(handles.radiobutton1,'Value');
handles.n=str2double(get(handles.edit7,'String'));
handles.accuracy=str2double(get(handles.edit8,'String'));
if handles.approach==1 && isnan(handles.n)  % check if the user has inputed n only if the approach is predefined no of steps
    msgbox('Please enter the value of n');
    return
elseif handles.approach==0 && isnan(handles.accuracy)  % check if the user has inputed accuracy only if the approach is convergence
    msgbox('Please enter the value of the accuracy');
    return
end
if handles.approach==1
    [handles.R]=calcslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.n);
else
    [handles.R,handles.n]=convergenceslider(handles.b,handles.ho,handles.dx,handles.Q,handles.C,handles.I,handles.accuracy);
    set(handles.edit7,'String',num2str(length(handles.R(1,:))));
end

plott(handles.R)
set(handles.uitable1,'Data',handles.R)
guidata(hObject, handles);

function slider6_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% Predefined No of steps
function radiobutton1_Callback(hObject, eventdata, handles)

%% Convergent
function radiobutton2_Callback(hObject, eventdata, handles)



%% b
function edit1_Callback(hObject, eventdata, handles)
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% initial depth
function edit2_Callback(hObject, eventdata, handles)
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% dx
function edit3_Callback(hObject, eventdata, handles)
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Q
function edit4_Callback(hObject, eventdata, handles)
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% C
function edit5_Callback(hObject, eventdata, handles)
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% I
function edit6_Callback(hObject, eventdata, handles)
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% N
function edit7_Callback(hObject, eventdata, handles)
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Accuracy
function edit8_Callback(hObject, eventdata, handles)
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% file name
function edit9_Callback(hObject, eventdata, handles)
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% do you want to save window
%% if n is not integer nnmber
%% draw the cross section as in object assignment
