function [data]=readdata(filename,path)
%% reading the data

format=strsplit(filename,'.');  % split the name from the format to know if it is .m or .cal
if format{2}== 'mat'
    load(path);
    eval(['data=' format{1}]);
else
    fid=fopen(path); % open to read the area of the catchment
    n=2;
    for i=1:n
        f = fgetl(fid);               % reading each line separately
        line_split= strsplit(f,' ');  %and split the line at every space
        dummy{i}= line_split;         %storing every line in a separate field
    end                                %and every element in this line in a separate cell
    dummy1=dlmread(path,'',10,0);
    data.Temp=dummy1(:,1);
    data.Temp=5*ones(length(dummy1(:,1)),1); % assume the temperature to be 25 
    data.Prec=dummy1(:,1);
    data.Flow=dummy1(:,3);
    data.Area=str2double(dummy{2}{1});   % area(km^2)
    data.Evap=dummy1(:,2);
    data.TStep='hourly';
end
l=length(data.Prec);
[ax,h1,h2]=plotyy(1:l,data.Prec,1:l,data.Evap,'line','line');
set(ax(1),'ydir','reverse');
title('Input Precipitation and Evapotranspiration');
xlabel('time(days)');
xlim([1,l])
ylabel(ax(1),'precipitation(mm)','Fontsize',8);
ylabel(ax(2),'Evapotranspiration(mm)','Fontsize',8);
%set(get(gca,'xlabel'),'position',[0 0 10])

fclose('all');
