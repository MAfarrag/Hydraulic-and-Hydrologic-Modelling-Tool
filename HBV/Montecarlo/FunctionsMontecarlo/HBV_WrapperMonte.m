function [Qnew] = HBV_WrapperMonte(p,v,timebases)
Qnew=zeros(length(v(:,1)),1);
St = 3*ones(1,5);          % Assume the first states
area=v(1,5);
for i=1:length(v(:,1))
    [Qnew(i),St] = HBVMonte(p,v(i,1:4),St,area,timebases);
end

end

