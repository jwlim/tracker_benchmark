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


function tracker = createSvmTracker()
tracker = [];
tracker.sv_size = 500;% maxial 100 cvs
tracker.C = 100;
tracker.B = 80;% for tvm
tracker.B_p = 10;% for positive sv
tracker.lambda = 1;% for whitening
tracker.m1 = 1;% for tvm
tracker.m2 = 2;% for tvm
tracker.w = [];
tracker.w_smooth_rate = 0.0;
tracker.confidence = 1;
tracker.state = 0;
tracker.temp_count = 0;
tracker.output_feat_record = [];
tracker.feat_cache = [];
% tracker.experts = {};
tracker.confidence_exp = 1;
tracker.confidence = 1;
tracker.best_expert_idx = 1;
tracker.failure = false;
tracker.update_count = 0;