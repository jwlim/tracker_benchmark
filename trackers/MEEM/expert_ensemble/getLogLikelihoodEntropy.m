%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Implemetation of the tracker described in paper
%	"MEEM: Robust Tracking via Multiple Experts using Entropy Minimization", 
%   Jianming Zhang, Shugao Ma, Stan Sclaroff, ECCV, 2014
%	
%	Copyright (C) 2014 Jianming Zhang
%
%	This program is free software: you can redistribute it and/or modify
%	it under the terms of the GNU General Public License as published by
%	the Free Software Foundation, either version 3 of the License, or
%	(at your option) any later version.
%
%	This program is distributed in the hope that it will be useful,
%	but WITHOUT ANY WARRANTY; without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	GNU General Public License for more details.
%
%	You should have received a copy of the GNU General Public License
%	along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%	If you have problems about this software, please contact: jmzhang@bu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ll, entropy] = getLogLikelihoodEntropy (svm_score,label_prior,label_prior_neg)

num = numel(svm_score);

pos_score = normcdf(svm_score,0,1);
pos_score = pos_score.*label_prior(:)';

neg_score = 1 - pos_score;
neg_score = neg_score.*label_prior_neg(:)';
p_XY_Z = prod(repmat(neg_score(:),[1 num])+diag(pos_score - neg_score));
g_XY_Z = p_XY_Z/sum(p_XY_Z);
entropy = -g_XY_Z*log(g_XY_Z)';% in case g is 0
ll = log(max(p_XY_Z));
