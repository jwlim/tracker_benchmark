function [X_pos X_neg] = affineTrainG(img, sz, opt, param, num_p, num_n, p0)
% function [X_pos X_neg] = affineTrainG(dataPath, sz, opt, param, num_p, num_n, forMat, p0)
% obtain positive and negative templates for the SDC

% input --- 
% dataPath: the path for the input images
% sz: the size of the tracking window
% opt: initial parameters
% param: the affine parameters
% num_p: the number for the positive templates
% num_n: the number for the negative templates
% forMat: the format of the input images in one video, for example '.jpg' '.bmp'.
% p0: aspect ratio in the first frame

% output ---
% X_pos: positive templates
% X_neg: negative templates

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

% img_color = imread([dataPath int2str(1) forMat]);
% if size(img_color,3)==3
%     img	= double(rgb2gray(img_color));
% else
%     img	= double(img_color);
% end

%%----------------- positive templates----------------%%
n = num_p;     % Sampling Number

param.param0 = zeros(6,n);     % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
sigma = [1, 1, .000, .000, .000, .000];
param.param = param.param0 + randMatrix.*repmat(sigma(:),[1,n]);

o = affparam2mat(param.param);     % Extract or Warp Samples which are related to above affine parameters
wimgs = warpimg(img, o, sz);

m = prod(opt.psize);
X_pos = zeros(m, n);
for i = 1: n
    X_pos(:,i) = reshape(wimgs(:,:,i), m, 1);
end

%%----------------- negative templates----------------%%
n = num_n;       % Sampling Number

param.param0 = zeros(6,n);      % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
sigma = [round(sz(2)*param.est(3)), round(sz(1)*param.est(3)*p0), .000, .000, .000, .000];
param.param = param.param0 + randMatrix.*repmat(sigma(:),[1,n]);

back = round(sigma(1)/4);
center = param.param0(1,1);
left = center - back;
right = center + back;
nono = param.param(1,:)<=right&param.param(1,:)>=center;
param.param(1,nono) = right;
nono = param.param(1,:)>=left&param.param(1,:)<center;
param.param(1,nono) = left;

back = round(sigma(2)/4);
center = param.param0(2,1);
top = center - back;
bottom = center + back;
nono = param.param(2,:)<=bottom&param.param(2,:)>=center;
param.param(2,nono) = bottom;
nono = param.param(2,:)>=top&param.param(2,:)<center;
param.param(2,nono) = top;


o = affparam2mat(param.param);    %Extract or Warp Samples which are related to above affine parameters
wimgs = warpimg(img, o, sz);

m = prod(opt.psize);
X_neg = zeros(m, n);
for i = 1: n
    X_neg(:,i) = reshape(wimgs(:,:,i), m, 1);
end