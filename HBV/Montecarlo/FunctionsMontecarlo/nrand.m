function x = nrand(range,varargin)
%NRAND  random number from normal distribution                     
%                                             
% USAGE:
%         x = NRAND([mu sigma])
%         x = NRAND([mu sigma],n)
%         x = NRAND([mu sigma],n,seed)
%                                             
% INPUT:
%    a - lower limit of the triangle                                  
%    b - upper limit of the trianlge 
%    n - number of sampling
%    s - random seed
%       
% OUTPUT:
%    x - random number                                                                 
%        
% EXAMPLES:
%    x=nrand([125 200])
%    ...
%      
% See also: 

% Author: Durga Lal Shrestha
% UNESCO-IHE Institute for Water Education, Delft, The Netherlands
% eMail: durgals@hotmail.com
% Website: durgalal.co.cc
% Copyright 2004-2007 Durga Lal Shrestha.
% $First created: 10-Oct-2007
% $Revision: 1.0.0 $ $Date: 10-Oct-2007 13:43:39 $

% ***********************************************************************
%% INPUT ARGUMENTS CHECK
error(nargchk(1,4,nargin))
n = 1;
%seed = 0; % Set randn to its default initial state:
if nargin > 1
	n = varargin{1};
end
if nargin > 2 && varargin{2} ~= 0
	seed = varargin{2};
	rand('seed', seed);
end

if iscell(range)
    mu = range{1};
    sigma = range{2};
else
    mu = range(1);
    sigma = range(2);
end
if ischar(a)
    mu= str2double(mu);
    sigma = str2double(sigma);
end
x = mu + sigma * randn(n,1);
