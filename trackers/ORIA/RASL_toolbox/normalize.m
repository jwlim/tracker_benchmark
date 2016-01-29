% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing

% Normalize each column of an array to be of unit length.
% Usage:
%   normalize(X) normalizes the columns of X.
%   normalize(X,2) normalizes the rows of X.
%   normalize(X,DIM) normalizes along dimension DIM of X.
function [normalizedData,normalizationFactor] = normalize(data, dimension)

if(nargin<2), 
    dimension = 1;
end

normalizationFactor = sqrt(sum(conj(data).*data, dimension));
resizeArray = ones(1, ndims(data));
resizeArray(dimension) = size(data, dimension);
normalizedData =  data ./ repmat(normalizationFactor, resizeArray);