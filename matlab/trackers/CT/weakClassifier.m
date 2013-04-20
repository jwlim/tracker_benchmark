function r = weakClassifier(posx,negx,samples,selector)
% $Description:
%    -Compute the weak classifier 
% $Agruments
% Input;
%    -posx: trained positive sample set. We utilize the posx.mu,posx.sig
%    -negx: trained negative ....                   ... negx.mu,negx.sig
%    -samples: tested samples. We utilize samples.feature
% Output:
%    -r: the computed classifier with respect to samples.feature
% $ History $
%   - Created by Kaihua Zhang, on April 22th, 2011

[row,col] = size(samples.feature);
mu1 = posx.mu(selector,:);
sig1= posx.sig(selector,:);
mu0 = negx.mu(selector,:);
sig0= negx.sig(selector,:);

mu1  = repmat(mu1,1,col);
sig1 = repmat(sig1,1,col);
mu0  = repmat(mu0,1,col);
sig0 = repmat(sig0,1,col);

n0= 1./(sig0+eps);
n1= 1./(sig1+eps);
e1= -1./(2*sig1.^2+eps);
e0= -1./(2*sig0.^2+eps);

x = samples.feature;
p0 = exp((x-mu0).^2.*e0).*n0;
p1 = exp((x-mu1).^2.*e1).*n1;

r  = (log(eps+p1)-log(eps+p0));

