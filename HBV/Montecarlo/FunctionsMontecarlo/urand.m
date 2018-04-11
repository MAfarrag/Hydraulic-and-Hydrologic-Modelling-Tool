function x = urand(range,varargin)
%URAND  random number from uniform distribution                     
%                                             
% USAGE:
%         x = URAND([a b])
%         x = URAND([a b],n)
%         x = URAND([a b],n,seed)
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
%    x=urand([125 200])
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
    a = range{1};
    b = range{2};
else
    a = range(1);
    b = range(2);
end
if ischar(a)
    a= str2double(a);
    b = str2double(b);
end
if a > b
	error('Lower range should be smaller than the upper range of variable in distribution file')
end
x = a + (b-a).* rand(n,1);
