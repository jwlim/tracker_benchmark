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

function expertsDo(I_vf,lambda,sigma)
global sampler;
global svm_tracker;
global experts;
global config

roi_reg = sampler.roi; roi_reg(3:4) = sampler.roi(3:4)-sampler.roi(1:2);

feature_map = imresize(I_vf,config.ratio,'nearest'); % 
ratio_x = size(I_vf,2)/size(feature_map,2);
ratio_y = size(I_vf,1)/size(feature_map,1);
% tmp_mask = zeros(sampler.template_size(1:2));
% tmp_mask(1:2:end,1:2:end) = 1;
% tmp_mask = repmat(tmp_mask,[1,1,size(I_vf,3)]);
patterns = im2colstep(feature_map,[sampler.template_size(1:2), size(I_vf,3)],[1, 1, size(I_vf,3)]);
% patterns = patterns(tmp_mask(:)>0,:); % columnwise

x_sz = size(feature_map,2)-sampler.template_size(2)+1;
y_sz = size(feature_map,1)-sampler.template_size(1)+1;
[X Y] = meshgrid(1:x_sz,1:y_sz);
temp = repmat(svm_tracker.output,[numel(X),1]);
temp(:,1) = (X(:)-1)*ratio_x + sampler.roi(1);
temp(:,2) = (Y(:)-1)*ratio_y + sampler.roi(2);
state = temp;

%% select expert

label_prior = fspecial('gaussian',[y_sz,x_sz],sigma);
label_prior_neg = ones(size(label_prior))/numel(label_prior);


% compute log likelihood and entropy
n = numel(experts);
score_temp = zeros(n,1);
rect_temp = zeros(n,4);

if config.debug
    loglik_vec=[];
    ent_vec=[];
    figure(3)
end

kernel_size = sampler.template_size(1:2)*0.5;%half template size;
rad = 0.5*min(sampler.template_size(1:2));

mask_temp = zeros(y_sz,x_sz);
idx_temp = [];
svm_scores = [];
svm_score = {};
svm_density = {};
peaks_collection = {};
peaks = zeros(n,2);
peaks_pool = [];

[X Y] = meshgrid(1:round(rad):x_sz,1:round(rad):y_sz);

for i = 1:n
    % find the highest peak
    svm_score{i} = -(experts{i}.w*patterns+experts{i}.Bias);
    svm_density{i} = normcdf(svm_score{i},0,1).*label_prior(:)';
    [val idx] = max(svm_density{i});
    best_rect = state(idx,:);
    rect_temp(i,:) = best_rect;
    svm_scores(i) = svm_score{i}(idx);
    idx_temp(i) = idx;
    [r c] = ind2sub(size(mask_temp),idx);
    peaks(i,:) = [r c];
    
    % find the possible peaks
    
    density_map = reshape(svm_density{i},y_sz,[]);
    density_map = (density_map - min(density_map(:)))/(max(density_map(:)) - min(density_map(:)));
    mm = (imdilate(density_map,strel('square',round(rad))) == density_map) & density_map > 0.9;
    [rn cn] = ind2sub(size(mask_temp),find(mm));
    peaks_pool = cat(1,peaks_pool,[rn cn]);  
    peaks_collection{i} = [rn cn];
%     mask_temp(r,c) = 1;
end
peaks_orig = peaks;
% merg peaks
peaks = mergePeaks(peaks,rad);
peaks_pool = mergePeaks(peaks_pool,rad);
mask_temp(sub2ind(size(mask_temp),round(peaks(:,1)),round(peaks(:,2)))) = 1;

%%
for i = 1:n

    dis = pdist2(peaks_pool,peaks_collection{i});
    [rr cc] = ind2sub([size(peaks_pool,1),size(peaks_collection{i},1)],find(dis < rad));
    [C,ia,ic] = unique(cc);
    peaks_temp = peaks_pool;
    peaks_temp(rr(ia),:) = peaks_collection{i}(cc(ia),:);
    mask = zeros(size(mask_temp));
    mask(sub2ind(size(mask_temp),round(peaks_temp(:,1)),round(peaks_temp(:,2)))) = 1;
    mask = mask>0;

    [loglik ent] = getLogLikelihoodEntropy(svm_score{i}(mask(:)),label_prior(mask(:)),label_prior_neg(mask(:)));
    if config.debug
        loglik_vec(end+1) = loglik;
        ent_vec(end+1) = ent;
        subplot(2,4,i)    
        imagesc(reshape(svm_score{i},y_sz,[]));
        colorbar
        subplot(2,4,i+4)
        imagesc(reshape(mask,y_sz,[]))
    end
    
    experts{i}.score(end+1) =  loglik - lambda*ent;
    score_temp(i) = sum(experts{i}.score(max(end+1-config.entropy_score_winsize,1):end));    
