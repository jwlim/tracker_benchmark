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

function initSampler(init_rect,I_vf,I,use_color)
global config
global sampler;

init_rect_roi = init_rect;
init_rect_roi(1:2) = init_rect(1:2) - sampler.roi(1:2)+1;
template = I_vf (round(init_rect_roi(2):init_rect_roi(2)+init_rect_roi(4)-1),...
    round(init_rect_roi(1):init_rect_roi(1)+init_rect_roi(3)-1),:);
sampler.template = imresize(template,config.template_sz);
sampler.template_size = size(sampler.template);
sampler.template = sampler.template(:)';
sampler.template_width = init_rect(3);
sampler.template_height = init_rect(4);
if use_color
    sampler.feature_num = 4;
else
    sampler.feature_num = 2;
end

%% for collecting initial training data
resample(I_vf);




