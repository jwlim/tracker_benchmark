function [X_neg alpha_qq] = updateDic(img, sz, opt, param, num_n, p0, alpha_q, alpha_p, occMap)
% function [X_neg alpha_qq] = updateDic(dataPath, sz, opt, param, num_n, forMat, p0, f, alpha_q, alpha_p, occMap)
% update the negative templates in the SDC and the template histogram in the SGM

% input --- 
% dataPath: the path for the input images
% sz: the size of the tracking window
% opt: initial parameters
% param: the affine parameters
% num_n: the number for the negative templates
% forMat: the format of the input images in one video, for example '.jpg' '.bmp'.
% p0: aspect ratio in the first frame
% f: the frame index
% alpha_q: the template histogram in the current frame
% alpha_p: the histogram of the tracking result
% occMap: the occlusion condition

% output ---
% X_neg: the negative tempaltes in the SDC for the next frame
% alpha_qq: the template histogram in the SGM for the next frame

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

% img_color = imread([dataPath int2str(f) forMat]);
% if size(img_color,3)==3
%     img	= double(rgb2gray(img_color));
% else
%     img	= double(img_color);
% end

%%----------------- update negative samples in the SDC ----------------%%
n = num_n;    % Sampling Number

param.param0 = zeros(6,n);      % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
sigma = [round(sz(2)*param.est(3)), round(sz(1)*param.est(3)*p0), .000, .000, .000, .000];
param.param = param.param0 + randMatrix.*repmat(sigma(:),[1,n]);

back = round(sigma(1)/5);
center = param.param0(1,1);
left = center - back;
right = center + back;
nono = param.param(1,:)<=right&param.param(1,:)>=center;
param.param(1,nono) = right;
nono = param.param(1,:)>=left&param.param(1,:)<center;
param.param(1,nono) = left;

back = round(sigma(2)/5);
center = param.param0(2,1);
top = center - back;
bottom = center + back;
nono = param.param(2,:)<=bottom&param.param(2,:)>=center;
param.param(2,nono) = bottom;
nono = param.param(2,:)>=top&param.param(2,:)<center;
param.param(2,nono) = top;

o = affparam2mat(param.param);     % Extract or Warp Samples which are related to above affine parameters
wimgs = warpimg(img, o, sz);

m = prod(opt.psize);
X_neg = zeros(m, n);
for i = 1: n
    X_neg(:,i) = reshape(wimgs(:,:,i), m, 1);
end

%%----------------- update template histogram in the SGM ----------------%%
if occMap<=0.8
    gamma = 0.95;
    alpha_qq = alpha_q*gamma + alpha_p*(1 - gamma);
else
    alpha_qq = alpha_q;
end