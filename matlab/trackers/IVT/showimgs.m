function [img,nw] = showimgs(imgs, nw, basis)
% function [img,nw] = showimgs(imgs, nw/range, basis)
%   display or build a large stiched image from small images
%
%  required inputs
%    imgs (h,w,n) : grayscale image patches to be stiched
%  optional inputs
%    nw : number of patches in horizontal direction
%    / range [lb,ub] : range to be drawn
%    / range [nw,lb,ub] : nw and range to be drawn
%    basis (h,w,d) : when imgs are not real images but coefs (d,n)
%
%  outputs
%    img : stiched image
%    nw : (calculated) number of patches in horizontal direction

%% Copyright (C) 2005 Jongwoo Lim and David Ross.
%% All rights reserved.


  [h,w,n] = size(imgs);
  if (nargin > 2)  %% use basis
    n = w;
    dim = [size(basis,1), size(basis,2), n];
    basis = reshape(basis, [dim(1)*dim(2), h]);
    imgs = reshape(basis*reshape(imgs, [h, n]), dim);
    h = dim(1); w = dim(2);
  end
  range = [];
  if (nargin < 2)
    nw = floor(sqrt(n));
  else
    switch length(nw)
    case 1;
    case 2;  range = nw(1:2);  nw = floor(sqrt(n));
    otherwise;  range = nw(2:3);  nw = nw(1);
    end
  end
  nh = ceil(n/nw);

  img = zeros(nh*h, nw*w);
  x = 1; y = 1;
  for i = 1:n
    img(y:y+h-1, x:x+w-1) = imgs(:,:,i);
    x = x + w;
    if (x >= nw*w)
      x = 1; y = y + h;
    end
  end
  if (nargout < 1)
    if (isempty(range))
      imagesc(img);
    else
      imagesc(img, range);
    end
    colormap gray; axis image;
    clear img nw;
  end
