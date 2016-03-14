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

function resample(I_vf,step_size)
global sampler;
global svm_tracker;
global config;

if nargin < 2
    step_size = max(round(sampler.template_size(1:2)/5),1);
end

feature_map = imresize(I_vf,config.ratio,'nearest');
step_size = max(round(min(sampler.template_size(1:2))/4),1);
step_size = step_size([1 1]);
rect=svm_tracker.output;

upleft = round([rect(1)-sampler.roi(1)+1,rect(2)-sampler.roi(2)+1]);
if ~((upleft(1)<1) || (upleft(2)<1) || (round(upleft(1)+rect(3)-1)>size(I_vf,2)) || (round(upleft(2)+rect(4)-1)>size(I_vf,1)))
    sub_win=I_vf(round(upleft(2): (upleft(2)+rect(4)-1)),round(upleft(1): (upleft(1)+rect(3)-1)),:);
    output_feat = imresize(sub_win,config.template_sz);
    svm_tracker.output_feat = output_feat(:)';
else    
    warning('tracking window outside of frame');
    keyboard
end

sampler.patterns_dt = [im2colstep(feature_map,sampler.template_size,[step_size, size(I_vf,3)])';...
    svm_tracker.output_feat];
temp = repmat(rect,[size(sampler.patterns_dt,1),1]);

[X Y] = meshgrid(1:step_size(2):size(feature_map,2)-sampler.template_size(2)+1,1:step_size(1):size(feature_map,1)-sampler.template_size(1)+1);
temp(1:end-1,1) = (X(:)-1)/config.ratio + sampler.roi(1);
temp(1:end-1,2) = (Y(:)-1)/config.ratio + sampler.roi(2);


%% compute cost table
left = max(round(temp(:,1)),round(rect(1)));
top = max(round(temp(:,2)),round(rect(2)));
right = min(round(temp(:,1)+temp(:,3)),round(rect(1)+rect(3)));
bottom = min(round(temp(:,2)+temp(:,4)),round(rect(2)+rect(4)));
ovlp = max(right - left,0).*max(bottom - top, 0);
sampler.costs = 1 - ovlp./(2*rect(3)*rect(4)-ovlp);

sampler.state_dt = temp;


end

