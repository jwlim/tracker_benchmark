% 
% Usage:   alpha=mexLasso(X,D,param);
%
% Name: mexLasso
%
% Description: mexLasso is an efficient implementation of the
%     LARS algorithm for solving the Lasso or the Elastic-Net. 
%     It is optimized for solving a large number of small or medium-sized 
%     decomposition problem (and not for a single large one).
%     It aims at addressing the following problems
%     for all columns x_i of X, 
%       1) when param.mode=0
%         min_{alpha_i} ||x_i-Dalpha_i||_2^2 s.t. ||alpha_i||_1 <= lambda
%       2) when param.mode=1
%         min_{alpha_i} ||alpha_i||_1 s.t. ||x_i-Dalpha_i||_2^2 <= lambda
%       3) when param.mode=2
%         min_{alpha_i} (1/2)||x_i-Dalpha_i||_2^2 + lambda||alpha_i||_1 + (1/2)lambda2||alpha_i||_2^2
%     Eventually, when param.pos=true, it solves the previous problems
%     with positivity constraints on the vectors alpha_i
%
% Inputs: X:  double m x n matrix   (input signals)
%               m is the signal size
%               n is the number of signals to decompose
%         D:  double m x p matrix   (dictionary)
%               p is the number of elements in the dictionary
%         param: struct
%               param.lambda  (parameter)
%               param.lambda2 (optional, elastic-net parameter, 0 by default)
%               param.L (optional, maximum number of elements of each 
%                 decomposition)
%               param.expand (optional, pre-compute the Gram Matrix,
%                 false by default)
%               param.pos (optional, adds positivity constraints on the
%                 coefficients, false by default)
%               param.mode (see above, by default: 2)
%               param.numThreads (optional, number of threads for exploiting
%                 multi-core / multi-cpus. By default, it takes the value -1,
%                 which automatically selects all the available CPUs/cores).
%
% Output: alpha: double sparse p x n matrix (output coefficients)
%
% Note: this function admits a few experimental usages, which have not
%     been extensively tested:
%         - single precision setting (even though the output alpha is double 
%           precision)
%
% Author: Julien Mairal, 2009
% Thanks to Julien Mairal for this code.  -- Wei Zhong.


