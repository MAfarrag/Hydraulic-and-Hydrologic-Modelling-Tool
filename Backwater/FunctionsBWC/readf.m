function [b,ho,dx,Q,C,I]=readf(path)
%% reading the data
data=importdata(path,'');
for i=2:length(data)
    var{i-1}=strsplit(data{i});
end
for i=1:length(var)
    eval([ var{1,i}{1,2} '= str2num(var{1,i}{1,1})' ]);
end
clc
