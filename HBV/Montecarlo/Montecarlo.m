function varargout = Montecarlo(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Montecarlo_OpeningFcn, ...
                   'gui_OutputFcn',  @Montecarlo_OutputFcn, ...
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


function Montecarlo_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Montecarlo
%% add paths
addpath(genpath('FunctionsMontecarlo')); 
%% read data of sieve catchment
cla(handles.axes100)
axes(handles.axes100);
[handles.data]=readdatamonte('Sieve.cal','Sieve.cal');
set(handles.editinputfile,'String','Sieve.cal');  %write the name of the loaded file of the edit text
plotQmonte(handles.data.Flow);
title('Observation Flow')
% 1- preparing the data for calibration(length of the vectors)
%handles.parameter.
LB = [-1,0,0,1,20,0.6,0,0,0.05,0.01,1,1.5,0.001,0.01,2.5,1,0.6,0.6]; 
UB = [2,3,2,5,120,1.4,5,1,0.1,0.1,2,2.4,0.1,1,3.5,6,1.4,1.4]; 
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
%% set the values of the Lower limit 
for i=1:length(parameters)
    param=['handles.parameter.limits.' parameters{i}];        % lower bound
    value=LB(i);
    eval([param ,'=', num2str(value) ] )              % stor value in the struct
    edittextlower=['handles.edit' ,parameters{i},'1']; % the edit text
    set(eval(edittextlower),'String',value);           % set the value to the edit text
    %----------------------------------------------------------------------
    param=['handles.parameter.limits.' parameters{i} '(1,2)'];% upper bound
    value=UB(i);
    eval([param ,'=', num2str(value) ] )              % stor value in the struct
    edittextupper=['handles.edit' ,parameters{i},'2']; % the edit text
    set(eval(edittextupper),'String',value);           % set the value to the edit text
end
%% preset of buttons
set(handles.radioSpecificN,'Value',1) 
set(handles.radioConverge,'Value',0)
set(handles.editNorun,'string',100)
set(handles.editconverge,'String',[])  
set(handles.editdiffinmean,'String',[])
set(handles.editNo,'String',[])
set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off')
%% about the slider
set(handles.slider19,'Max',length(handles.data.Flow),'Min',0)
set(handles.slider19,'Value',0)
%% variable that its value will increase if calculate button has been pressed 
handles.montecarlo=0;

clc
handles.output = hObject;   
% Update handles structure
guidata(hObject, handles);


function varargout = Montecarlo_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%% input file name
function pushloadfile_Callback(hObject, eventdata, handles)
[filename,path] = uigetfile({'*.cal';'*.mat'},'File Selector','Select the input file');
if (filename~=0)
    path=[path filename]; % full path with the name
else
   return
end
axes(handles.axes100);
[handles.data]=readdatamonte(filename,path);
set(handles.editinputfile,'String',filename);  %write the name of the loaded file of the edit text
plotQmonte(handles.data.Flow);


% cla(handles.axes2)
% axes(handles.axes2);
% plotQ(handles.data.Flow);
% cla(handles.axes3)

% Update handles structure
guidata(hObject, handles);

%% parameters file
function pushloadparam_Callback(hObject, eventdata, handles)
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
% set(handles.editTT1,'String',num2str(handles.par.TT));
% set(handles.editTTI1,'String',num2str(handles.par.TTI));
% set(handles.editTTM1,'String',num2str(handles.par.TTM));
% set(handles.editCFMAX1,'String',num2str(handles.par.CFMAX));
% set(handles.editFC1,'String',num2str(handles.par.FC));
% set(handles.editECORR1,'String',num2str(handles.par.ECORR));
% set(handles.editETF1,'String',num2str(handles.par.ETF));
% set(handles.editLP1,'String',num2str(handles.par.LP));
% set(handles.editK11,'String',num2str(handles.par.K));
% set(handles.editK2,'String',num2str(handles.par.K1));
% set(handles.editALPHA1,'String',num2str(handles.par.ALPHA));
% set(handles.editBETA1,'String',num2str(handles.par.BETA));
% set(handles.editCWH1,'String',num2str(handles.par.CWH));
% set(handles.editCFR1,'String',num2str(handles.par.CFR));
% set(handles.editCFLUX1,'String',num2str(handles.par.CFLUX));
% set(handles.editPERC1,'String',num2str(handles.par.PERC));
% set(handles.editRFCF1,'String',num2str(handles.par.RFCF));
% set(handles.editSFCF1,'String',num2str(handles.par.SFCF));
% Update handles structure
guidata(hObject, handles);

%% monte carlo
function Montecarlo_Callback(hObject, eventdata, handles)
%% increase the validation variable
handles.montecarlo=1;
%% reread the limits and the distribution
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:length(parameters)
    % lower limit
    edittextlower=['handles.edit' ,parameters{i},'1'];         % name of the edit text
    value=get(eval(edittextlower),'String');                   % get the value from the edit text
    param=['handles.parameter.limits.' parameters{i} '(1,1)']; % name of the parameter(the struct)
    eval([param ,'=', value] )                                 % assign the value to the parameter
    % upper limit
    edittextupper=['handles.edit' ,parameters{i},'2'];         % name of the edit text
    value=get(eval(edittextupper),'String');                   % get the value from the edit text
    param=['handles.parameter.limits.' parameters{i} '(1,2)']; % name of the parameter(the struct)   
    eval([param ,'=',value] )                                  % assign the value to the parameter
    % popup menu
    pop=['handles.pop' parameters{i}];                         % name of the popupmenu
    popvalue=get(eval(pop),'value');                           % get the value from the menu
    param=['handles.parameter.dist.' parameters{i}];           % assign the value to the parameter
    eval([param ,'=', num2str(popvalue) ] )                    % assign the the distribution to the parameter
end
%%-------------------------------------------------------------------------
%% calculation
uncertainty.prec = handles.data.Prec;
uncertainty.temp = handles.data.Temp;
uncertainty.Flow = handles.data.Flow;
uncertainty.ET = handles.data.Evap;
uncertainty.LTAT = mean(uncertainty.temp)*ones(length(uncertainty.Flow),1);
v = [uncertainty.prec,uncertainty.temp,uncertainty.ET,uncertainty.LTAT];    %v=[precipitation,temperature, potential evapotranspiration, daily mean temp]required variable matrix for the HBV code 
v(1,5)=handles.data.Area;
% sroring the time bases of the measurement
if strcmp(handles.data.TStep,'hourly')==1   % so the data are hourly
    timebases=1;
else
    timebases=0;
end
%% Rum HBV-----------------------------------------------------------------
% Specific no of runs
if get(handles.radioSpecificN,'Value') == 1  % if the user selected to run specific no of runs    
    %% No of Runs
    N=round(str2double(get(handles.editNorun,'String')));
    if isnan(N) || N< 1 % check on the precentage
        msgbox('Please select a number of Runs more than 1');
        return
    end
    % waiting bar
    wait = waitbar(0,'1','Name','calculation process',...
        'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    setappdata(wait,'canceling',0)
    p=zeros(N,18);
    %% for loop
    for i = 1:N
        if getappdata(wait,'canceling')
            break
        end
         waitbar(i/N,wait,['Iteration No = ' num2str(i) '/' num2str(N) '   ' num2str(round(i*100/N)) '%'])
        p(i,:) = sampling(handles.parameter); % generate 18 randum parameters
        %Check that parameter values are not less than zero(except to TT, TTI,%TTM)
        for j = 4:length(p(i,:))
            if p(i,j) < 0
                p(i,j) = 0;
            end
        end
        [uncertainty.Qcal(i,:)] = HBV_WrapperMonte(p(i,:),v,timebases);
    end
    delete(wait)
    diff=abs(mean(uncertainty.Qcal(end,:))-mean(uncertainty.Qcal(end-1,:)));
    set(handles.editdiffinmean,'String',round(diff,3))
%% -------------------------------------------------------------------------    
%% -------------------------------------------------------------------------
else      % If the user has chossen run till the Difference in mean less than 
     %% Value of difference
    stop=str2double(get(handles.editconverge,'String'));
    if isnan(stop)
        msgbox('Please select the value of the stopping rule');
        return
    end
    % waiting bar
    wait = waitbar(0,'1','Name','calculation process',...
        'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    setappdata(wait,'canceling',0)
    
   N = 1;   % no of calculations till stopping rule achevied
   diff=1000;
   meannew = 0;
   while diff > stop
       if getappdata(wait,'canceling')
           break
       end
       waitbar(N,wait,['Iteration No = ' num2str(N)])
       meanold = meannew;
       
       p(i,:) = sampling(handles.parameter); % generate 18 randum parameters
       %Check that parameter values are not less than zero(except to TT, TTI,%TTM)
       for j = 4:length(p(i,:))
           if p(i,j) < 0
               p(i,j) = 0;
           end
       end
       [uncertainty.Qcal(N,:)] = HBV_WrapperMonte(p(i,:),v,timebases);
       meannew = mean(uncertainty.Qcal(N,:));
       diff = abs(meannew - meanold);
       N = N + 1;
   end
   N=N-1;
   delete(wait)
   set(handles.editNo,'String',N)
end
%% plotting ---------------------------------------------------------------
cla(handles.axes100)
axes(handles.axes100);
set( findall(handles.axes100, '-property', 'visible'), 'visible', 'on')   % make axes1 visible
set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off') % make the panel invisible
% plot the observed flow
plot(handles.data.Flow(:,1),'--r','lineWidth',2)
hold on
% plot the calculated flow
for i=1:N
    plot(uncertainty.Qcal(i,:),'-.')
end
xlabel('Time')
ylabel('Discharge 10^3 m3/sec')
handles.leg=legend('Observed','Uncertain Flow');
title('Plot of Observation vs Simulated')
h = get(handles.axes100,'ytick');
set(handles.axes100,'yticklabel',h/10^3)
%--------------------------------------------------------------------------
%% calculationg pdf
% mean & SDV
for i=1:length(uncertainty.Qcal(1,:))
    uncertainty.Qmean(i)=mean(uncertainty.Qcal(:,i));
    uncertainty.Qstd(i)=std(uncertainty.Qcal(:,i));
    uncertainty.Qskewness(i)=skewness(uncertainty.Qcal(:,i));
    uncertainty.Qkurtosis(i)=kurtosis(uncertainty.Qcal(:,i));
end

for i=1:length(uncertainty.Qcal(1,:))
% uncertainty.Qnormpdf(:,i)=(1/(uncertainty.Qstd(i)*sqrt(2*pi)))*(exp((-(sort(uncertainty.Qcal(:,i))-uncertainty.Qmean(i)).^2)/(2*uncertainty.Qstd(i)^2)));
% [uncertainty.cdfv(:,i),uncertainty.cdfx(:,i)] = empcdf(uncertainty.Qcal(:,i));
uncertainty.Qnormpdf(:,i)= exp(-(sort(uncertainty.Qcal(:,i))-uncertainty.Qmean(i)).^2./(2*uncertainty.Qstd(i)^2))./(uncertainty.Qstd(i)*sqrt(2*pi));
end
%% calculating pdf
% for i=1:length(uncertainty.Qcal(1,:))
%     for j=2: length(uncertainty.Qcal(:,1))
%         uncertainty.pdfv(j,i)=uncertainty.cdfv(j,i)-uncertainty.cdfv(j-1,i);
%     end
% end
%--------------------------------------------------------------------------
%% about the slider
set(handles.slider19,'Max',length(handles.data.Flow),'Min',0)
set(handles.slider19,'Value',0)
%% the moving ball
handles.p1=plot(1,handles.data.Flow(1),'o','MarkerFaceColor','cyan'); % plot the marker


%% store variables in handles 
 handles.parameter.assumedvalues=p;
 handles.parameter.N=N;
 handles.uncertainty=uncertainty;
clc
% Update handles structure
guidata(hObject, handles);





%% clear figure
function pushclearfig_Callback(hObject, eventdata, handles)
axes(handles.axes100)
cla(handles.axes100)
cla(handles.axes50)
set( findall(handles.axes100, '-property', 'visible'), 'visible', 'on')   % make axes1 visible
set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off') % make the panel invisible

%% close
function pushclose_Callback(hObject, eventdata, handles)
close(Montecarlo)

%% save figures
function pushsavefig_Callback(hObject, eventdata, handles)
[Filename,Pathname] = uiputfile({ '*.jpg'}, 'Save plots');
if Filename==0
    return;
else
    name=strsplit(Filename,'.');
    str=strcat(Pathname,Filename);
    im1=getframe(handles.axes100);
    im=[im1.cdata];
    imwrite(im,Filename)
    im1=getframe(handles.axes50);
    im=[im1.cdata];
    imwrite(im,[name{1} '1.jpg'])
end

%% save results
function pushsavecalibrated_Callback(hObject, eventdata, handles)
% check if the calibration has been done or not
if isnan(str2double(get(handles.editdiffinmean,'String'))) && isnan(str2double(get(handles.editNo,'String'))) % read one of the edit text of the calibrated parameters if it is  empty send message 
    msgbox('please run the model first');
    return
end

[filename,path] = uiputfile({'*.mat'},'File Selector','Select the input file');
if (filename~=0)
    name=strsplit(filename,'.');
    path1=[path filename]; % full path with the name
    path2=[path name{1} 'parameters.jpg'];
else
   return
end
save1=handles.uncertainty;
save2=handles.parameter;
save(path1, 'save1')
save(path2, 'save2')



%% plotting options
function popplot_Callback(hObject, eventdata, handles)
%% empty the statictical properties
set(handles.editmean,'string','')
set(handles.editstdv,'string','')
set(handles.editskew,'string','')
set(handles.editQ,'string','')
set(handles.editTime,'string','')
cla(handles.axes50)
%% validation
if handles.montecarlo== 0
    msgbox('please press Run first');
    return
end
%% plotting
axes(handles.axes100)
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'};
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Spagetti
if get(handles.popplot,'value')==1   % spagetti plot
    %Validation of the moving ball and slider
    handles.montecarlo=2; 
    %----------------------------------------------------------------------
    axes(handles.axes100);
    set( findall(handles.axes100, '-property', 'visible'), 'visible', 'on')   % make axes1 visible
    set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off') % make the panel invisible
%     set(handles.leg,'visible','on') % make the legend invisible
    % plot the observed flow
    plot(handles.data.Flow(:,1),'--r','lineWidth',2)
    hold on
    % plot the calculated flow
    xlim([0,length(handles.data.Flow)])
    ylim([0,max(max(handles.uncertainty.Qcal))+50])
    for i=1:handles.parameter.N
        plot(handles.uncertainty.Qcal(i,:),'-.')
    end
    xlabel('Time')
    ylabel('Discharge 10^3 m3/sec')
    handles.leg=legend('Observed','Uncertain Flow');
    title('Plot of Observation vs MC Uncertainty Flow')
    handles.h = get(handles.axes100,'ytick');
    set(handles.axes100,'yticklabel',handles.h/10^3)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% mean
%--------------------------------------------------------------------------
elseif get(handles.popplot,'value')==2   % mean plot
    %Validation of the moving ball and slider
    handles.montecarlo=2; 
    %----------------------------------------------------------------------
    cla(handles.axes100)
    axes(handles.axes100);
    set( findall(handles.axes100, '-property', 'visible'), 'visible', 'on')   % make axes1 visible
    set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off') % make the panel invisible
    % plot the mean
    mu= mean(handles.uncertainty.Qcal);           % Mean of MC runs
    
    % plot the observed flow
    plot(handles.data.Flow(:,1),'--r','lineWidth',2)
    hold on
    plot(mu,'b','linewidth',2)
    xlabel('Time')
    ylabel('Discharge 10^3 m3/sec')
    handles.leg=legend('Observed','Mean of Uncertain Flow');
    title('Plot of Observation vs Mean of MC calculated Flow')
    h = get(handles.axes100,'ytick');
    set(handles.axes100,'yticklabel',h/10^3)
    %empcdf(Qcomp(t,:))%Cumulative distribution at 494 time step
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Standard veviation
%--------------------------------------------------------------------------
elseif get(handles.popplot,'value')==3
    %Validation of the moving ball and slider
    handles.montecarlo=2;
    %----------------------------------------------------------------------
    cla(handles.axes100)
    axes(handles.axes100);
    set( findall(handles.axes100, '-property', 'visible'), 'visible', 'on')   % make axes1 visible
    set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off') % make the panel invisible
    st= std(handles.uncertainty.Qcal);            % Standard deviation of MC runs
    % plot the observed flow
    plot(st)
    xlabel('Time')
    ylabel('Discharge 10^3 m3/sec')
    handles.leg=legend('Observed','Standard deviation');
    title('MC Uncertainty Flow')
    h = get(handles.axes100,'ytick');
    set(handles.axes100,'yticklabel',h/10^3)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% confidence interval
%--------------------------------------------------------------------------
elseif get(handles.popplot,'value')==4   
    %Validation of the moving ball and slider
    handles.montecarlo=2;
    %----------------------------------------------------------------------
    cla(handles.axes100)
    axes(handles.axes100);
    set( findall(handles.axes100, '-property', 'visible'), 'visible', 'on')   % make axes1 visible
    set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'off') % make the panel invisible
    % plot the observed flow
    y5= wprctile(handles.uncertainty.Qcal,5);     % 5% percentile values
    y95= wprctile(handles.uncertainty.Qcal,95);   % 95% percentile values
    area(y95);
    hold on
    f=area(y5);
    f.FaceColor = [1 1 1];
    title('Comparison of 95% and 5% confidence intervals')
    
    xlabel('Time')
    ylabel('Discharge 10^3 m3/sec')
    handles.leg=legend('confidence area');
    title('MC Uncertainty Flow')
    h = get(handles.axes100,'ytick');
    set(handles.axes100,'yticklabel',h/10^3)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% parameters distributions from 1 to 9
%--------------------------------------------------------------------------
elseif get(handles.popplot,'value')==5
    %Validation of the moving ball and slider
    handles.montecarlo=2;
    %----------------------------------------------------------------------
    set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'on') % make the panel visible
    set( findall(handles.axes100, '-property', 'visible'), 'visible', 'off')   % make axes1 invisible
    set(handles.leg,'visible','off') % make the legend invisible
    [indexx,nc,xcc,nnn,y] =ahist2(handles.parameter.assumedvalues) ;
    if nargout == 0
        rows  = ceil(sqrt(9));
        cols  = ceil(9/rows);
        for i = 1:9
            subplot(rows,cols,i,'Parent',handles.uipanel6);
            bar(xcc(:,i),nnn(:,i),'hist');
            xlim([min(y(:,i)) max(y(:,i))])
            xlabel(parameters{i})
        end
    else
        n = nnn;
        xc = xcc;
        index = indexx;
    end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% parameters distributions from 10 to 18
%--------------------------------------------------------------------------
elseif get(handles.popplot,'value')==6   % parameters distributions
    %Validation of the moving ball and slider
    handles.montecarlo=2;
    %----------------------------------------------------------------------
    set( findall(handles.axes100, '-property', 'visible'), 'visible', 'off')
    set( findall(handles.uipanel6, '-property', 'visible'), 'visible', 'on')
    set(handles.leg,'visible','off') % make the legend invisible
    [indexx,nc,xcc,nnn,y] =ahist2(handles.parameter.assumedvalues) ;
    if nargout == 0
        rows  = ceil(sqrt(9));
        cols  = ceil(9/rows);
        for i = 1:9
            subplot(rows,cols,i,'Parent',handles.uipanel6);
            bar(xcc(:,i+9),nnn(:,i+9),'hist');
            xlim([min(y(:,i+9)) max(y(:,i+9))])
            xlabel(parameters{i+9})
        end
    else
        n = nnn;
        xc = xcc;
        index = indexx;
    end
end
% Update handles structure
guidata(hObject, handles);
function popplot_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% moving ball and histogram
function slider19_Callback(hObject, eventdata, handles)
%% validation
% if the plot changed to another plot than the spagetti plot the object of
% the ball will be deleted
if handles.montecarlo~=1
    msgbox('please rerun the calculation to be able to use the slider and moving ball');
    return
end

if get(handles.popplot,'value')~=1 
    msgbox('you have to select Uncertain plots as a plot type ');
    return
end
set(handles.slider19,'SliderStep',[0.001 0.001]);
sliderval=get(hObject,'Value');
%% move the moving ball
axes(handles.axes100)
handles.p1.XData =round(sliderval);  %+x;
handles.p1.YData = handles.data.Flow(handles.p1.XData);
drawnow
%% plot the histogram
cla(handles.axes50)
axes(handles.axes50);
histogram(handles.uncertainty.Qcal(:,handles.p1.XData),'Normalization','pdf')
xlabel('Q(m3/sec)')
ylabel('Frequency of occurrence')
title('Uncertainty on each Value')
hold on
plot(sort(handles.uncertainty.Qcal(:,handles.p1.XData)),handles.uncertainty.Qnormpdf(:,handles.p1.XData),'LineWidth',1.5)
set(handles.editmean,'string',round(handles.uncertainty.Qmean(1,handles.p1.XData),2))
set(handles.editstdv,'string',round(handles.uncertainty.Qskewness(1,handles.p1.XData),2))
set(handles.editskew,'string',round(handles.uncertainty.Qskewness(1,handles.p1.XData),2))
set(handles.editQ,'string',round(handles.uncertainty.Qkurtosis(1,handles.p1.XData),2))
set(handles.editTime,'string',handles.p1.XData)



function slider19_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%--------------------------------------------------------------------------
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

function editconverge_Callback(hObject, eventdata, handles)
function editconverge_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editNorun_Callback(hObject, eventdata, handles)
function editNorun_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editdiffinmean_Callback(hObject, eventdata, handles)
function editdiffinmean_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editNo_Callback(hObject, eventdata, handles)
function editNo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% parameters lower limit
function editTT1_Callback(hObject, eventdata, handles)
function editTT1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editTTI1_Callback(hObject, eventdata, handles)
function editTTI1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editTTM1_Callback(hObject, eventdata, handles)
function editTTM1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCFMAX1_Callback(hObject, eventdata, handles)
function editCFMAX1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editFC1_Callback(hObject, eventdata, handles)
function editFC1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editECORR1_Callback(hObject, eventdata, handles)
function editECORR1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editETF1_Callback(hObject, eventdata, handles)
function editETF1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editLP1_Callback(hObject, eventdata, handles)
function editLP1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editK1_Callback(hObject, eventdata, handles)
function editK1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editK11_Callback(hObject, eventdata, handles)
function editK11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editALPHA1_Callback(hObject, eventdata, handles)
function editALPHA1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editBETA1_Callback(hObject, eventdata, handles)
function editBETA1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCWH1_Callback(hObject, eventdata, handles)
function editCWH1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCFR1_Callback(hObject, eventdata, handles)
function editCFR1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editCFLUX1_Callback(hObject, eventdata, handles)
function editCFLUX1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editPERC1_Callback(hObject, eventdata, handles)
function editPERC1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRFCF1_Callback(hObject, eventdata, handles)
function editRFCF1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editSFCF1_Callback(hObject, eventdata, handles)
function editSFCF1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% parameters upper limit---------------------------------------------------
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
%% popupmenus
function popTT_Callback(hObject, eventdata, handles)
function popTT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popTTI_Callback(hObject, eventdata, handles)
function popTTI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popTTM_Callback(hObject, eventdata, handles)
function popTTM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popCFMAX_Callback(hObject, eventdata, handles)
function popCFMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popFC_Callback(hObject, eventdata, handles)
function popFC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popECORR_Callback(hObject, eventdata, handles)
function popECORR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popETF_Callback(hObject, eventdata, handles)
function popETF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popLP_Callback(hObject, eventdata, handles)
function popLP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popK_Callback(hObject, eventdata, handles)
function popK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popK1_Callback(hObject, eventdata, handles)
function popK1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popALPHA_Callback(hObject, eventdata, handles)
function popALPHA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popCWH_Callback(hObject, eventdata, handles)
function popCWH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popBETA_Callback(hObject, eventdata, handles)
function popBETA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popCFR_Callback(hObject, eventdata, handles)
function popCFR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popCFLUX_Callback(hObject, eventdata, handles)
function popCFLUX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popPERC_Callback(hObject, eventdata, handles)
function popPERC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popRFCF_Callback(hObject, eventdata, handles)
function popRFCF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popSFCF_Callback(hObject, eventdata, handles)
function popSFCF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% -------------------------------------------------------------------------
%Radio

function radioSpecificN_Callback(hObject, eventdata, handles)
set(handles.radioSpecificN,'Value',1) 
set(handles.radioConverge,'Value',0)
set(handles.editconverge,'String',[])  
set(handles.editdiffinmean,'String',[])
set(handles.editNo,'String',[])
function radioConverge_Callback(hObject, eventdata, handles)
set(handles.radioSpecificN,'Value',0) 
set(handles.radioConverge,'Value',1)    % editNorun
set(handles.editNorun,'String',[])
set(handles.editdiffinmean,'String',[])
set(handles.editNo,'String',[])



function editmean_Callback(hObject, eventdata, handles)
function editmean_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editstdv_Callback(hObject, eventdata, handles)
function editstdv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editskew_Callback(hObject, eventdata, handles)
function editskew_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editQ_Callback(hObject, eventdata, handles)
function editQ_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTime_Callback(hObject, eventdata, handles)
function editTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
