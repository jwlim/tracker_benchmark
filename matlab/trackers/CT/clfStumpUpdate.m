function [mu1,sig1,mu0,sig0] = clfStumpUpdate(posx,negx,mu1,sig1,mu0,sig0,lRate)
% $Description:
%    -Update the mean and variance of the gaussian stump classifier
% $Agruments
% Input;
%    -posx: positive sample set. We utilize the posx.feature
%    -negx: negative ....                   ... negx.feature
%    -mu1: mean of positive.feature M x 1 vector
%    -sig1:standard deviation of positive.feature M x 1 vector 
%    -mu0 : ...    negative
%    -sig0: ...    negative
%    -lRate: constant rate
% Output:
%    -mu1: updated mean of positive.feature
%    -sig1:...     standard deviation ....
%    -mu0: updated mean of negative.feature
%    -sig0:....    standard variance ...
% $ History $
%   - Created by Kaihua Zhang, on April 22th, 2011
%   - Changed by Kaihua Zhang, on May 18th, 2011
%--------------------------------------------------
[prow,pcol] = size(posx.feature);
pmu = mean(posx.feature,2);
posmu = repmat(pmu,1,pcol);
sigm1 = mean((posx.feature-posmu).^2,2);

nmu = mean(negx.feature,2);
[nrow,ncol] = size(negx.feature);
negmu = repmat(nmu,1,ncol);
sigm0 = mean((negx.feature-negmu).^2,2);
%------------------------------------------Online MIL update method
% sig1= lRate*sig1+ (1-lRate)*sqrt(sigm1);
% mu1 = lRate*mu1 + (1-lRate)*pmu;
% 
% sig0= lRate*sig0+ (1-lRate)*sqrt(sigm0);
% mu0 = lRate*mu0 + (1-lRate)*nmu;
%---------------------------------------------
%------------------------------------------Our update method
sig1= sqrt(lRate*sig1.^2+ (1-lRate)*sigm1+lRate*(1-lRate)*(mu1-pmu).^2);
mu1 = lRate*mu1 + (1-lRate)*pmu;

sig0= sqrt(lRate*sig0.^2+ (1-lRate)*sigm0+lRate*(1-lRate)*(mu0-nmu).^2);
mu0 = lRate*mu0 + (1-lRate)*nmu;