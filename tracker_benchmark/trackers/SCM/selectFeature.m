function P = selectFeature(AA_pos, AA_neg, param)
% function P = selectFeature(AA_pos, AA_neg, param)
% obtain the projection matrix P

% input --- 
% AA_pos: the normalized positive templates
% AA_neg: the normalized negative templates
% param: the parameters for sparse representation

% output ---
% P: the projection matrix

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

A = [AA_pos AA_neg];
L = [ones(size(AA_pos,2),1); (-1)*ones(size(AA_neg,2),1)];     % the label for each template, +1 for positive templates and -1 for negative templates
param.lambda = 0.001;
param.L = length(L);
w = mexLasso(L, A', param);
w = full(w);
sel = find(w~=0);
k = length(sel);             % the number of selected feature
P = zeros(size(AA_pos,1),k);
for i = 1:k
    P(sel(i),i) = 1;
end