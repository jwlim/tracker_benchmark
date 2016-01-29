function patch = affinePatch(wimgs, patchsize, patchnum)
% function patch = affinePatch(wimgs, patchsize, patchnum)
% obtain M patches in each candidate

% input --- 
% wimgs: the N candidate images (matrix)
% patchsize: the size of each patch
% patchnum: the number of patches in one candidate

% output ---
% patch: the patches for N candidates (vector)

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

n = size(wimgs,3);
patch = zeros(prod(patchsize), prod(patchnum), n);

for i = 1:n
    image = wimgs(:, :, i);
    blocksize = size(image);
    y = patchsize(1)/2;
    x = patchsize(2)/2;
    patch_centy = y : 2: (blocksize(1)-y);
    patch_centx = x : 2: (blocksize(2)-x); 
    l =1;
    for j = 1: patchnum(1)             % sliding window
        for k = 1:patchnum(2)
            data = image(patch_centy(j)-y+1 : patch_centy(j)+y, patch_centx(k)-x+1 : patch_centx(k)+x);
            patch(:, l, i) = reshape(data,numel(data),1);
            l = l+1;
        end
    end   
end