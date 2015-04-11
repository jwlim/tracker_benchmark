function wimg = warpimg(img, p, sz)
%% Copyright (C) 2005 Jongwoo Lim and David Ross.
%% All rights reserved.
% Thanks to Jongwoo Lim and David Ross for this code.  -- Wei Zhong.

if (nargin < 3)
    sz = size(img);
end
if (size(p,1) == 1)
    p = p(:);
end
w = sz(2);  h = sz(1);  n = size(p,2);
[x,y] = meshgrid([1:w]-w/2, [1:h]-h/2);

pos = reshape(cat(2, ones(h*w,1),x(:),y(:)) ...
    * [p(1,:) p(2,:); p(3:4,:) p(5:6,:)], [h,w,n,2]);

wimg = squeeze(interp2(img, pos(:,:,:,1), pos(:,:,:,2)));

wimg(find(isnan(wimg))) = 0;    

%   B = SQUEEZE(A) returns an array B with the same elements as
%   A but with all the singleton dimensions removed.  A singleton
%   is a dimension such that size(A,dim)==1;

