function [Qrounded,Hrounded]=preissmann(inputs,Q,H,LBC,RBC)
X=inputs.X;
T=inputs.T;
maxiteration=inputs.maxiteration;
theta=inputs.theta;
epsi=inputs.psi;
dx=inputs.dx;
dt=inputs.dt;
beta=inputs.beta;
b=inputs.b;
c=inputs.c;
s=inputs.s;
%% Factors 
A1=zeros(1,X-1);
B1=zeros(1,X-1);
C1=zeros(1,X-1);
D1=zeros(1,X-1);
E1=zeros(1,X-1);
A2=zeros(1,X-1);
B2=zeros(1,X-1);
C2=zeros(1,X-1);
D2=zeros(1,X-1);
E2=zeros(1,X-1);

E=zeros(1,2*X);
F=zeros(2*X,2*X);  % matrix of the coefficient Size of(2X*2X)
Unknowns=zeros(2*X);
cols=1;
%% waiting bar
wait = waitbar(0,'1','Name','calculation process',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(wait,'canceling',0)
for t=2:T   % start of computation for all time steps
    %% waiting bar
    % Check for Cancel button press
    if getappdata(wait,'canceling')
        break
    end
    waitbar(t/T,wait,['Time step = ' num2str(t) '/' num2str(T) ' ' num2str(round(t*100/T)) '%'])  %sprintf('%d',t)
    %% Iteration 
    for iter=1:maxiteration     % strating the iterations
        
          if iter==1  % for the first iteration assume that the current and next value of Q & H is the same like the previous step
            Q(t,:)=Q(t-1,:);
            H(t,:)=H(t-1,:);
        elseif iter > 1  % for the second iteration use the values that we have calculated in the previous iteration
            Q(t,:)=Q(t,:);
            H(t,:)=H(t,:);
          end
        % as we have changed the entire row including the BC that we have
        % assigned we have to bring them back
        if strcmp(LBC.type,'h') % if the lBC is h
            H(t,1)=LBC.interpolatedvalues(t,1);          % bring back the value of the LBC do not assume it
        else
            Q(t,1)=LBC.interpolatedvalues(t,1);
        end
        
        if strcmp(RBC.type,'h') % if the RBC is h
            H(t,X)=RBC.interpolatedvalues(t,1);          % bring back the value of the LBC do not assume it
        else
            Q(t,X)=RBC.interpolatedvalues(t,1);
        end
        
        for x=1:X-1
            %% compute all the coefficient A B C D based on Q(t-1) and Q_comp
            % continuity equation factors
            A1(x)=(-theta/dx);
            B1(x)=(b*(1-epsi)/dt);
            C1(x)=(theta/dx);
            D1(x)=(b*epsi/dt);
            E1(x)=((1-epsi)*b*H(t-1,x)/dt)+(epsi*b*H(t-1,x+1)/dt)-((1-theta)*(Q(t-1,x+1)-Q(t-1,x))/dx);
            % continuity equation factors
            F(2*x-1,cols)=A1(x);
            F(2*x-1,cols+1)=B1(x);
            F(2*x-1,cols+2)=C1(x);
            F(2*x-1,cols+3)=D1(x);
            E(2*x-1)=E1(x);
            %% momentum equation factors
            hj_nhalf=0.5*(H(t,x)+H(t-1,x));
            Aj_nhalf=b*hj_nhalf;
            hj1_nhalf=0.5*(H(t,x+1)+H(t-1,x+1));
            Aj1_nhalf=b*(hj1_nhalf);
            Ajhalf_nhalf=0.5*( Aj_nhalf+Aj1_nhalf);
            Kj_nhalf = c*b*hj_nhalf^(1.5);
            Kj1_nhalf = c*b*hj1_nhalf^(1.5);
            A2(x)=((1-epsi)/dt)-(beta/Aj_nhalf/dx)*Q(t-1,x)+(1-epsi)*9.81*Aj_nhalf*(abs(Q(t-1,x))/(Kj_nhalf)^2);
            B2(x)=-9.81*Ajhalf_nhalf*(theta/dx);
            C2(x)=(epsi/dt)+(beta/Aj1_nhalf/dx)*Q(t-1,x+1)+epsi*9.81*Ajhalf_nhalf*(abs(Q(t-1,x+1))/Kj1_nhalf^2);
            D2(x)=9.81*Ajhalf_nhalf*(theta/dx);
            E2(x)=((1-epsi)/dt)*Q(t-1,x)+(epsi/dt)*Q(t-1,x+1)-9.81*Ajhalf_nhalf*(1-theta)*(H(t-1,x+1)-H(t-1,x))/dx+9.81*Ajhalf_nhalf*s;
            % momentum equation factors
            F(2*x,cols)=A2(x);
            F(2*x,cols+1)=B2(x);
            F(2*x,cols+2)=C2(x);
            F(2*x,cols+3)=D2(x);
            E(2*x)=E2(x);
            cols=cols+2;
        end  % end of X loop (all factors are calculated except the BC )
        
        %% BC at F & E matrix 
        % lBC
        % the left BC is always at the row before the last row 2*X-1
        % if Q put 1 in the 1st column if h put 1 in the 2nd column of the
        % matrix F (the matrix of the factors A B C D)
        % put the value of the BC at that time at vector E at the same row
        if strcmp(LBC.type,'h')     % if the lBC is h
            F(2*X-1,2)=1;          % put 1 at the factor matrix at the line before the last line
            E(2*X-1)=LBC.interpolatedvalues(t,1);    % put the value of the HLBC at this certain time at the E matrix at the line before the last line
        else            % Q
            F(2*X-1,1)=1;
            E(2*X-1)=LBC.interpolatedvalues(t,1);
        end
        % RBC
        % the right BC is always at the last row 2*X
        % if Q put 1 in the column before the last column if h put 1 in the last column of the
        % matrix F (the matrix of the factors A B C D)
        % put the value of the BC at that time at vector E at the same row
        if strcmp(RBC.type,'h')   % if the RBC is h
            F(2*X,2*X)=1;        % put 1 at the factor matrix at the line before the last line
            E(2*X)=RBC.interpolatedvalues(t,1);    % put the value of the HLBC at this certain time at the E matrix at the line before the last line
        else
            F(2*X,2*X-1)=1;
            E(2*X)=RBC.interpolatedvalues(t,1);
        end
        cols=1;   % to make the storing of factors starts from the first row again
        %% Solving the equation F * Unknowns = E 
        %E=E';
        Unknowns=inv(F)*E';  % F is a square matrix , E is a column vector
        %Unknowns=F\E';
        %% Extracting the values of Q & H from the Unknown matrix
        % unknowns=[Q,H,Q,H,Q,H,Q,H............,LBC,RBC]
        j=1;
        k=1;
        for i=1:length(Unknowns)
            if mod(i,2)==0  % mod is zero for all the even numbers
                H(t,j)=Unknowns(i); 
                j=j+1;
            else
                Q(t,k)=Unknowns(i);  % mod is nonzero for all the odd numbers
                k=k+1;
            end
        end
    end % end of iterations
    %% save computed values at time steps 
end  % end of computation for all time steps

delete(wait)

Hrounded=round(H,3);
Qrounded=round(Q,3);
clc
