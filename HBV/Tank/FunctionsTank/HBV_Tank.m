function [Error,Qnew,St,Q0,Q1,CF] = HBV_Tank(p,Flow,v,timebases)

St=zeros(length(Flow),5);
Q0=zeros(length(Flow),1);
Q1=zeros(length(Flow),1);
CF=zeros(length(Flow),1);
Qnew=zeros(length(Flow),1);
St(1,:) = 3*ones(1,5); % Assume the first states

area=v(1,5);
for i=1:length(Flow)
    [Qnew(i),St(i+1,:),Q0(i),Q1(i),CF(i)] = HBVT(p,v(i,1:4),St(i,:),area,timebases);
end
Error(1) = -NSE(Flow,Qnew);   % Nash Sutcliffe Effiency
Error(2) = RMSE(Flow,Qnew);   % Root Mean Squared Error
Error(3) = PBIAS(Flow,Qnew);  % Percent Bias
Error(4) = RSR(Flow,Qnew);    % RMSE Observations standard deviation ratio
end

