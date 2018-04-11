function [f x] = empcdf(varargin)
% EMPCDF  Computes empirical cumulative distribution function from given  
%         distribution of data.
%
% USAGE:
%       [f x] = empcdf(dist)
%      empcdf(axis_handle,dist)
%
% INPUT:
%    dist:  vector of distribution i.e. data values
% xis_handle: axis handle to plot the cumulative distribution function
%	  
% OUTPUT:        
%       f:  f is a vector of values of the empirical cdf evaluated at x.
%       x:  vector of values where empirical cdf values will be evaluated


% See also 

% Copyright 2004-2005 by Durga Lal Shrestha.
% eMail: durgals@hotmail.com
% $Date: 2005/07/05
% $Revision: 1.3.0 $ $Date: 2010/04/29 $
%
% ***********************************************************************
%% INPUT ARGUMENTS CHECK
%error(nargchk(1,1,nargin));
% Check if the first argument is handle axis
args = varargin;
[cax,args,nargs] = axescheck(args{:});
dist=args{1};
if ~isvector(dist)
    error('Invalid data size: input data must be vector')
end

% ************************************************************************
%% COMPUTATION
x = dist(:);
m = length(x);

cumulativeF = 1:m;
% Sort distribution.
xSorted = sort(x);
[xu, ind] = unique(xSorted);
p = cumulativeF(ind)/m;
p=p(:);
% Plot if no return values are requested
if nargout ==0
   if ~isempty(cax)
        stairs(cax,xu,p);
   else
       stairs(xu,p);
   end
   xlabel('x')
   ylabel('cdf')
else
    f=p;
    x=xu;
end



