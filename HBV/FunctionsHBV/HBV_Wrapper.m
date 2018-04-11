function [Error,Qnew,St] = HBV_Wrapper(p,Flow,v,timebases)

Qnew=zeros(length(Flow),1);
St = zeros(length(Flow),5);
St(1,:) = 3*ones(1,5);          % Assume the first states
area=v(1,5);
for i=1:length(Flow)
    [Qnew(i), St(i+1,:)] = HBV(p,v(i,1:4),St(i,:),area,timebases);
end
Error(1) = -NSE(Flow,Qnew);   % Nash Sutcliffe Effiency
Error(2) = -RMSE(Flow,Qnew);   % Root Mean Squared Error
Error(3) = -PBIAS(Flow,Qnew);  % Percent Bias
Error(4) = -RSR(Flow,Qnew);    % RMSE Observations standard deviation ratio
end

