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

function initSvmTracker (sample,label,fuzzy_weight)

global svm_tracker;
global experts;


sample_w = fuzzy_weight;
       
pos_mask = label>0.5;
neg_mask = ~pos_mask;
s1 = sum(sample_w(pos_mask));
s2 = sum(sample_w(neg_mask));
        
sample_w(pos_mask) = sample_w(pos_mask)*s2;
sample_w(neg_mask) = sample_w(neg_mask)*s1;
        
C = max(svm_tracker.C*sample_w/sum(sample_w),0.001);
        
svm_tracker.clsf = svmtrain( sample, label,'boxconstraint',C,'autoscale','false');
        
svm_tracker.clsf.w = svm_tracker.clsf.Alpha'*svm_tracker.clsf.SupportVectors;
svm_tracker.w = svm_tracker.clsf.w;
svm_tracker.Bias = svm_tracker.clsf.Bias;
svm_tracker.sv_label = label(svm_tracker.clsf.SupportVectorIndices,:);
svm_tracker.sv_full = sample(svm_tracker.clsf.SupportVectorIndices,:);
        
svm_tracker.pos_sv = svm_tracker.sv_full(svm_tracker.sv_label>0.5,:);
svm_tracker.pos_w = ones(size(svm_tracker.pos_sv,1),1);
svm_tracker.neg_sv = svm_tracker.sv_full(svm_tracker.sv_label<0.5,:);
svm_tracker.neg_w = ones(size(svm_tracker.neg_sv,1),1);
        
% compute real margin
pos2plane = -svm_tracker.pos_sv*svm_tracker.w';
neg2plane = -svm_tracker.neg_sv*svm_tracker.w';
svm_tracker.margin = (min(pos2plane) - max(neg2plane))/norm(svm_tracker.w);
        
% calculate distance matrix
if size(svm_tracker.pos_sv,1)>1
    svm_tracker.pos_dis = squareform(pdist(svm_tracker.pos_sv));
else
    svm_tracker.pos_dis = inf;
end
svm_tracker.neg_dis = squareform(pdist(svm_tracker.neg_sv)); 
        
%% intialize tracker experts
experts{1}.w = svm_tracker.w;
experts{1}.Bias = svm_tracker.Bias;
experts{1}.score = [];
experts{1}.snapshot = svm_tracker;
        
experts{2} = experts{1};