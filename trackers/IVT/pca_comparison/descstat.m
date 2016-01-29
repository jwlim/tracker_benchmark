function [varargout] = descstat(M)
% descstat(M)
% s = descstat(M)
% [min,mean,max,std] = descstat(M)
%
% Compute some descriptive statistics about the entries of M, namely
% the min, mean, max, and standard deviation.  If the number of return
% values is 0, then the statistics are printed on the screen.

% Author: David Ross
% $Id: descstat.m,v 1.1 2007-05-25 16:28:17 dross Exp $


x = full(min(M(:)));
y = full(mean(M(:)));
z = full(max(M(:)));
s = full(std(M(:)));

if nargout == 0
    disp(sprintf('min=%.3g\tmean=%.3g\tmax=%.3g\tstd=%.3g',x,y,z,s));
elseif nargout == 1
    varargout = {[x,y,z,s]};
else
    varargout = {x,y,z,s};
end