function [interpolatedBC]=BCinterp(BC,dt,T)
if strcmp(BC.unit,'sec')     % LBC unit
    interp=dt;
elseif strcmp(BC.unit,'min')     % LBC unit
    interp=dt/60;
elseif strcmp(BC.unit,'hours')     % LBC unit
    interp=dt/60/60;
elseif strcmp(BC.unit,'days')     % LBC unit
    interp=dt/60/60/24;
end
interp11=interp;
% check if the BC is Q or H 
%if strcmp(BC.type,'h')
    for t=1:T
        interpolatedBC(t,1)=interp1(BC.value(:,1),BC.value(:,2),interp11);
        %HLBC(t,1)=H(t,1);
        interp11=interp11+interp;   % update the value of the interp
    end
% %else  % if Q
%     for t=2:T
%         Q(t,1)=interp1(LBC(:,1),LBC(:,2),interp11);
%         QLBC(t,1)=Q(t,1);
%         interp11=interp11+interp;   % update the value of the interp
%     end
% end
