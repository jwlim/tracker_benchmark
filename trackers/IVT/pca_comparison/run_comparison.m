% run_comparison.m
%   Experiments to compare various algorithms for PCA, in terms of speed
%   and reconstruction accuracy.
%
% Author: David Ross
% $Id: run_comparison.m,v 1.2 2007-05-25 16:28:18 dross Exp $

% Parameters
NUM_EVECS = 16; % number of eigenvectors
BLOCK_SIZE = 5; % how often to update?
FF = 1; % forgetting factor

% Load the data
load sylvester_windows.mat;
% load minghsuan_windows.mat
% load dog_windows.mat;
% load ../davidin300.mat; data = double(data);
D = size(data,1)*size(data,2);
NUM_DATA = size(data,3);
data = reshape(data, [D NUM_DATA]);
data = data / max(data(:)); % scale data to between 0 and 1



% Build the batch PCA model
tic;
% [pca_basis, pca_evals] = truepca(data); % fast when data has fewer rows
% [pca_basis, pca_evals] = truepca_svd(data);
[pca_basis, pca_evals] = gram_pca(data); % fast when data has fewer columns
pca_basis = pca_basis(:,1:NUM_EVECS);
pca_evals = pca_evals(1:NUM_EVECS);
runtime_pca = toc
% Compute the PCA error
data_zm = data - repmat(mean(data,2), [1 NUM_DATA]);
diff = data_zm - pca_basis*(pca_basis'*data_zm);
err_pca = mean(abs(diff(:)))
rms_pca = sqrt(mean(diff(:).^2))


% Build the incremental Hall model.
tic;
U_hall = []; S_hall = []; mu_hall = zeros(D,1); n_hall = 0;
for ii = 1:BLOCK_SIZE:NUM_DATA
    index = ii:min((ii+BLOCK_SIZE-1), NUM_DATA);
    [U_hall, S_hall, mu_hall, n_hall] = ...
        hall(data(:,index), U_hall, S_hall, mu_hall, n_hall, NUM_EVECS);
    % throw away the extra vectors we don't need
    U_hall(:,NUM_EVECS+1:end) = [];
    S_hall(NUM_EVECS+1:end) = [];
end
runtime_hall = toc
% Compute the hall reconstruction error.
data_zm = data - repmat(mu_hall,[1 NUM_DATA]);
diff = data_zm - U_hall*(U_hall'*data_zm);
err_hall = mean(abs(diff(:)))
rms_hall = sqrt(mean(diff(:).^2))



% Build our incremental model.
tic;
U = []; S = []; mu = zeros(D,1); n = 0;
for ii = 1:BLOCK_SIZE:NUM_DATA
    index = ii:min((ii+BLOCK_SIZE-1), NUM_DATA);
    [U, S, mu, n] = sklm(data(:,index), U, S, mu, n, FF, NUM_EVECS);
    % throw away the extra vectors we don't need
    U(:,NUM_EVECS+1:end) = [];
    S(NUM_EVECS+1:end) = [];
end
runtime_ivt = toc
% Compute our reconstruction error.
data_zm = data - repmat(mu,[1 NUM_DATA]);
diff = data_zm - U*(U'*data_zm);
err_ivt = mean(abs(diff(:)))
rms_ivt = sqrt(mean(diff(:).^2))



% Some comparisons

%fprintf('compare eigenvalues\n\tPCA\tHall\tSKLM\n');
%disp([pca_evals S_hall S.^2/NUM_DATA])

fprintf('angle between subspaces\n\ttrue-Hall=%g  true-IVT=%g  Hall-IVT=%g\n', ...
    subspace(pca_basis, U_hall), subspace(pca_basis, U), ...
    subspace(U_hall, U));
