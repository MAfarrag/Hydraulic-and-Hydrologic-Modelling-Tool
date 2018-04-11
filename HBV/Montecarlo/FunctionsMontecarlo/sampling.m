function sample = sampling(distFile,varargin)
%SAMPLING  sample parameter from distribution file.                      
%                                             
% USAGE:
%         sample = SAMPLING(distFile)
%         sample = SAMPLING(distFile,nSamples)
%         sample = SAMPLING(distFile,nSamples,seed)
%                                             
% INPUT:
%    distFile - Name of the distribution file 
%    nSample -  Number of samples required
%    seed - random number seed   
%       
% OUTPUT:
%    sample - samples generated                                     
%
% EXAMPLES:
%      
% See also: DISTREAD

% Author: Durga Lal Shrestha
% UNESCO-IHE Institute for Water Education, Delft, The Netherlands
% eMail: durgals@hotmail.com
% Website: http://www.hi.ihe.nl/durgalal/index.htm
% Copyright 2004-2007 Durga Lal Shrestha.
% $First created: 10-Oct-2007
% $Revision: 1.0.0 $ $Date: 10-Oct-2007 11:58:10 $

% ***********************************************************************
%% INPUT ARGUMENTS CHECK
error(nargchk(1,3,nargin))

ns = 1;
seed = 0; % Set randn to its default initial state:
if nargin > 1
	ns = varargin{1};
end
if nargin > 2
	seed = varargin{2};
end
%% storing the values of the struct into  a cell array
parameters={'TT','TTI','TTM','CFMAX','FC','ECORR','ETF','LP','K','K1','ALPHA','BETA','CWH','CFR','CFLUX','PERC','RFCF','SFCF'}; % to be able to set the edit text to the value of each parameter without writing set alot of times
for i=1:18
    param=['distFile.limits.' parameters{i} '(1,1)']; % name of the parameter(the struct)
    distfile{i,1}= eval(param);        % Lower bound
    param=['distFile.limits.' parameters{i} '(1,2)']; % name of the parameter(the struct)
    distfile{i,2}= eval(param);        % Lower bound
    distribution=eval(['distFile.dist.' parameters{i}]); % name of the parameter(the struct)
    if distribution==1
        distfile{i,3}= 'urand';
    elseif distribution==2
        distfile{i,3}='urand';
    else
        distfile{i,3}='urand';
    end
end
dist = distfile;
npar =size(dist,1);
sample = zeros(ns,npar);
for i=1:npar
	funcname =dist{i,3}  ;                  % distStrSpilted{end};    % function name
    arg = [dist{i,1},dist{i,2}];
    % Check if it is function
    num=str2double(funcname);
    if ~isnan(num) % reading from var file, so use uniform distribution
        funcname='urand';   % if the function is not written it will be assumed 'urand'
        arg=[dist{i,1},dist{i,2}];
    end
	sample(:,i)= feval(funcname,arg,ns,seed);		
end


