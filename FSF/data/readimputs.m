function [inputs]=readimputs(filename)
% reading the input file   
fid=fopen(filename);  %'input.txt';
n=0;                    % n is the number of lines (number of rows)
f=fgetl(fid);
 while f ~= -1         % this while loop is made just to count the number of rows
     f = fgetl(fid);
     n=n+1;
 end
 %-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
 frewind(fid); % this command to operation go to the beginning of the
               % file again
%% reading each line and split it 
for i=1:n
     f = fgetl(fid);               % reading each line separately 
     line_split= strsplit(f,' ');  %and split the line at every space 
     dummy{i}= line_split;         %storing every line in a separate field   
 end                               %and every element in this line in a separate cell
%% assigning values
inputs.L=str2double(dummy{1,3}{1,1});   % length
inputs.b=str2double(dummy{1,4}{1,1});   % bed width
inputs.c=str2double(dummy{1,5}{1,1});   % chezy coeff
inputs.g=str2double(dummy{1,6}{1,1});   % gravitational acceleration
inputs.s=str2double(dummy{1,7}{1,1});   % slope
inputs.dx=str2double(dummy{1,9}{1,1});
inputs.dt=str2double(dummy{1,10}{1,1}); % dt in sec
inputs.theta=str2double(dummy{1,11}{1,1});
inputs.psi=str2double(dummy{1,12}{1,1});
inputs.maxiteration=str2double(dummy{1,13}{1,1});   % max no of iterations
inputs.maxt=str2double(dummy{1,14}{1,1});       % time in hours
inputs.beta=1;
inputs.ICf=dummy{1,16}{1,1};        % initial conditions
inputs.LBCf=dummy{1,17}{1,1};        % LBC
inputs.RBCf=dummy{1,18}{1,1};        % RBC
inputs.Qout=dummy{1,20}{1,1};         % resulted Q
inputs.Hout=dummy{1,21}{1,1};         % resulted h
