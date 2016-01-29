function [B,evals] = gram_pca(X,k)
% [B,evals] = gram_pca(X,k)
%
% Do PCA by taking the eigenvectors of X'*X, rather than X*X'.  This is
% much faster when X has fewer columns than rows.
%
% Arguments:
%    X = data, as column vectors
%    k = # of eigenvectors to keep
%
% Return Values:
%    B = PCA basis of k eigenvectors
%    evals = eigenvalues corresponding to columns of B

% Author: David Ross
% $Id: gram_pca.m,v 1.1 2007-05-24 02:44:24 dross Exp $

if nargin < 2
    k = min(size(X));
end

NUM_DATA = size(X,2);
X = X - repmat(mean(X,2),[1 NUM_DATA]);

% compute the eigendecomposition of the Gram matrix
[B,evals] = eig(X'*X/NUM_DATA);

% compute the eigenvectors of the covariance matrix,
% sorting them by decreasing eigenvalue
B = X*B(:,end:-1:(end-k+1));

% renormalize B
normB = sqrt(sum(B.^2,1));
B = B ./ (ones(size(B,1),1) * normB);

% reorder the eigenvalues by decreasing order
evals = diag(evals);
evals = evals(end:-1:(end-k+1));
