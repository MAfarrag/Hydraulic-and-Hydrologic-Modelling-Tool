function [data]=readdataTank(filename,path)
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
fclose('all');
clc
