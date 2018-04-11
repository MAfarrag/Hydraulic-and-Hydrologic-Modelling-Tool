function [R]=calc(b,ho,dx,Q,C,I,n)
%%Validation of data
if b<=0
    msgbox('b must be a positive number!');
    return
end
if ho<=0 
   msgbox('ho must be a positive number!');
    return
end
if dx<=0
    msgbox('dx must be a positive number!');
    return
end

if Q<=0 
    msgbox('Q must be a positive number!');
    return
end

if C<=0 
    msgbox('C must be a positive number!');
    return
end

if I<=0 || I>=1 
    msgbox('Ib must be a positive number less than 1!');
    return
end

if n<=0 
    msgbox('n must be a positive number more than 1!');
    return
end
%%
points=0:n;          %10 calculated points + the initial point at the mouth 
h(1)= ho;                          % water depth at the downstream end (Boundary condition)
Elev(1)=0;
Dist(1)=0;
WL(1)=h(1)+Elev(1);
const=(Q^2)/(C^2)/(b^2);
%% Implicit Calculation    solving the equation first explicitly in order to get starting values at all the points to be able to start calculation 
%--------------------------------------------------------------------------
% waiting bar
wait = waitbar(0,'1','Name','calculation process',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(wait,'canceling',0)
%--------------------------------------------------------------------------
for i=2:n+1
    %% waiting bar
    % Check for Cancel button press
    if getappdata(wait,'canceling')
        break
    end
    waitbar(i/n,wait,['Caculation step = ' num2str(i) '/' num2str(n) ' ' num2str(round(i*100/n)) '%'])  %sprintf('%d',t)
%--------------------------------------------------------------------------
    solver=h(i-1);   % for each position the solver start from the value of water depth the previous position i-1 
    error=0.1;       % starting value for the error to be able to enter the while loop
    while error >= 0.00001
    h(i)= h(i-1)+dx*((const/solver^3)-I) ; % water depth above the ground
    error=solver-h(i);
    solver = solver-0.00001;
    end
    Dist(i)=Dist(i-1)+dx;
    Elev(i)=Elev(i-1)+I*dx;
    WL(i)=Elev(i)+h(i);
end
delete(wait)
R(1,:)= points;         % points
R(2,:)= Dist;          % cumulative distance
R(3,:)= round(h,3);             % water depth above the ground
R(4,:)= Elev;          % bed elevation or geodetical height
R(5,:)=round(WL,3); 
