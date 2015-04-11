function  VV = normVector(V)
% function VV = normVector(V)
% normalize each column for the input V

% input --- 
% V: the matrix that needs to normalize

% output ---
% VV: the normalized matrix

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

n = size(V,2);
VV =zeros(size(V));
for i = 1 : n
    if norm(V(:,i))~=0
        k = norm(V(:,i));
        VV(:,i) = V(:,i)/k;
    else
        VV(:,i) = V(:,i);
    end
end