end

%%
svm_tracker.best_expert_idx = numel(score_temp);
if numel(score_temp) >= 2 && config.use_experts
    [val idx] = max(score_temp(1:end-1));
    if score_temp(idx) > score_temp(end) && size(peaks,1) > 1%svm_scores(idx) > config.svm_thresh
        % recover previous version
%         output = svm_tracker.output;
%         experts{end}.snapshot = svm_tracker;
        experts{end}.score = experts{idx}.score;
        svm_tracker = experts{idx}.snapshot;
%         svm_tracker.output = rect_temp(idx,:);
        svm_tracker.best_expert_idx = idx;
%         experts([idx end]) = experts([end idx]);
    end
end
svm_tracker.output = rect_temp(svm_tracker.best_expert_idx,:);
svm_tracker.confidence = svm_scores(svm_tracker.best_expert_idx);
svm_tracker.output_exp = rect_temp(end,:);
svm_tracker.confidence_exp = svm_scores(end);

% svm_tracker.w = experts{svm_tracker.best_expert_idx}.w;
% svm_tracker.Bias = experts{svm_tracker.best_expert_idx}.Bias;

 
if config.debug

    for i = 1:n
        subplot(2,4,i)
        if i == svm_tracker.best_expert_idx
            color = [1 0 0];
        else
            color = [1 1 1];
        end
        text(0,1,num2str(experts{i}.score(end)),'BackgroundColor',color);
        text(15,1,num2str(score_temp(i)),'BackgroundColor',color);
        text(0,3,num2str(loglik_vec(i)),'BackgroundColor',color);
        text(15,3,num2str(ent_vec(i)),'BackgroundColor',color);
    end
    figure(2)
    imagesc(mask_temp)
    figure(1)
end


%% update training sample
% approximately 200 training samples
step = round(sqrt((y_sz*x_sz)/120));
mask_temp = zeros(y_sz,x_sz);
mask_temp(1:step:end,1:step:end) = 1;
mask_temp = mask_temp > 0;
sampler.patterns_dt = patterns(:,mask_temp(:))';
sampler.state_dt = state(mask_temp(:),:);
sampler.costs = 1 - getIOU(sampler.state_dt,svm_tracker.output);
if min(sampler.costs)~=0
    sampler.state_dt = [sampler.state_dt; rect_temp(svm_tracker.best_expert_idx,:)];
    sampler.patterns_dt = [sampler.patterns_dt; patterns(:,idx_temp(svm_tracker.best_expert_idx))'];
    sampler.costs = [sampler.costs;0];
end

% better localization and add the predicted state and pattern
% output = svm_tracker.output;
% output(1:2) = output(1:2) - sampler.roi(1:2) + 1;
% [shift pattern_loc] = localize(I_vf,...
%     -reshape(svm_tracker.w,config.template_sz(1),config.template_sz(2),[]),...
%     output,5);
% svm_tracker.output(1:2) = svm_tracker.output(1:2) + shift;

end


function merged_peaks = mergePeaks(peaks, rad)

dis_mat = pdist2(peaks,peaks) + diag(inf*ones(size(peaks,1),1));
while min(dis_mat(:)) < rad && size(peaks,1) > 1
    [val idx] = min(dis_mat(:));
    [id1 id2] = ind2sub(size(dis_mat),idx);
    merged_peak = 0.5*(peaks(id1,:) + peaks(id2,:));
    peaks([id1 id2],:) = [];
    peaks = [peaks;merged_peak];
    dis_mat = pdist2(peaks,peaks) + diag(inf*ones(size(peaks,1),1));
end

merged_peaks = peaks;

end

