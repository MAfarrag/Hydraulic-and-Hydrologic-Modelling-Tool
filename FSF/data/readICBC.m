function [IC LBC RBC]=readICBC(name1,name2,name3)
%% reading IC & BC
% reading only the type of the boundary Condition is it Q or H and the unit
% is hours or min or sec
namef{1}=name2; namef{2}=name3; % LBC then RBC
bc={'LBC','RBC'};
for i=1:2
    fid=fopen(namef{i});
    f=textscan(fid,'%s');
    eval([bc{i} '.type=' 'f{1}{4}']) % BC type is it H or Q
    eval([bc{i} '.unit=' 'f{1}{5}']) % BC unit is it H or Q
end
fclose(fid);
LBC.value=dlmread(name2,'',3,0); % BC value
RBC.value=dlmread(name3,'',3,0); % BC value
QHinitial=dlmread(name1,'',1,0);
IC.Q=QHinitial(:,1);   % IC for Q
IC.H=QHinitial(:,2);   % IC for h
