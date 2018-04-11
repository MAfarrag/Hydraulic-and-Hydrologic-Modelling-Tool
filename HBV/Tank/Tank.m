function varargout = Tank(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tank_OpeningFcn, ...
                   'gui_OutputFcn',  @Tank_OutputFcn, ...
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

function Tank_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

addpath(genpath('FunctionsTank'));
%% preloading to both data & parameters
%% parameters ----------------------------------------------------------------------
filename='Sieve.txt'; % the GUI will preload the data from bagmati file
path=filename; 
set(handles.editloadparam,'String',filename); % write the file name on the edit text
[handles.par]=readparamT(path,filename);
%% set the parameters at the textboxes
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.par.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
%% data----------------------------------------------------------------------
filename='Sieve.cal'; % the GUI will preload the data from bagmati file 
path=filename; 
[handles.data]=readdataTank(filename,path);
set(handles.editloadinputfile,'String',filename);  %write the name of the loaded file of the edit text
%% clear the figures
axes(handles.axes1)
axis off
axes(handles.axes2)
axis off
% Update handles structure
guidata(hObject, handles);


function varargout = Tank_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% load data
function pushbutton3_Callback(hObject, eventdata, handles)
[filename,path] = uigetfile({'*.cal';'*.mat'},'File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
[handles.data]=readdataTank(filename,path);
set(handles.editloadinputfile,'String',filename);  %write the name of the loaded file of the edit text

% Update handles structure
guidata(hObject, handles);

%% load parameters
function pushbutton1_Callback(hObject, eventdata, handles)
[filename,path] = uigetfile({'*.txt';'*.mat'},'File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
set(handles.editloadparam,'String',filename); % write the file name on the edit text
[handles.par]=readparamT(path,filename);
%% set the parameters at the textboxes
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.par.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
% Update handles structure
guidata(hObject, handles);


%% tank simulation
function pushbutton5_Callback(hObject, eventdata, handles)
% related to stopping the plotting 
set(handles.editstop,'String',0)
%% 1- reread the values of the parameters from the edit text as the user might
% has changed the values
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%--------------------------------------------------------------------------
%% 4- calculation process 
handles.data.LTAT = mean(handles.data.Temp)*ones(length(handles.data.Temp),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT ];    %v=[precipitation,temperature, potential evapotranspiration, daily mean temp]required variable matrix for the HBV code 
v(1,5)=handles.data.Area;

if strcmp(handles.data.TStep,'hourly')==1   % so the data are hourly
    timebases=1;
    unitconst=3.6;
else                                        % so the data are daily
    timebases=0; 
    unitconst=86.4;
end
%% saving a video
Saving=get(handles.popupmenu1,'value');
if Saving==2
    [filename,path] = uiputfile({'*.avi'},'File Selector','Select a name');
    if (filename~=0)
        path=[path filename]; % full path with the name
        set(handles.editfilename,'String',num2str(filename))
    else
        return
    end
end

%--------------------------------------------------------------------------
% if handles.par.PERC>=1 % check on the precentage 
%     msgbox('Please Note that the percolation parameter is greater than 1 so the upper zone might be empty all the time');
%     %return
% end
%--------------------------------------------------------------------------
[H.Error,H.Qcal,H.ST,H.Qo,H.Q1,H.CF]=HBV_Tank(p,handles.data.Flow,v,timebases);
% Qo is the run off from upper zone (mm depth)
% Q1 is the run off from lower zone (mm depth)
% CF is the capilary rise  (mm depth)
% Qcal is the total Run off depth Qcal=Qodepth+Q1depth = ... mm (m3/sec)
% Qt =Qo+Q1 (total run off as a mm depth)
H.SM=H.ST(2:end,2);
H.UZ=H.ST(2:end,3);
H.LZ=H.ST(2:end,4);
H.Qt=H.Q1+H.Qo;         % total run off as mm depth

H.Qodisch=(H.Qo*handles.data.Area)/unitconst;      %(60*60*24*1000/10^6);    % m3/s  discharge
H.Q1disch=(H.Q1*handles.data.Area)/unitconst;      %(60*60*24*1000/10^6);    % m3/s  discharge 

%% plot the discharge
series=1:length(H.Qcal);
axes(handles.axes1);
axis on
%plot(series,H.ST(2:end,2),series,H.ST(2:end,3),series,H.ST(2:end,4));
hold on
plot(H.Q1disch,'m','Linewidth',2);
plot(H.Qodisch,'c','Linewidth',1.5);
plot(H.Qcal,'-r','Linewidth',1.5);  % plot Q cal
%legend({'SM (mm)','UZ (mm)','LZ (mm)','Q1 (m3/s)','Qo (m3/s)','Q Total (m3/s)'},'FontSize',8,'Location','northeast');
legend({'Q1 (m3/s)','Qo (m3/s)','Q Total (m3/s)'},'FontSize',8,'Location','northeast');
title('Run off Simulation');
xlabel('time(days)');
ylabel('Discharge 10^3(m³/s)');
h = get(gca,'ytick');
set(gca,'yticklabel',h/10^3)
%--------------------------------------------------------------------------
% plot the moving ball
p1=plot(1,H.Qcal(1),'o','MarkerFaceColor','red'); % plot the marker
p2=plot(1,H.Q1disch(1),'o','MarkerFaceColor','magenta'); % plot the marker
p3=plot(1,H.Qodisch(1),'o','MarkerFaceColor','cyan'); % plot the marker
%% Plot the tanks
axes(handles.axes2)
cla(handles.axes2)
%Lower zone Tank
l1x = [0,0,9];
l1y = [7,2,2];
l2x = [6,6,9];
l2y = [7,3,3];
plot(l1x,l1y,'k','Linewidth',2)
hold on
plot(l2x ,l2y,'k','Linewidth',2)
%upper zone Tank
l1x = [0,0,3,3];
l1y = [14,9,9,8];
l2x = [4,4,15,15];
l2y = [8,9,9,8];
l3x = [6,6,16,16];
l3y = [14,10,10,8];
plot(l1x,l1y,'k','Linewidth',2)
plot(l2x,l2y,'k','Linewidth',2)
plot(l3x ,l3y,'k','Linewidth',2)
%Total Tank
l1x = [13,13,21];
l1y = [5,0,0];
l2x = [18,18,21];
l2y = [5,1,1];
plot(l1x,l1y,'k','Linewidth',2)
plot(l2x,l2y,'k','Linewidth',2)

xlim([0,22]);
ylim([0,16]);
axis off
%grid on
% names of the tankes
text(1,7.5,'Lower Zone');
text(1.5,15,'Upper Zone');
text(13.5,6,'Total Runoff');
text(7,5,'Q1');
text(8,12,'Qo');
text(18.5,3,'Qtotal');
% recording a video 
handles.frame = struct('cdata',[],'colormap',[]);
f = 1;
% h1 = animatedline; %h2 = animatedline;
for i = 1:1:series(end)
    %% check if the user want to stop plotting
    if str2double(get(handles.editstop,'String'))==1
        break
    end
    %% values of the runn off dicharge and depth
    t1=text(7,4,strcat(num2str(round(H.Q1disch(i),2),2), ' m³/s'));  % Q1
    t2=text(8,11,strcat(num2str(round(H.Qodisch(i),2),2),' m³/s'));  % Q0
    t3=text(1.5,14,strcat(num2str(round(H.UZ(i),2),2), ' mm'));    % UZ=Sim.ST(:,3)
    t4=text(4,7.5,strcat(num2str(round(H.LZ(i),2),2), ' mm'));    % LZ=Sim.ST(:,4)
    t5=text(18.5,2,strcat(num2str(round(H.Qcal(i),2),2), ' m³/s')); % Qcal total run off as discharge
    t6=text(18,6,strcat(num2str(round(H.Qt(i),2),2), ' mm')); % Qt total run off as depth
    %----------------------------------------------------------------------
    % move the moving balls
    axes(handles.axes1)
    p1.XData = series(i+1);
    p1.YData = H.Qcal(i);
    p2.XData = series(i+1);
    p2.YData = H.Q1disch(i);
    p3.XData = series(i+1);
    p3.YData = H.Qodisch(i);
    drawnow  
    % relative depth (depth/max depth)-------------------------------------
    axes(handles.axes2);
    UZr = H.UZ(i)/max(H.UZ);
    LZr = H.LZ(i)/max(H.LZ);
    Qor = H.Qo(i)/max(H.Qo);    % Upper zone relative depth
    Q1r = H.Q1(i)/max(H.Q1);    % lower zone relative depth
    %Qcald=H.Qcal(i)/max(H.Qcal);
    Qodischr=H.Qodisch(i)/max(H.Qcal);
    Q1dischr=H.Q1disch(i)/max(H.Qcal);
%     Qtr =H.Qt(i)/max(H.Qt);
    Qcalr=H.Qcal(i)/max(H.Qcal);
    %% Filling tanks
    %1- Lower Zone tank (datum is 2)
    hbody = (7-2)*LZr+2; % Y coordinate of the points in the body of the tank
    %harm = (3-2)*Q1r+2;  % Y coordinate of the points in the arm
    harm = (3-2)*Q1dischr+2;  % Y coordinate of the points in the arm
    % body (for the depth)
    xbody = [0,0,6,6];   % X coordinate of the four points of the body
    ybody = [hbody,2,2,hbody];
    % arm (for the discharge)
    xarm = [6,6,9,9];
    yarm = [2,harm,harm,2];
    %Fill
    f1=fill(xbody,ybody,'b'); % fill the area surrounded by these coordinates by blue polygon
    f2=fill(xarm,yarm,'m');
    %----------------------------------------------------------------------
    %% 2- Upper zone tank (datum is 9)
    hbody = (14-9)*UZr+9;   % Y coordinate of the points in the body of the tank
    harm = (10-9)*Qodischr+9;    % Y coordinate of the points in the arm
    % body (for the depth)
    xbody = [0,0,6,6];      % X coordinate of the four points of the body
    ybody = [hbody,9,9,hbody];
    % Arm (for the discharge)
    xarm = [6,6,16,16];
    yarm = [9,harm,harm,9];
    % Connection 1
    xconnect = [2,4,4,2];      % if there is a sufficient depth fill the entire connection
    yconnect = [9,9,8,8];
    % Connection 2
    xconnect2 = [15,15,16,16];  % if there is a sufficient depth fill the entire connection
    yconnect2 = [9,8,8,9];
    %Fill
    f3=fill(xbody,ybody,'b');
    f4=fill(xarm,yarm,'c');    %[0 0.85 0.85]
    if UZr > 0.01
        f5=fill(xconnect,yconnect,'b');  % fill the connection
        f6=fill(xconnect2,yconnect2,'c');  % fill the connection2  [0 0.85 0.85]
    end
    %% 3- Total tank (datum is 0)
    hbody1 = (5-0)*Q1r+0;        % Y coordinate of the points in the body of the tank Q1depth (lower zone depth)in the bottom 
    hbody2 = (5-0)*Qor+hbody1; % Y coordinate of the points in the body of the tank Qodepth (upper zone depth) in top of the Q1
    harm = (3-2)*Qcalr+0;  % Y coordinate of the points in the arm
    % body1 (for the depth) from lower zone
    xbody1 = [13,13,18,18];      % X coordinate of the four points of the body
    ybody1 = [hbody1,0,0,hbody1];
    % body2 (for the depth) from upper zone
    xbody2 = [13,13,18,18];      % X coordinate of the four points of the body
    ybody2 = [hbody2,hbody1,hbody1,hbody2];
    % Arm (for the discharge)
    xarm = [18,18,21,21];
    yarm = [0,harm,harm,0];
    %Fill
    f7=fill(xbody1,ybody1,'m');
    f8=fill(xbody2,ybody2,'c');
    f9=fill(xarm,yarm,'c');
    %----------------------------------------------------------------------
    pause(0.1)
    %drawnow
    %----------------------------------------------------------------------
    delete(t1);delete(t2);delete(t3);delete(t4);delete(t5);delete(t6);
    delete(f1);delete(f2);delete(f3);delete(f4);delete(f7);delete(f8);
    if UZr > 0.01
        delete(f5);
        delete(f6);
    end
    delete(f9);
    %----------------------------------------------------------------------
    %% recording frames for the video
    if get(handles.popupmenu1,'value') == 2
        handles.frame(f) = getframe(gcf);
        f = f+1;
    end
end
Saving=get(handles.popupmenu1,'value');
if Saving==2
    %% writting the video
    v = VideoWriter(path,'Motion JPEG AVI');
    % Open the file for writing.
    open(v)
    % Write the image in A to the video file.
    writeVideo(v,handles.frame)
    % Close the file.
    close(v)
end



% save
function pushbutton6_Callback(hObject, eventdata, handles)
% Saving the video   
Saving=get(handles.popupmenu1,'value');
if Saving==2
    msgbox('saving the video should be selected before the simulation');
    return
elseif Saving==3
    [filename,path] = uiputfile({'*.jpg'},'File Selector','Define Figure Output');
    if (filename~=0)
        path=[path filename]; % full path with the name
    else
        return
    end
    set(handles.editfilename,'String',filename);  %write the name of the loaded file of the edit text
    im1=getframe(handles.axes1);
    im1=[im1.cdata];
    imwrite(im1,path)
elseif Saving==4
    [filename,path] = uiputfile({'*.jpg'},'File Selector','Define Figure Output');
    if (filename~=0)
        path=[path filename]; % full path with the name
    else
        return
    end
    set(handles.editfilename,'String',filename);  %write the name of the loaded file of the edit text
    im1=getframe(handles.axes2);
    im1=[im1.cdata];
    imwrite(im1,path)
end

%% popupmenu
function popupmenu1_Callback(hObject, eventdata, handles)
handles.Saving=get(handles.popupmenu1,'value');
% video=2
% figure=3
% tanks = 4
% Update handles structure
guidata(hObject, handles);
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% clear figure
function pushbutton7_Callback(hObject, eventdata, handles)
axes(handles.axes1)
cla(handles.axes1)
axes(handles.axes2)
cla(handles.axes2)

%% stop plotting
function pushstop_Callback(hObject, eventdata, handles)
set(handles.editstop,'String',1)
% Update handles structure
guidata(hObject,handles);
%% close
function pushbutton4_Callback(hObject, eventdata, handles)
close(Tank)







function editloadparam_Callback(hObject, eventdata, handles)
function editloadparam_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editloadinputfile_Callback(hObject, eventdata, handles)
function editloadinputfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTT_Callback(hObject, eventdata, handles)
function editTT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTTI_Callback(hObject, eventdata, handles)
function editTTI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTTM_Callback(hObject, eventdata, handles)
function editTTM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editK1_Callback(hObject, eventdata, handles)
function editK1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editBETA_Callback(hObject, eventdata, handles)
function editBETA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editALPHA_Callback(hObject, eventdata, handles)
function editALPHA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editECORR_Callback(hObject, eventdata, handles)
function editECORR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFC_Callback(hObject, eventdata, handles)
function editFC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCFMAX_Callback(hObject, eventdata, handles)
function editCFMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editETF_Callback(hObject, eventdata, handles)
function editETF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editLP_Callback(hObject, eventdata, handles)
function editLP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCWH_Callback(hObject, eventdata, handles)
function editCWH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCFR_Callback(hObject, eventdata, handles)
function editCFR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCFLUX_Callback(hObject, eventdata, handles)
function editCFLUX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPERC_Callback(hObject, eventdata, handles)
function editPERC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRFCF_Callback(hObject, eventdata, handles)
function editRFCF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSFCF_Callback(hObject, eventdata, handles)
function editSFCF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editK_Callback(hObject, eventdata, handles)
function editK_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editfilename_Callback(hObject, eventdata, handles)
function editfilename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editstop_Callback(hObject, eventdata, handles)
function editstop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
