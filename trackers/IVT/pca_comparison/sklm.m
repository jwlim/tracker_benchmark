function [U, D, mu, n] = sklm(data, U0, D0, mu0, n0, ff, K)
% [U, D, mu, n] = sklm(data, U0, D0, mu0, n0, ff)
% [U, D, mu, n] = sklm(data, U0, D0, mu0, n0, ff, K)
%                 sklm(data)  % initialize
%    Sequential Karhunen-Loeve Transform
%    without mu0 or mu, data is assumed as zero-mean
%
%  required input
%    data (N,n) : initial/additional data
%    U0 (N,d) : old basis
%    D0 (d,1) : old singular values
%  optional input
%    mu0 (N,1) : old mean
%    n0 : number of previous data
%    ff : forgetting factor (def=1.0)
%    K : maximum number of basis vectors to retain
%
%  output
%    U (N,d+n) : new basis
%    D (d+n,1) : new singular values
%    mu (N,1) : new mean
%    n : new number of data

%% Copyright (C) 2005 Jongwoo Lim and David Ross.
%% All rights reserved.
 
% Based on algorithm from A. Levy & M. Lindenbaum 
%   "Sequential Karhunen-Loeve Basis Extraction and its Application
%    to Image", IEEE Trans. on Image Processing Vol. 9, No. 8, 
%    August 2000.

% $Id: sklm.m,v 1.2 2007-05-25 16:28:18 dross Exp $

[N,n] = size(data);

if (nargin == 1) || isempty(U0)
  if (size(data,2) == 1)
    mu = data; %reshape(data(:), size(mu0));
    U = zeros(size(data)); U(1)=1; D = 0;
  else
    mu = mean(data,2);
    data = data - repmat(mu,[1,n]);
    [U,D,V] = svd(data, 0);
    D = diag(D);
    % mu = reshape(mu, size(mu0));
  end
  if nargin >= 7
      keep = 1:min(K,length(D));
      D = D(keep);
      U = U(:,keep);
  end
else
  if (nargin < 6)  ff = 1.0;  end
  if (nargin < 5)  n0 = n;  end
  if (nargin >= 4 & isempty(mu0) == false)
    mu1 = mean(data,2);
    data = data - repmat(mu1,[1,n]);

    data = [data, sqrt(n*n0/(n+n0))*(mu0(:)-mu1)];
    mu = reshape((ff*n0*mu0(:) + n*mu1)/(n+ff*n0), size(mu0));
    n = n+ff*n0;
  end
  D = diag(D0);
  %[Q,R,E] = qr([ ff*U0*D, data ], 0); % old way
  
  data_proj = U0'*data; % new way
  data_res = data - U0*data_proj;
  [q, dummy] = qr(data_res, 0);
  Q = [U0 q];
  R = [ff*diag(D0) data_proj; zeros([size(data,2) length(D0)]) q'*data_res];

  [U,D,V] = svd(R, 0);
  D = diag(D);

  if nargin < 7
      cutoff = sum(D.^2) * 1e-6;
      keep = find(D.^2 >= cutoff);
  else
      keep = 1:min([K,length(D),n]);
  end
  D = D(keep);
  U = Q * U(:, keep);
end
