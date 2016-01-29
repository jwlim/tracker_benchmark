function [CX, sse] = vgg_kmeans(X, nclus, varargin)

% VGG_KMEANS    initialize K-means clustering
%               [CX, sse] = vgg_kmeans(X, nclus, optname, optval, ...)
%
%               - X: input points (one per column)
%               - nclus: number of clusters
%               - opts (defaults):
%                    maxiters (inf): maxmimum number of iterations
%                    mindelta (eps): minimum change in SSE per iteration
%                       verbose (1): 1=print progress
%
%               - CX: cluster centers
%               - sse: SSE

% Author: Mark Everingham <me@robots.ox.ac.uk>
% Date: 13 Jan 03

opts = struct('maxiters', inf, 'mindelta', eps, 'verbose', 1);
if nargin > 2
    opts=vgg_argparse(opts,varargin);
end

perm=randperm(size(X,2));
CX=X(:,perm(1:nclus));

sse0 = inf;
iter = 0;
while iter < opts.maxiters
    
    [CX, sse] = vgg_kmiter(X, CX);
    
    if opts.verbose
        fprintf('iter %d: sse = %g (%g secs)\n', iter, sse, t)
    end
    
    k = sse0-sse;
    if k < opts.mindelta
        break
    end
    
    sse0=sse;
    iter=iter+1;
    
end

