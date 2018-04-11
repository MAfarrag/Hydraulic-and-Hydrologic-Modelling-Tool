function varargout = FSF(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FSF_OpeningFcn, ...
                   'gui_OutputFcn',  @FSF_OutputFcn, ...
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

function FSF_OpeningFcn(hObject, eventdata, handles, varargin)
%% add folders pathes
addpath(genpath('data'));
%% preloding data
[handles.inputs]=readimputs('Steady.txt');
%% set the parameters in the edittext
parameters={'b','c','s','L','dx','dt','maxiteration','maxt','theta','psi','beta'};
set(handles.editinputfile,'String','Steady.txt')
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.inputs.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
%% set the test case to steady
set(handles.poptest,'value',2)
%% preload the IC & BC
[handles.IC,handles.LBC,handles.RBC]=readICBC(handles.inputs.ICf,handles.inputs.LBCf,handles.inputs.RBCf);
%% validation of BC
%check if the BC is const or varing----------------------------------------
for i=2:length(handles.LBC.value)  % comparing each value with the previous value
    if handles.LBC.value(i,2)~= handles.LBC.value(i-1,2)
        handles.LBC.varing(i-1)=1;    % varing
    else
        handles.LBC.varing(i-1)=0;         % const
    end
end
for i=2:length(handles.RBC.value)
    if handles.RBC.value(i,2)~= handles.RBC.value(i-1,2)
        handles.RBC.varing(i-1)=1;
    else
        handles.RBC.varing(i-1)=0;
    end
end
% if at least there is one change it is varied
if sum(handles.LBC.varing)>0
    handles.LBC.varing='varied';
    set(handles.popus,'value',2)
else
    handles.LBC.varing='const';
    set(handles.popus,'value',1)
    set(handles.addrowus,'Enable','off') % disable the add row and erase row buttons
    set(handles.deleterowus,'Enable','off')
    handles.LBC.value=[handles.LBC.value(1,1),handles.LBC.value(1,2)];
end

if sum(handles.RBC.varing)>0
    handles.RBC.varing='varied';
    set(handles.popds,'value',2)
else
    handles.RBC.varing='const';
    set(handles.popds,'value',1)
    set(handles.addrowds,'Enable','off') % disable the add row and erase row buttons
    set(handles.deleterowds,'Enable','off')
    handles.RBC.value=[handles.RBC.value(1,1),handles.RBC.value(1,2)];
end
%% set the radio buttons of the BC units
if strcmp(handles.LBC.unit,'sec')
    set(handles.poptimeus,'value',1)
elseif strcmp(handles.LBC.unit,'min')     % LBC unit
    set(handles.poptimeus,'value',2)
elseif strcmp(handles.LBC.unit,'hours')     % LBC unit
    set(handles.poptimeus,'value',3)
elseif strcmp(handles.LBC.unit,'days')     % LBC unit
    set(handles.poptimeus,'value',4)
end
if strcmp(handles.RBC.unit,'sec')
    set(handles.poptimeds,'value',1)
elseif strcmp(handles.RBC.unit,'min')     % LBC unit
    set(handles.poptimeds,'value',2)
elseif strcmp(handles.RBC.unit,'hours')     % LBC unit
    set(handles.poptimeds,'value',3)
elseif strcmp(handles.RBC.unit,'days')     % LBC unit
    set(handles.poptimeds,'value',4)
end
%--------------------------------------------------------------------------
%% set the radio buttons like for the BC type
if handles.LBC.type=='h' % if LBC is h set the radio button of h
    %set(handles.radioUSH,'Enable','on');
    set(handles.radioUSH,'Value',1)
    set(handles.radioUSQ,'Value',0)
else
    set(handles.radioUSH,'Value',0)
    set(handles.radioUSQ,'Value',1)
end
if handles.RBC.type=='h' % if LBC is h set the radio button of h
    set(handles.radioDSH,'Value',1)
    set(handles.radioDSQ,'Value',0)
else
    set(handles.radioDSH,'Value',0)
    set(handles.radioDSQ,'Value',1)
end
%% setting the BC to the uitable
set(handles.uitableus,'Data',handles.LBC.value)
set(handles.uitableds,'Data',handles.RBC.value)
%check if the BC is const or varing----------------------------------------

if get(handles.popus,'value')==1 % LBC is const
handles.LBC.value(2,1)=1000;
handles.LBC.value(2,2)=handles.LBC.value(1,2);
else   % LBC is varied
    %check if it has more than one value or not
    [row cols]=size(handles.LBC.value);
    if row==1
        msgbox('please check the LBC table the tybe is varied so it should have more than one row, you can use the "+" or "-" buttons to edit the table');
        return
    end
     % check if the time column is increasing ----------------------------------------
     for i=2:length(handles.LBC.value)  % comparing each value with the previous value
         if handles.LBC.value(i,1)< handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, time column should be in ascending order you can use the "+" or "-" buttons to edit the table');
             return
         elseif handles.LBC.value(i,1)== handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
             return
         end
     end
 end
 
if get(handles.popds,'value')==1  % RBC is const
handles.RBC.value(2,1)=1000;
handles.RBC.value(2,2)=handles.RBC.value(1,2);
else
    %check if it has more than one value or not
    [row cols]=size(handles.RBC.value);
    if row==1
        msgbox('please check the LBC table the tybe is varied so it should have more than one row,you can use the "+" or "-" buttons to edit the table');
        return
    end
    % check if the time column is increasing ----------------------------------------
    for i=2:length(handles.RBC.value)
        if handles.RBC.value(i,1)< handles.RBC.value(i-1,1)
            msgbox('please check the Values of RBC, time column should in ascending order you can use the "+" or "-" buttons to edit the table');
            return
        elseif handles.RBC.value(i,1)== handles.RBC.value(i-1,1)
            msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
            return
        end
    end
end
%% recording a video
set(handles.checkboxH,'Value',1)
set(handles.checkboxQ,'Value',1)
set(handles.editpath,'string','FSF.avi')
handles.pathHvideo='FSFH.avi';
handles.pathQvideo='FSFQ.avi';
%% Formation of matrix Q & matrix H
%calculating no of discritization points
handles.inputs.X=round(handles.inputs.L/handles.inputs.dx)+1;
handles.inputs.T=round(handles.inputs.maxt*60*60/handles.inputs.dt)+1;
handles.Q=zeros(handles.inputs.T,handles.inputs.X);
handles.H=zeros(handles.inputs.T,handles.inputs.X);
%% interpolating the BC
[handles.LBC.interpolatedvalues]=BCinterp(handles.LBC,handles.inputs.dt,handles.inputs.T);
[handles.RBC.interpolatedvalues]=BCinterp(handles.RBC,handles.inputs.dt,handles.inputs.T);
%% plot the IC
distance=0:handles.inputs.dx:handles.inputs.L;
set(handles.edittime,'String',0);
axes(handles.axes1);
area(distance,handles.IC.H(1:handles.inputs.X),'FaceColor',[0 0.75 0.75])%,'lineWidth',2)
ylim([min(min(handles.IC.H))-2,max(max(handles.IC.H))+2]);  
ylabel('Water depth m')
xlabel('Distance m')
legend('IC','location','east' )
%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
% Q
axes(handles.axes2);
plot(distance,handles.IC.Q(1:handles.inputs.X),'lineWidth',2)
ylim([min(min(handles.IC.Q))-2,max(max(handles.IC.Q))+2])
legend('IC','location','east' )
ylabel('Discharge m3/sec')
xlabel('Distance m')
%% set the IC in the uitable
set(handles.uitableIC,'Data',[distance',handles.IC.H,handles.IC.Q])
% validation
if length(handles.IC.Q) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of Q at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
if length(handles.IC.H) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of H at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
%% plot the BC
timeseries=0:handles.inputs.dt:handles.inputs.maxt*60*60;
timeseries=round((timeseries/60/60),3);
axes(handles.axes3)
plot(handles.LBC.interpolatedvalues(2:end,1),timeseries(2:end),'LineWidth',2)
xlim([min(handles.LBC.interpolatedvalues)-1,max(handles.LBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('LBC')
ylabel('time (hrs)')
xlabel(handles.LBC.type)
axes(handles.axes4)
plot(handles.RBC.interpolatedvalues(2:end,1),timeseries(2:end),'LineWidth',2)
xlim([min(handles.RBC.interpolatedvalues)-1,max(handles.RBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('RBC')
ylabel('time (hrs)')
xlabel(handles.RBC.type)

%% variable that its value will increase if calculate button has been pressed 
handles.calculatevalidate=0;

% Choose default command line output for FSF
handles.output = hObject;


% Update handles structure
guidata(hObject,handles);

function varargout = FSF_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;




%% load input file
function pushbutton1_Callback(hObject, eventdata, handles)
[filename,path] = uigetfile({'*.txt'},'File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
[handles.inputs]=readimputs(filename);
%% set the parameters in the edittext
parameters={'b','c','s','L','dx','dt','maxiteration','maxt','theta','psi','beta'};
set(handles.editinputfile,'String',filename)
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.inputs.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
% Update handles structure
guidata(hObject,handles);

%% Run calculation
function RUN_Callback(hObject, eventdata, handles)
%% increase the validation variable
handles.calculatevalidate=handles.calculatevalidate+1;
%% reread parameters from the edit text
parameters={'b','c','s','L','dx','dt','maxiteration','maxt','theta','psi','beta'};
set(handles.editinputfile,'String','input.txt')
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=get(eval(edittext),'String');
    %value=['handles.inputs.',parameters{i}];
    parr=['handles.inputs.',parameters{i}];
   eval([parr,'=', value] )
end
%% reread the BC
% tybe of the LBC
if get(handles.radioUSQ,'Value')==1  % LBC
    handles.LBC.type='Q';
else
    handles.LBC.type='h';
end
% tybe of the RBC
if get(handles.radioDSQ,'Value')==1 
    handles.RBC.type='Q';
else
    handles.RBC.type='h';
end
%% Unit of the LBC
if get(handles.poptimeus,'value')==1
    handles.LBC.unit='sec';
elseif get(handles.poptimeus,'value')==2     
    handles.LBC.unit='min';
elseif get(handles.poptimeus,'value')==3
    handles.LBC.unit='hours';
elseif get(handles.poptimeus,'value')==4
    handles.LBC.unit='days';
end
if get(handles.poptimeds,'value')==1
    handles.RBC.unit='sec';
elseif get(handles.poptimeds,'value')==2     
    handles.RBC.unit='min';
elseif get(handles.poptimeds,'value')==3
    handles.RBC.unit='hours';
elseif get(handles.poptimeds,'value')==4
    handles.RBC.unit='days';
end
%% values of BC
handles.LBC.value=get(handles.uitableus,'Data');
handles.RBC.value=get(handles.uitableds,'Data');
% check maybe the user want to play and deleted all the BC 
if isempty(handles.LBC.value)
    m1=msgbox('please check the LBC table you might have deleted all the values');
    pause(4)
    delete(m1)
    m1=msgbox('is this case you have a free time & so check this out');
    pause(4)
    delete(m1)
    [s,website]=web('https://www.youtube.com/watch?v=UCqOkUBaWqQ');
    pause(50)
    close(website)
    return
end
if isempty(handles.RBC.value)
    m1=msgbox('please check the RBC table you might have deleted all the values');
    pause(4)
    delete(m1)
    m1=msgbox('is this case you have a free time & so check this out');
    pause(4)
    delete(m1)
    [s,website]=web('https://www.youtube.com/watch?v=UCqOkUBaWqQ');
    pause(50)
    close(website)
    return
end
%check if the BC is const or varing----------------------------------------

if get(handles.popus,'value')==1 % LBC is const
handles.LBC.value(2,1)=1000;
handles.LBC.value(2,2)=handles.LBC.value(1,2);
else   % LBC is varied
    %check if it has more than one value or not
    [row cols]=size(handles.LBC.value);
    if row==1
        msgbox('please check the LBC table the type is varied so it should have more than one row, you can use the "+" or "-" buttons to edit the table');
        return
    end
    % check if the time column is increasing ----------------------------------------
     for i=2:length(handles.LBC.value)  % comparing each value with the previous value
         if handles.LBC.value(i,1)< handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, time column should be in ascending order you can use the "+" or "-" buttons to edit the table');
             return
         elseif handles.LBC.value(i,1)== handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
             return
         end
     end
 end
 
if get(handles.popds,'value')==1  % RBC is const
handles.RBC.value(2,1)=1000;
handles.RBC.value(2,2)=handles.RBC.value(1,2);
else
    %check if it has more than one value or not
    [row cols]=size(handles.RBC.value);
    if row==1
        msgbox('please check the RBC table the tybe is varied so it should have more than one row,you can use the "+" or "-" buttons to edit the table');
        return
    end
    % check if the time column is increasing ----------------------------------------
    for i=2:length(handles.RBC.value)
        if handles.RBC.value(i,1)< handles.RBC.value(i-1,1)
            msgbox('please check the Values of RBC, time column should in ascending order you can use the "+" or "-" buttons to edit the table');
            return
        elseif handles.RBC.value(i,1)== handles.RBC.value(i-1,1)
            msgbox('please check the Values of RBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
            return
        end
    end
end
%% Formation of matrix Q & matrix H
%calculating no of discritization points
handles.inputs.X=round(handles.inputs.L/handles.inputs.dx)+1;
handles.inputs.T=round(handles.inputs.maxt*60*60/handles.inputs.dt)+1;
handles.Q=zeros(handles.inputs.T,handles.inputs.X);
handles.H=zeros(handles.inputs.T,handles.inputs.X);
%% interpolating the BC
[handles.LBC.interpolatedvalues]=BCinterp(handles.LBC,handles.inputs.dt,handles.inputs.T);
[handles.RBC.interpolatedvalues]=BCinterp(handles.RBC,handles.inputs.dt,handles.inputs.T);
%% IC
temp=get(handles.uitableIC,'Data'); %handles.IC.Q
handles.IC.H=temp(:,2);
handles.IC.Q=temp(:,3);
% validation
if length(handles.IC.Q) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of Q at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
if length(handles.IC.H) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of H at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
handles.Q(1,:)=handles.IC.Q(1:length(handles.Q(1,:)),1)'; % you have to input values more than or equal the no of points 
handles.H(1,:)=handles.IC.H(1:length(handles.Q(1,:)),1);
%% preissmann
[handles.Q,handles.H]=preissmann(handles.inputs,handles.Q,handles.H,handles.LBC,handles.RBC);
%% plot the LBC
timeseries=0:handles.inputs.dt:handles.inputs.maxt*60*60;
timeseries=round((timeseries/60/60),3);
axes(handles.axes3)
plot(handles.LBC.interpolatedvalues(:,1),timeseries,'LineWidth',2)
xlim([min(handles.LBC.interpolatedvalues)-1,max(handles.LBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('LBC')
ylabel('time (hrs)')
xlabel(handles.LBC.type)
axes(handles.axes4)
plot(handles.RBC.interpolatedvalues(:,1),timeseries,'LineWidth',2)
xlim([min(handles.RBC.interpolatedvalues)-1,max(handles.RBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('RBC')
ylabel('time (hrs)')
xlabel(handles.RBC.type)

%% stability condition
R=(handles.IC.H(1,1)*handles.inputs.b/(handles.inputs.b+2*handles.IC.H(1,1)));
u=handles.inputs.c*sqrt(handles.inputs.s*R);
coeff=((handles.inputs.psi-0.5)/((u+sqrt(9.81*handles.IC.H(1,1)))*(handles.inputs.dx/handles.inputs.dx)))+(handles.inputs.theta-0.5);
if coeff >=0
    stability=' stable';
else
    stability=' unstable';
end
set(handles.editstability,'string',[num2str(round(coeff,2)) stability])
% Update handles structure
guidata(hObject,handles);


%% add row us 
function addrowus_Callback(hObject, eventdata, handles)
%set(handles.uitableus,'Data',handles.IC.Q)
data = get(handles.uitableus,'Data');
data(end+1,:)=0;
set(handles.uitableus,'Data',data)
% Update handles structure
guidata(hObject,handles);

%% add row ds 
function addrowds_Callback(hObject, eventdata, handles)
data = get(handles.uitableds,'Data');
data(end+1,:)=0;
set(handles.uitableds,'Data',data)
% Update handles structure
guidata(hObject,handles);

%% delete row us 
function deleterowus_Callback(hObject, eventdata, handles)
data = get(handles.uitableus,'Data');
data=data(1:end-1,:);
set(handles.uitableus,'Data',data)
% Update handles structure
guidata(hObject,handles);

%% delete row ds 
function deleterowds_Callback(hObject, eventdata, handles)
data = get(handles.uitableds,'Data');
data=data(1:end-1,:);
set(handles.uitableds,'Data',data)
% Update handles structure
guidata(hObject,handles);

%% plot
function plot_Callback(hObject, eventdata, handles)
%% validation
if handles.calculatevalidate== 0
    msgbox('please press Run first');
    return
end
%% Y limit
YlimH(1,1)=str2double(get(handles.editylimHup, 'String' ));
YlimH(1,2)=str2double(get(handles.editylimHdown, 'String' ));

YlimQ(1,1)=str2double(get(handles.editylimQup, 'String' ));
YlimQ(1,2)=str2double(get(handles.editylimQdown, 'String' ));

if isnan(YlimH(1,1))  
    YlimH(1,1)=min(min(handles.H))-2;
end
if isnan(YlimH(1,2))
    YlimH(1,2)=max(max(handles.H))+2;
end
if isnan(YlimQ(1,1))
    YlimQ(1,1)=min(min(handles.Q))-2;
end
if isnan(YlimQ(1,2))
    YlimQ(1,2)=max(max(handles.Q))+2;
end
%%
set(handles.editstop,'String',0) % related to stopping the plotting 
%% recording a video
distance=0:handles.inputs.dx:handles.inputs.L;
for t=1:1:handles.inputs.T             %length(timesereis)
    %set(handles.editTime,'value',round((t-1)*dt/60))
    time=round((t-1)*handles.inputs.dt/60);
    set(handles.edittime,'String',time); % counter for time in min
    %-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
    % H
    axes(handles.axes1);
    area(distance,handles.H(t,:),'FaceColor',[0 0.75 0.75])%,'lineWidth',2)
    ylim([YlimH(1,1),YlimH(1,2)]) %ylim([min(min(handles.H)),max(max(handles.H))]);  
    %title(['Transient Test Variation of depth with distance editTime = ' num2str(round((t-1)*dt/60),3) ' min'])
    ylabel('Water depth m')
    xlabel('Distance m')
    %legend('transient Test','location','eastoutside' )
    %-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
    % Q
    axes(handles.axes2);
    plot(distance,handles.Q(t,:),'lineWidth',2)
    ylim([YlimQ(1,1) YlimQ(1,2)]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]); 
    %title(['Transient Test Variation of Discharge with distance  editTime = ' num2str(round((t-1)*dt/60),3) ' min'])
    ylabel('Discharge m3/sec')
    xlabel('Distance m')
    %legend('transient Test','location','eastoutside' )
    pause(0.01)
    %% check if the user want to record a video
    if get(handles.checkboxH,'Value') == 1
        hvideo(t) = getframe(handles.axes1);
    end
    if get(handles.checkboxQ,'Value')==1
        Qvideo(t) = getframe(handles.axes2);
    end
    %% check if the user want to stop plotting
    if str2double(get(handles.editstop,'String'))==1
        break
    end
end
%%-------------------------------------------------------------------------
%% writting the video
if str2double(get(handles.editstop,'String'))==0 % wite the video only if the user did not press stop
    %H video
    if get(handles.checkboxH,'Value') == 1
        v = VideoWriter(handles.pathHvideo,'Motion JPEG AVI');
        open(v)
        writeVideo(v,hvideo)
        close(v)
    end
    %%-------------------------------------------------------------------------
    %Q video
    if get(handles.checkboxQ,'Value')==1
        w = VideoWriter(handles.pathQvideo,'Motion JPEG AVI');
        open(w)
        writeVideo(w,Qvideo)
        close(w)
    end
 end
% Update handles structure
guidata(hObject,handles);

%% stop plooting
function pushbuttonstop_Callback(hObject, eventdata, handles)
set(handles.editstop,'String',1)
%handles.stop=1;
% Update handles structure
guidata(hObject,handles);

%% save result
function pushbuttonsave_Callback(hObject, eventdata, handles)
[filename,path] = uiputfile({'*.txt'},'File Selector','Select the input file');
if (filename~=0)
    filename=strsplit(filename,'.');
    path1=[path filename{1} 'Q.txt']; % full path with the name
    path2=[path filename{1} 'H.txt']; % full path with the name
else
   return
end
%% open a file to store the values of Q,H every time step
fidQ=fopen(path1,'wt');
fidH=fopen(path2,'wt');
for t=1:handles.inputs.T
    fprintf(fidQ,'%15.3f',handles.Q(t,:));
    fprintf(fidQ,'\n');
    fprintf(fidH,'%15.3f',handles.H(t,:));
    fprintf(fidH,'\n');
end
fclose(fidQ);
fclose(fidH);

%% clear figures
function pushbuttonclearfigures_Callback(hObject, eventdata, handles)
cla(handles.axes1)
cla(handles.axes2)
set(handles.edittime,'String',0)

%% video path
function pushpath_Callback(hObject, eventdata, handles)
[filename,path] = uiputfile({'*.avi'},'File Selector','Select a name');
set(handles.editpath,'String',filename)
if (filename~=0)
    filename=strsplit(filename,'.');
    handles.pathQvideo=[path filename{1} 'Q.avi']; % full path with the name
    handles.pathHvideo=[path filename{1} 'H.avi']; % full path with the name
else
   return
end
% Update handles structure
guidata(hObject,handles);

%% plot LBC
function pushplotLBC_Callback(hObject, eventdata, handles)
%% reread the BC
% tybe of the LBC
if get(handles.radioUSQ,'Value')==1  % LBC
    handles.LBC.type='Q';
else
    handles.LBC.type='h';
end
%% Unit of the LBC
if get(handles.poptimeus,'value')==1
    handles.LBC.unit='sec';
elseif get(handles.poptimeus,'value')==2     
    handles.LBC.unit='min';
elseif get(handles.poptimeus,'value')==3
    handles.LBC.unit='hours';
elseif get(handles.poptimeus,'value')==4
    handles.LBC.unit='days';
end
%% values of BC
handles.LBC.value=get(handles.uitableus,'Data');
% check maybe the user want to play and deleted all the BC 
if isempty(handles.LBC.value)
    m1=msgbox('please check the LBC table you might have deleted all the values');
    pause(4)
    delete(m1)
    m1=msgbox('is this case youhave a free time & you are playing so check this out');
    pause(4)
    delete(m1)
    [s,website]=web('https://www.youtube.com/watch?v=UCqOkUBaWqQ');
    pause(50)
    close(website)
    return
end
%check if the BC is const or varing----------------------------------------

if get(handles.popus,'value')==1 % LBC is const
handles.LBC.value(2,1)=1000;
handles.LBC.value(2,2)=handles.LBC.value(1,2);
else   % LBC is varied
    %check if it has more than one value or not
    [row cols]=size(handles.LBC.value);
    if row==1
        msgbox('please check the LBC table the tybe is varied so it should have more than one row, you can use the "+" or "-" buttons to edit the table');
        return
    end
     % check if the time column is increasing ----------------------------------------
     for i=2:length(handles.LBC.value)  % comparing each value with the previous value
         if handles.LBC.value(i,1)< handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, time column should be in ascending order you can use the "+" or "-" buttons to edit the table');
             return
         elseif handles.LBC.value(i,1)== handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
             return
         end
     end
end
%% Formation of matrix Q & matrix H
%calculating no of discritization points
handles.inputs.X=round(handles.inputs.L/handles.inputs.dx)+1;
handles.inputs.T=round(handles.inputs.maxt*60*60/handles.inputs.dt)+1;
%% interpolating the BC
[handles.LBC.interpolatedvalues]=BCinterp(handles.LBC,handles.inputs.dt,handles.inputs.T);
%% plot the LBC
timeseries=0:handles.inputs.dt:handles.inputs.maxt*60*60;
timeseries=round((timeseries/60/60),3);
axes(handles.axes3)
plot(handles.LBC.interpolatedvalues(:,1),timeseries,'LineWidth',2)
xlim([min(handles.LBC.interpolatedvalues)-1,max(handles.LBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('LBC')
ylabel('time (hrs)')
xlabel(handles.LBC.type)

%% plot RBC
function pushplotRBC_Callback(hObject, eventdata, handles)
%% reread the BC
% tybe of the RBC
if get(handles.radioDSQ,'Value')==1 
    handles.RBC.type='Q';
else
    handles.RBC.type='h';
end
%% Unit of the RBC
if get(handles.poptimeds,'value')==1
    handles.RBC.unit='sec';
elseif get(handles.poptimeds,'value')==2     
    handles.RBC.unit='min';
elseif get(handles.poptimeds,'value')==3
    handles.RBC.unit='hours';
elseif get(handles.poptimeds,'value')==4
    handles.RBC.unit='days';
end
%% values of BC
handles.RBC.value=get(handles.uitableds,'Data');
% check maybe the user want to play and deleted all the BC 
if isempty(handles.RBC.value)
    m1=msgbox('please check the RBC table you might have deleted all the values');
    pause(4)
    delete(m1)
    m1=msgbox('is this case youhave a free time & you are playing so check this out');
    pause(4)
    delete(m1)
    [s,website]=web('https://www.youtube.com/watch?v=UCqOkUBaWqQ');
    pause(50)
    close(website)
    return
end
%check if the BC is const or varing----------------------------------------
if get(handles.popds,'value')==1  % RBC is const
handles.RBC.value(2,1)=1000;
handles.RBC.value(2,2)=handles.RBC.value(1,2);
else
    %check if it has more than one value or not
    [row cols]=size(handles.RBC.value);
    if row==1
        msgbox('please check the LBC table the tybe is varied so it should have more than one row,you can use the "+" or "-" buttons to edit the table');
        return
    end
    % check if the time column is increasing ----------------------------------------
    for i=2:length(handles.RBC.value)
        if handles.RBC.value(i,1)< handles.RBC.value(i-1,1)
            msgbox('please check the Values of RBC, time column should in ascending order you can use the "+" or "-" buttons to edit the table');
            return
        elseif handles.RBC.value(i,1)== handles.RBC.value(i-1,1)
            msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
            return
        end
    end
end
%% Formation of matrix Q & matrix H
%calculating no of discritization points
handles.inputs.X=round(handles.inputs.L/handles.inputs.dx)+1;
handles.inputs.T=round(handles.inputs.maxt*60*60/handles.inputs.dt)+1;
%% interpolating the BC
[handles.RBC.interpolatedvalues]=BCinterp(handles.RBC,handles.inputs.dt,handles.inputs.T);
%% plot the LBC
timeseries=0:handles.inputs.dt:handles.inputs.maxt*60*60;
timeseries=round((timeseries/60/60),3);
axes(handles.axes4)
plot(handles.RBC.interpolatedvalues(:,1),timeseries,'LineWidth',2)
xlim([min(handles.RBC.interpolatedvalues)-1,max(handles.RBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('RBC')
ylabel('time (hrs)')
xlabel(handles.RBC.type)

%% add row IC
function addrowic_Callback(hObject, eventdata, handles)
data = get(handles.uitableIC,'Data');
handles.inputs.dx=str2double(get(handles.editdx,'String'));
data(end+1,1)=data(end,1)+handles.inputs.dx;
%data(end+1,:)=0;
set(handles.uitableIC,'Data',data)
% Update handles structure
guidata(hObject,handles);

%% delete row IC
function deleterowic_Callback(hObject, eventdata, handles)
data = get(handles.uitableIC,'Data');
data=data(1:end-1,:);
set(handles.uitableIC,'Data',data)
% Update handles structure
guidata(hObject,handles);

%% plot IC
function pushplotIC_Callback(hObject, eventdata, handles)
%% validation
handles.inputs.L=str2double(get(handles.editL,'String'));
handles.inputs.dx=str2double(get(handles.editdx,'String'));
handles.inputs.X=round(handles.inputs.L/handles.inputs.dx)+1;
temp=get(handles.uitableIC,'Data'); %handles.IC.Q
handles.IC.H=temp(:,2);
handles.IC.Q=temp(:,3);
% validation
if length(handles.IC.Q) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of Q at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
if length(handles.IC.H) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of H at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
%% plot the IC
% axes(handles.axes1)
% cla(handles.axes1)
% axes(handles.axes2)
% cla(handles.axes2)
distance=0:handles.inputs.dx:handles.inputs.L;
set(handles.edittime,'String',0);
axes(handles.axes1);
area(distance,handles.IC.H(1:handles.inputs.X),'FaceColor',[0 0.75 0.75])%,'lineWidth',2)
ylim([min(min(handles.IC.H))-2,max(max(handles.IC.H))+2])
ylabel('Water depth m')
legend('IC','location','east' )
%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
% Q
axes(handles.axes2);
plot(distance,handles.IC.Q(1:handles.inputs.X),'lineWidth',2)
ylim([min(min(handles.IC.Q))-2,max(max(handles.IC.Q))+2])
legend('IC','location','east' )
ylabel('Discharge m3/sec')
xlabel('Distance m')

%% ref
function pushref_Callback(hObject, eventdata, handles)
open('STABILITY OF A GENERAL PREISSMANN SCHEME.pdf')

%% save figures
function pushsavefig_Callback(hObject, eventdata, handles)
[filename,path] = uiputfile({'*.jpg'},'File Selector','Define Figure Output');
if (filename~=0)
    path=[path filename]; % full path with the name
else
    return
end
filename=strsplit(filename,'.');
path1=[path filename{1} 'H.jpg']; % full path with the name
path2=[path filename{1} 'Q.jpg']; % full path with the name
path3=[path filename{1} 'LBC.jpg']; % full path with the name
path4=[path filename{1} 'RBC.jpg']; % full path with the name
%H
im1=getframe(handles.axes1);
im1=[im1.cdata];
imwrite(im1,path1)
%Q
im1=getframe(handles.axes2);
im1=[im1.cdata];
imwrite(im1,path2)
%LBC
im1=getframe(handles.axes3);
im1=[im1.cdata];
imwrite(im1,path3)
% RBC
im1=getframe(handles.axes4);
im1=[im1.cdata];
imwrite(im1,path4)

%% close
function pushbutton3_Callback(hObject, eventdata, handles)
close(FSF)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% select case
function poptest_Callback(hObject, eventdata, handles)
%% empty the stability text
set(handles.editstability,'String','')
%% determin which case did the user selected 
if get(handles.poptest,'value')==1
    filename='static.txt';
elseif get(handles.poptest,'value')==2
    filename='Steady.txt';
elseif get(handles.poptest,'value')==3
    filename='transientconst.txt';
elseif get(handles.poptest,'value')==4
    filename='transientvaried.txt';
end
%% read inputs parameters from file
[handles.inputs]=readimputs(filename);% the values are also updated in the handles
%% set the parameters in the edittext
parameters={'b','c','s','L','dx','dt','maxiteration','maxt','theta','psi','beta'};
set(handles.editinputfile,'String',filename)
for i=1:length(parameters)
    edittext=['handles.edit' ,parameters{i}];
    value=['handles.inputs.',parameters{i}];
    set(eval(edittext),'String',eval(value));
end
%% read the IC & BC from the file
[handles.IC,handles.LBC,handles.RBC]=readICBC(handles.inputs.ICf,handles.inputs.LBCf,handles.inputs.RBCf);
%% validation of BC
%check if the BC is const or varing----------------------------------------
for i=2:length(handles.LBC.value)  % comparing each value with the previous value
    if handles.LBC.value(i,2)~= handles.LBC.value(i-1,2)
        handles.LBC.varing(i-1)=1;    % varing
    else
        handles.LBC.varing(i-1)=0;         % const
    end
end
for i=2:length(handles.RBC.value)
    if handles.RBC.value(i,2)~= handles.RBC.value(i-1,2)
        handles.RBC.varing(i-1)=1;
    else
        handles.RBC.varing(i-1)=0;
    end
end
% if at least there is one change it is varied
if sum(handles.LBC.varing)>0
    handles.LBC.varing='varied';
    set(handles.popus,'value',2)
else
    handles.LBC.varing='const';
    set(handles.popus,'value',1)
    set(handles.addrowus,'Enable','off') % disable the add row and erase row buttons
    set(handles.deleterowus,'Enable','off')
    handles.LBC.value=[handles.LBC.value(1,1),handles.LBC.value(1,2)];
end

if sum(handles.RBC.varing)>0
    handles.RBC.varing='varied';
    set(handles.popds,'value',2)
else
    handles.RBC.varing='const';
    set(handles.popds,'value',1)
    set(handles.addrowds,'Enable','off') % disable the add row and erase row buttons
    set(handles.deleterowds,'Enable','off')
    handles.RBC.value=[handles.RBC.value(1,1),handles.RBC.value(1,2)];
end
%% set the popupmenu of the BC units
if strcmp(handles.LBC.unit,'sec')
    set(handles.poptimeus,'value',1)
elseif strcmp(handles.LBC.unit,'min')     % LBC unit
    set(handles.poptimeus,'value',2)
elseif strcmp(handles.LBC.unit,'hours')     % LBC unit
    set(handles.poptimeus,'value',3)
elseif strcmp(handles.LBC.unit,'days')     % LBC unit
    set(handles.poptimeus,'value',4)
end
if strcmp(handles.RBC.unit,'sec')
    set(handles.poptimeds,'value',1)
elseif strcmp(handles.RBC.unit,'min')     % LBC unit
    set(handles.poptimeds,'value',2)
elseif strcmp(handles.RBC.unit,'hours')     % LBC unit
    set(handles.poptimeds,'value',3)
elseif strcmp(handles.RBC.unit,'days')     % LBC unit
    set(handles.poptimeds,'value',4)
end
%--------------------------------------------------------------------------
%% set the radio buttons like for the BC type
if handles.LBC.type=='h' % if LBC is h set the radio button of h
    set(handles.radioUSH,'Value',1)
    set(handles.radioUSQ,'Value',0)
else
    set(handles.radioUSH,'Value',0)
    set(handles.radioUSQ,'Value',1)
end
if handles.RBC.type=='h' % if LBC is h set the radio button of h
    set(handles.radioDSH,'Value',1)
    set(handles.radioDSQ,'Value',0)
else
    set(handles.radioDSH,'Value',0)
    set(handles.radioDSQ,'Value',1)
end
%% setting the BC to the uitable
set(handles.uitableus,'Data',handles.LBC.value)
set(handles.uitableds,'Data',handles.RBC.value)

%check if the BC is const or varing----------------------------------------

if get(handles.popus,'value')==1 % LBC is const
handles.LBC.value(2,1)=1000;
handles.LBC.value(2,2)=handles.LBC.value(1,2);
else   % LBC is varied
    %check if it has more than one value or not
    [row cols]=size(handles.LBC.value);
    if row==1
        msgbox('please check the LBC table the tybe is varied so it should have more than one row, you can use the "+" or "-" buttons to edit the table');
        return
    end
     % check if the time column is increasing ----------------------------------------
     for i=2:length(handles.LBC.value)  % comparing each value with the previous value
         if handles.LBC.value(i,1)< handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, time column should be in ascending order you can use the "+" or "-" buttons to edit the table');
             return
         elseif handles.LBC.value(i,1)== handles.LBC.value(i-1,1)
             msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
             return
         end
     end
 end
 
if get(handles.popds,'value')==1  % RBC is const
handles.RBC.value(2,1)=1000;
handles.RBC.value(2,2)=handles.RBC.value(1,2);
else
    %check if it has more than one value or not
    [row cols]=size(handles.RBC.value);
    if row==1
        msgbox('please check the LBC table the tybe is varied so it should have more than one row,you can use the "+" or "-" buttons to edit the table');
        return
    end
    % check if the time column is increasing ----------------------------------------
    for i=2:length(handles.RBC.value)
        if handles.RBC.value(i,1)< handles.RBC.value(i-1,1)
            msgbox('please check the Values of RBC, time column should in ascending order you can use the "+" or "-" buttons to edit the table');
            return
        elseif handles.RBC.value(i,1)== handles.RBC.value(i-1,1)
            msgbox('please check the Values of LBC, there is one time that has two values you can use the "+" or "-" buttons to edit the table');
            return
        end
    end
end


%% Formation of matrix Q & matrix H
%calculating no of discritization points
handles.inputs.X=round(handles.inputs.L/handles.inputs.dx)+1;
handles.inputs.T=round(handles.inputs.maxt*60*60/handles.inputs.dt)+1;
handles.Q=zeros(handles.inputs.T,handles.inputs.X);
handles.H=zeros(handles.inputs.T,handles.inputs.X);
%% plot the IC
distance=0:handles.inputs.dx:handles.inputs.L;
set(handles.edittime,'String',0);
axes(handles.axes1);
area(distance,handles.IC.H(1:handles.inputs.X),'FaceColor',[0 0.75 0.75])%,'lineWidth',2)
ylim([min(min(handles.IC.H))-2,max(max(handles.IC.H))+2])
ylabel('Water depth m')
legend('IC','location','east' )
%-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
% Q
axes(handles.axes2);
plot(distance,handles.IC.Q(1:handles.inputs.X),'lineWidth',2)
ylim([min(min(handles.IC.Q))-2,max(max(handles.IC.Q))+2])
ylabel('Discharge m3/sec')
xlabel('Distance m')
legend('IC','location','east' )
%% set the IC in the uitable
set(handles.uitableIC,'Data',[distance',handles.IC.H,handles.IC.Q])
% validation
if length(handles.IC.Q) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of Q at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
if length(handles.IC.H) < handles.inputs.X
     msgbox(['please check the IC you have to enter the value of H at' num2str(handles.inputs.X) ' point along the channel']);
    return
end
%% interpolating the BC
[handles.LBC.interpolatedvalues]=BCinterp(handles.LBC,handles.inputs.dt,handles.inputs.T);
[handles.RBC.interpolatedvalues]=BCinterp(handles.RBC,handles.inputs.dt,handles.inputs.T);

%% plot the LBC
timeseries=0:handles.inputs.dt:handles.inputs.maxt*60*60;
timeseries=round((timeseries/60/60),3);
axes(handles.axes3)
plot(handles.LBC.interpolatedvalues(:,1),timeseries,'LineWidth',2)
xlim([min(handles.LBC.interpolatedvalues)-1,max(handles.LBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('LBC')
ylabel('time (hrs)')
xlabel(handles.LBC.type)
axes(handles.axes4)
plot(handles.RBC.interpolatedvalues(:,1),timeseries,'LineWidth',2)
xlim([min(handles.RBC.interpolatedvalues)-1,max(handles.RBC.interpolatedvalues)+1]) %ylim([min(min(handles.Q)),max(max(handles.Q))]); %ylim([-2,2]);
title('RBC')
ylabel('time (hrs)')
xlabel(handles.RBC.type)
% Update handles structure
guidata(hObject,handles);

function poptest_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkboxH_Callback(hObject, eventdata, handles)

function checkboxQ_Callback(hObject, eventdata, handles)

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function radioUSQ_Callback(hObject, eventdata, handles)
set(handles.radioUSQ,'Value',1)% if i pressed on Q make h unselected 
set(handles.radioUSH,'Value',0)% inorder not to select both at the same time
function radioDSQ_Callback(hObject, eventdata, handles)
set(handles.radioDSQ,'Value',1)
set(handles.radioDSH,'Value',0)
function radioUSH_Callback(hObject, eventdata, handles)
set(handles.radioUSH,'Value',1)
set(handles.radioUSQ,'Value',0)
function radioDSH_Callback(hObject, eventdata, handles)
set(handles.radioDSH,'Value',1)
set(handles.radioDSQ,'Value',0)

function radioushours_Callback(hObject, eventdata, handles)
set(handles.radioushours,'Value',1)
set(handles.radiousminutes,'Value',0)
function radiousminutes_Callback(hObject, eventdata, handles)
set(handles.radioushours,'Value',0)
set(handles.radiousminutes,'Value',1)



%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function editinputfile_Callback(hObject, eventdata, handles)
function editinputfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit13_Callback(hObject, eventdata, handles)
function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editb_Callback(hObject, eventdata, handles)
function editb_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editc_Callback(hObject, eventdata, handles)
function editc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edits_Callback(hObject, eventdata, handles)
function edits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editL_Callback(hObject, eventdata, handles)
function editL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editdx_Callback(hObject, eventdata, handles)
function editdx_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editdt_Callback(hObject, eventdata, handles)
function editdt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editmaxiteration_Callback(hObject, eventdata, handles)
function editmaxiteration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editmaxt_Callback(hObject, eventdata, handles)
function editmaxt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittheta_Callback(hObject, eventdata, handles)
function edittheta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editpsi_Callback(hObject, eventdata, handles)
function editpsi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editbeta_Callback(hObject, eventdata, handles)
function editbeta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit26_Callback(hObject, eventdata, handles)
function edit26_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit27_Callback(hObject, eventdata, handles)
function edit27_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit28_Callback(hObject, eventdata, handles)
function edit28_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editBCUS_Callback(hObject, eventdata, handles)
function editBCUS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editBCDS_Callback(hObject, eventdata, handles)
function editBCDS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit31_Callback(hObject, eventdata, handles)
function edit31_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit32_Callback(hObject, eventdata, handles)
function edit32_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittime_Callback(hObject, eventdata, handles)
function edittime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editstop_Callback(hObject, eventdata, handles)
function editstop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editpath_Callback(hObject, eventdata, handles)
function editpath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editylimHup_Callback(hObject, eventdata, handles)
function editylimHup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editylimQup_Callback(hObject, eventdata, handles)
function editylimQup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editylimHdown_Callback(hObject, eventdata, handles)
function editylimHdown_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editylimQdown_Callback(hObject, eventdata, handles)
function editylimQdown_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editstability_Callback(hObject, eventdata, handles)
function editstability_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function popus_Callback(hObject, eventdata, handles)
 if get(handles.popus,'value')==1 % LBC is const
      set(handles.addrowus,'Enable','off') % disable the add row and erase row buttons
      set(handles.deleterowus,'Enable','off')
      data = get(handles.uitableus,'Data');
      data=[data(1,1) data(1,2)];
      set(handles.uitableus,'Data',data)
 else
     set(handles.addrowus,'Enable','on') % disable the add row and erase row buttons
     set(handles.deleterowus,'Enable','on')
 end
function popus_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popds_Callback(hObject, eventdata, handles)
 if get(handles.popds,'value')==1 % RBC is const
      set(handles.addrowds,'Enable','off') % disable the add row and erase row buttons
      set(handles.deleterowds,'Enable','off')
      data = get(handles.uitableds,'Data');
      data=[data(1,1) data(1,2)];
      set(handles.uitableds,'Data',data)
 else
     set(handles.addrowds,'Enable','on') % disable the add row and erase row buttons
     set(handles.deleterowds,'Enable','on')
 end
function popds_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function poptimeds_Callback(hObject, eventdata, handles)
function poptimeds_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function poptimeus_Callback(hObject, eventdata, handles)
function poptimeus_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit51_Callback(hObject, eventdata, handles)
function edit51_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
