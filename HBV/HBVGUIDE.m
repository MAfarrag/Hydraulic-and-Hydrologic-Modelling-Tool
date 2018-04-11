function varargout = HBVGUIDE(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HBVGUIDE_OpeningFcn, ...
                   'gui_OutputFcn',  @HBVGUIDE_OutputFcn, ...
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


function HBVGUIDE_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for HBVGUIDE
handles.output = hObject;
%% add pathes
addpath(genpath('Tank'));
addpath(genpath('FunctionsHBV'));
addpath(genpath('Montecarlo')); 
addpath(genpath('Data of catchments '));
%% preloading to both data & parameters in ordernto be able to
%% data----------------------------------------------------------------------
filename='Bagmati.mat'; % the GUI will preload the data from bagmati file 
axes(handles.axes1);
[handles.data]=readdata(filename,filename);
set(handles.editinputfile,'String',filename);  %write the name of the loaded file of the edit text
axes(handles.axes2);
plotQ(handles.data.Flow);
legend('Observed Data')
%% parameters----------------------------------------------------------------
filename='parameter.txt';   % the GUI will preload the parameters from the parameter file
[handles.par]=readparamf(filename);
set(handles.editparamfile,'String',filename); % write the file name on the edit text
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.par.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
%% Sliders----------------------------------------------------------------
% set the value of the sliders equal the value of the loaded parameters
for i=1:length(parameters)
    slider=['handles.slider' ,parameters{i}];
    value=['handles.par.',parameters{i}];
    set(eval(slider),'Value',eval(value));
end
%% Calibration-------------------------------------------------------------
set(handles.editcalib,'String',num2str(0.7)); % set the percentage 70 %
set(handles.editcalrun,'String',num2str(50)); % set the no of runs 50 runs
%%-------------------------------------------------------------------------
% set(handles.statusbar,'String','set of data and parameters has been preloaded')
% Update handles structure
guidata(hObject, handles);


function varargout = HBVGUIDE_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% input file name
function pushbutton1_Callback(hObject, eventdata, handles)
[filename,path] = uigetfile({'*.cal';'*.mat'},'File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
%get(handles.pushbutton1,'Value')
axes(handles.axes1);
[handles.data]=readdata(filename,path);
set(handles.editinputfile,'String',filename);  %write the name of the loaded file of the edit text
% set(handles.statusbar,'String','Input Data has been loaded successfully');

cla(handles.axes2)
axes(handles.axes2);
plotQ(handles.data.Flow);
cla(handles.axes3)
% Update handles structure
guidata(hObject, handles);

%% parameters file
function pushbutton2_Callback(hObject, eventdata, handles)
[filename,path] = uigetfile('*.txt','File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
set(handles.editparamfile,'String',filename); % write the file name on the edit text
[handles.par]=readparamf(path);
%% set the parameters at the textboxes
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.par.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
% set(handles.editTT,'String',num2str(handles.par.TT));
% set(handles.editTTI,'String',num2str(handles.par.TTI));
% set(handles.editTTM,'String',num2str(handles.par.TTM));
% set(handles.editCFMAX,'String',num2str(handles.par.CFMAX));
% set(handles.editFC,'String',num2str(handles.par.FC));
% set(handles.editECORR,'String',num2str(handles.par.ECORR));
% set(handles.editETF,'String',num2str(handles.par.ETF));
% set(handles.editLP,'String',num2str(handles.par.LP));
% set(handles.editK,'String',num2str(handles.par.K));
% set(handles.editK2,'String',num2str(handles.par.K1));
% set(handles.editALPHA,'String',num2str(handles.par.ALPHA));
% set(handles.editBETA,'String',num2str(handles.par.BETA));
% set(handles.editCWH,'String',num2str(handles.par.CWH));
% set(handles.editCFR,'String',num2str(handles.par.CFR));
% set(handles.editCFLUX,'String',num2str(handles.par.CFLUX));
% set(handles.editPERC,'String',num2str(handles.par.PERC));
% set(handles.editRFCF,'String',num2str(handles.par.RFCF));
% set(handles.editSFCF,'String',num2str(handles.par.SFCF));
% Update handles structure
guidata(hObject, handles);


%% calibration
function pushbutton3_Callback(hObject, eventdata, handles)
handles.per=str2double(get(handles.editcalib,'String'));
NC=round(str2double(get(handles.editcalrun,'String')));
%% 1-check 
if isnan(handles.per) || handles.per<0.5 ||  handles.per>0.8 % check on the precentage 
    msgbox('Please select a percentage between 0.5 & 0.7');
    return
elseif isnan(NC) || NC< 20 % check on the precentage
    msgbox('Please select a number of calibration Runs more than 20');
    return
end
%--------------------------------------------------------------------------
%% 2- reread the values of the parameters from the edit text as the user might
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
% 3- check on the values of the parameters
%--------------------------------------------------------------------------
%% 4- calibration process
% read the calibration function    Select calibration Function 
handles.per = round(handles.per*length(handles.data.Temp));
calib.prec = handles.data.Prec(1:handles.per);
calib.temp = handles.data.Temp(1:handles.per);
calib.Flow = handles.data.Flow(1:handles.per);
calib.ET = handles.data.Evap(1:handles.per);
calib.LTAT = mean(calib.temp)*ones(length(calib.Flow),1);
v = [calib.prec,calib.temp,calib.ET,calib.LTAT];    %v=[precipitation,temperature, potential evapotranspiration, daily mean temp]required variable matrix for the HBV code 
v(1,5)=handles.data.Area;
% to use it inside HBV_wrapper1 inside the godlike function in the calibration
h=[v(:,1:4),calib.Flow];                %csvwrite('temp.txt',[v,calib.Flow]);
h(1,6)=handles.data.Area;
% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    h(1,7)=1;
    timebases=h(1,7);
else
    h(1,7)=0;
    timebases=h(1,7);
end
save('v.mat','h');
%%  waiting bar
wait = waitbar(0,'please wait for comutation just listen ','Name','calculation process');
pause(3)
%% play a sound track
trackname='relax.wav';
[y,Fs] = audioread(trackname);
info = audioinfo(trackname);
t = 0:seconds(1/Fs):seconds(info.Duration);
t = t(1:end-1);
% plot the frequency of the sound waves
axes(handles.axes3);
plot(t,y)
xlabel('Time')
ylabel('Audio Signal')
drawnow
% play the track
player = audioplayer(y,Fs);
play(player);
% 5- preparing the data for calibration(length of the vectors)
LB = [-1,0,0,1,50,0.6,0,0,0,0,0,0,0.001,0.01,0,0,0.6,0.6]; % required for the godlike code wich is the calibration code
UB = [2,3,2,5,500,1.4,5,1,1,1,1,1.5,0.1,1,4,2,1.4,1.4];    % required for the godlike code wich is the calibration code
if get(handles.popupmenu1,'value')==1
    calib.param = GODLIKE(@HBV_WrapperNSE,NC,LB,UB);
elseif get(handles.popupmenu1,'value')==2
    calib.param = GODLIKE(@HBV_WrapperRMSE,NC,LB,UB);
elseif get(handles.popupmenu1,'value')==3
    calib.param = GODLIKE(@HBV_WrapperPBIAS,NC,LB,UB);
else
    calib.param = GODLIKE(@HBV_WrapperRSR,NC,LB,UB);
end
% stop the track
clear player
% delete the waiting bar
delete(wait)
%% 5- calculate the Discharge with the calibrated parameters
[calib.Error,calib.Qcal,ST]=HBV_Wrapper(calib.param,calib.Flow,v,timebases);
%% 6-calibrated panel (set the value of the calibrated parameters in the calibrated panel)
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i},'2'];
    set(eval(edittext),'String',round(calib.param(i),3));
end
%--------------------------------------------------------------------------
%% 7-edit text  (set the values of the calibrated parameters to the edit text)
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    set(eval(edittext),'String',round(calib.param(i),3));
end
%--------------------------------------------------------------------------
%% 8-sliders  (set the value of the calibated parameters into the sliders)
for i=1:length(parameters)
    slider=['handles.slider' ,parameters{i}];
    set(eval(slider),'Value',calib.param(i));
end
%--------------------------------------------------------------------------
%% 9-error  (set the values of the error)
set(handles.editNSE,'String',num2str(round(calib.Error(1),2)));
set(handles.editRMSE,'String',num2str(round(calib.Error(2),2)));
set(handles.editPBIAS,'String',num2str(round(calib.Error(3),2)));
set(handles.editRSR,'String',num2str(round(calib.Error(4),2)));
%--------------------------------------------------------------------------
%% 10- plot the discharge from calibrated parameters
axes(handles.axes2);
plotQ(calib.Qcal);
%legend('Observed Data','Calibrated Discharge')
%--------------------------------------------------------------------------
%% 11- plot the states
axes(handles.axes3);
plot(1:length(ST(:,1)),ST(:,2),1:length(ST(:,1)),ST(:,3),1:length(ST(:,1)),ST(:,4));
legend({'SM','UZ','LZ'},'FontSize',10,'Location','east');
title('HBV Model States');
xlabel('time(days)');
ylabel('storage(m3)');
%% 12- Validation

valid.prec = handles.data.Prec(handles.per+1:end);
valid.temp = handles.data.Temp(handles.per+1:end);
valid.Flow= handles.data.Flow(handles.per+1:end);
valid.ET= handles.data.Evap(handles.per+1:end);
valid.LTAT= mean(valid.temp)*ones(length(valid.Flow),1);
v2 = [valid.prec,valid.temp,valid.ET,valid.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v2(1,5)=handles.data.Area;
[valid.Error,valid.Qcal]=HBV_Wrapper(calib.param,valid.Flow,v2,timebases);
%% 13- plot
axes(handles.axes2);
plot(handles.per+1:length(handles.data.Temp),valid.Qcal(:,1),'LineWidth',1); % plotting water level
hold on
%title('HBVGUIDE Model Results')
%ylabel('Discharge m3/sec');
legend('Observed Data','Calibrated Discharge','Validated Discharge')
%--------------------------------------------------------------------------
% 14- set the values of the error
set(handles.edit28,'String',num2str(round(valid.Error(1),2)));
set(handles.edit29,'String',num2str(round(valid.Error(3),2)));
set(handles.edit30,'String',num2str(round(valid.Error(2),2)));
set(handles.edit31,'String',num2str(round(valid.Error(4),2)));
%--------------------------------------------------------------------------

handles.calib=calib;         % make it global to call ot in the slider
handles.timebases=timebases; % make it global to call ot in the slide

% Update handles structure
guidata(hObject, handles);


%% clear figure
function pushbutton6_Callback(hObject, eventdata, handles)
axes(handles.axes2)
cla(handles.axes2)
cla(handles.axes3)

%% close
function pushbutton8_Callback(hObject, eventdata, handles)
close(HBVGUIDE)

%% save figures
function pushbutton9_Callback(hObject, eventdata, handles)
[Filename,Pathname] = uiputfile({ '*.jpg'}, 'Save plots');
if Filename==0
    return;
else
    name=strsplit(Filename,'.');
str=strcat(Pathname,Filename);
im1=getframe(handles.axes1);
im=[im1.cdata];
str=strcat(Pathname,Filename);
imwrite(im,str)
im1=getframe(handles.axes2);
im=[im1.cdata];
str=strcat(Pathname,[name{1} '1.jpg']);
imwrite(im,str)
im1=getframe(handles.axes3);
im=[im1.cdata];
str=strcat(Pathname,[name{1} '2.jpg']);
imwrite(im,str)
end

%% calculate
function pushbutton10_Callback(hObject, eventdata, handles)
%% 2- reread the values of the parameters from the edit text as the user might
% has changed the values
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

%% save calibrated parameters
function pushbutton11_Callback(hObject, eventdata, handles)
% check if the calibration has been done or not
if isnan(str2double(get(handles.editSFCF2,'String'))) % read one of the edit text of the calibrated parameters if it is  empty send message 
    msgbox('Calibration process has not been done yet');
    return
end

[filename,path] = uiputfile({'*.mat';'*.txt'},'File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
calibratedparam=handles.calib.param;
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'};

format=strsplit(filename,'.');  % split the name from the format to know if it is .m or .cal
if format{2}== 'mat'
    save(path, 'calibratedparam')
else
    fid=fopen(path,'w'); % open to read the area of the catchment
    for i=1:length(calibratedparam)
    fprintf(fid,'%10.3f   %s',calibratedparam(i),parameters{i});
    fprintf(fid,'\n');
    end
    fclose(fid)
end


%% tank simulation
function pushbutton12_Callback(hObject, eventdata, handles)
Tank

%% monte carlo
function pushmontecarlo_Callback(hObject, eventdata, handles)
Montecarlo
%--------------------------------------------------------------------------

%% sliders
function sliderTT_Callback(hObject, eventdata, handles)
%set(handles.sliderTT,'Max',2.5,'Min',-2.5,'SliderStep',[0.01 0.01]);
set(handles.sliderTT,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editTT,'String',num2str(sliderval)) % put the value in the edit text
%handles.par.TT=get(handles.sliderTT,'Value');    % put the value in the variable itself
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end

% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderTT_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderTTI_Callback(hObject, eventdata, handles)
set(handles.sliderTTI,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editTTI,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end

%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderTTI_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderTTM_Callback(hObject, eventdata, handles)
set(handles.sliderTTM,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editTTM,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end

% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderTTM_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderCFMAX_Callback(hObject, eventdata, handles)
set(handles.sliderCFMAX,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editCFMAX,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end

%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderCFMAX_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderFC_Callback(hObject, eventdata, handles)
set(handles.sliderFC,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editFC,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end


% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderFC_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderECORR_Callback(hObject, eventdata, handles)
set(handles.sliderECORR,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editECORR,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end


% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderECORR_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderETF_Callback(hObject, eventdata, handles)
set(handles.sliderETF,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editETF,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end


%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderETF_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderLP_Callback(hObject, eventdata, handles)
set(handles.sliderLP,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editLP,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end


%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderLP_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderK_Callback(hObject, eventdata, handles)
set(handles.sliderK,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editK,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end

%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderK_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderK1_Callback(hObject, eventdata, handles)
set(handles.sliderK1,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editK2,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderK1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderALPHA_Callback(hObject, eventdata, handles)
set(handles.sliderALPHA,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editALPHA,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderALPHA_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderBETA_Callback(hObject, eventdata, handles)
set(handles.sliderBETA,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editBETA,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderBETA_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderCWH_Callback(hObject, eventdata, handles)
set(handles.sliderCWH,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editCWH,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderCWH_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderCFR_Callback(hObject, eventdata, handles)
set(handles.sliderCFR,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editCFR,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderCFR_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderCFLUX_Callback(hObject, eventdata, handles)
set(handles.sliderCFLUX,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editCFLUX,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderCFLUX_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderPERC_Callback(hObject, eventdata, handles)
set(handles.sliderPERC,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editPERC,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end

%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderPERC_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderRFCF_Callback(hObject, eventdata, handles)
set(handles.sliderRFCF,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editRFCF,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderRFCF_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function sliderSFCF_Callback(hObject, eventdata, handles)
set(handles.sliderSFCF,'SliderStep',[0.01 0.01]);
sliderval=get(hObject,'Value');
set(handles.editSFCF,'String',num2str(sliderval)) % put the value in the edit text
%% read all parameters again from the edit text & make a vector p
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    p(i)=str2double(value);  % values of the parameters as a vector for HBV_wrapper
    parr=['handles.par.',parameters{i}];
   eval([parr,'=', value] )
end
%% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are daily
    timebases=1;
else
    timebases=0;
end
%% calculate Q & error from HBV_wrapper
handles.data.LTAT= mean(handles.data.Temp)*ones(length(handles.data.Flow),1);
v = [handles.data.Prec,handles.data.Temp,handles.data.Evap,handles.data.LTAT];    %v=[precipitation,temperature, potential evapotranspiration,
v(1,5)=handles.data.Area;
[Error,Qcal]=HBV_Wrapper(p,handles.data.Flow,v,timebases);

% plot
axes(handles.axes2);
plotQ(Qcal);

function sliderSFCF_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





%% file name
function editinputfile_Callback(hObject, eventdata, handles)
function editinputfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% parameterfile
function editparamfile_Callback(hObject, eventdata, handles)
function editparamfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% parameters
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

function editCFMAX_Callback(hObject, eventdata, handles)
function editCFMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFC_Callback(hObject, eventdata, handles)
function editFC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editECORR_Callback(hObject, eventdata, handles)
function editECORR_CreateFcn(hObject, eventdata, handles)
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

function editK_Callback(hObject, eventdata, handles)
function editK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editK1_Callback(hObject, eventdata, handles)
function editK1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editALPHA_Callback(hObject, eventdata, handles)
function editALPHA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editBETA_Callback(hObject, eventdata, handles)
function editBETA_CreateFcn(hObject, eventdata, handles)
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




% function statusbar_Callback(hObject, eventdata, handles)
% function statusbar_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

function editcalib_Callback(hObject, eventdata, handles)
function editcalib_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editcalrun_Callback(hObject, eventdata, handles)
function editcalrun_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNSE_Callback(hObject, eventdata, handles)
function editNSE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPBIAS_Callback(hObject, eventdata, handles)
function editPBIAS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRMSE_Callback(hObject, eventdata, handles)
function editRMSE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRSR_Callback(hObject, eventdata, handles)
function editRSR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









function editTT2_Callback(hObject, eventdata, handles)
function editTT2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTTI2_Callback(hObject, eventdata, handles)
function editTTI2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTTM2_Callback(hObject, eventdata, handles)
function editTTM2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editK2_Callback(hObject, eventdata, handles)
function editK2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editK12_Callback(hObject, eventdata, handles)
function editK12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editBETA2_Callback(hObject, eventdata, handles)
function editBETA2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCFR2_Callback(hObject, eventdata, handles)
function editCFR2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editALPHA2_Callback(hObject, eventdata, handles)
function editALPHA2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editECORR2_Callback(hObject, eventdata, handles)
function editECORR2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFC2_Callback(hObject, eventdata, handles)
function editFC2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCFMAX2_Callback(hObject, eventdata, handles)
function editCFMAX2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editETF2_Callback(hObject, eventdata, handles)
function editETF2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editLP2_Callback(hObject, eventdata, handles)
function editLP2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCWH2_Callback(hObject, eventdata, handles)
function editCWH2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCFLUX2_Callback(hObject, eventdata, handles)
function editCFLUX2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPERC2_Callback(hObject, eventdata, handles)
function editPERC2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRFCF2_Callback(hObject, eventdata, handles)
function editRFCF2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSFCF2_Callback(hObject, eventdata, handles)
function editSFCF2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end














function edit28_Callback(hObject, eventdata, handles)
function edit28_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit29_Callback(hObject, eventdata, handles)
function edit29_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit30_Callback(hObject, eventdata, handles)
function edit30_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit31_Callback(hObject, eventdata, handles)
function edit31_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit52_Callback(hObject, eventdata, handles)
function edit52_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit53_Callback(hObject, eventdata, handles)
function edit53_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit54_Callback(hObject, eventdata, handles)
function edit54_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit55_Callback(hObject, eventdata, handles)
function edit55_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit56_Callback(hObject, eventdata, handles)
function edit56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit57_Callback(hObject, eventdata, handles)
function edit57_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit58_Callback(hObject, eventdata, handles)
function edit58_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit59_Callback(hObject, eventdata, handles)
function edit59_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit60_Callback(hObject, eventdata, handles)
function edit60_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit61_Callback(hObject, eventdata, handles)
function edit61_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit62_Callback(hObject, eventdata, handles)
function edit62_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit63_Callback(hObject, eventdata, handles)
function edit63_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit64_Callback(hObject, eventdata, handles)
function edit64_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit65_Callback(hObject, eventdata, handles)
function edit65_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit66_Callback(hObject, eventdata, handles)
function edit66_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit67_Callback(hObject, eventdata, handles)
function edit67_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit71_Callback(hObject, eventdata, handles)
function edit71_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit51_Callback(hObject, eventdata, handles)
function edit51_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function popupmenu1_Callback(hObject, eventdata, handles)
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
