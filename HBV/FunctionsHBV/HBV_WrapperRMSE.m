function [Error] = HBV_WrapperRMSE(p)
%v=csvread('temp.txt',0,0);
load('v.mat');
v=h;
Flow=v(:,5);
area=v(1,6);
timebases=h(1,7);
St = 3*ones(1,5);           % Assume the first states
Qnew = zeros(length(Flow),1);

for i=1:length(Flow)
    [Qnew(i), St] = HBV(p,v(i,1:4),St,area,timebases);
end
Error= RMSE(Flow,Qnew);   % Nash Sutcliffe Effiency
end

