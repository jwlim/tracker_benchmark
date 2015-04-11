
function [success_rates, thresholds, results] = ...
  ComputeSuccessRates(results, varargin)
%
% ComputeSuccessRates
% - compute the success rates for each tracking result in results.
%
% Usage:
% [success_rates, threshods] = ComputeSuccessRates(results, ...)
% - results : tracking results loaded by LoadTrackingResults().
% - success_rates : the success rates for each result.
% - thresholds : the threshold values used to compute success rate.
%
% [..., results] = ComputeSuccessRates(test_name, sequences, trackers, ...)
% - test_name, sequences, trackers : parameters for LoadTrackingResults().
% - results : the returned struct from LoadTrackingResults().
%
% Options:
% - thresholds : a threshold value array. (default: 0:0.05:1)

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)


%- Load the tracking results.
if ~isstruct(results) && numel(varargin) >= 2
  results = LoadTrackingResults(results, varargin{1}, varargin{2}, varargin{3:end});
  varargin = varargin(3:end);
end

%- Setup the options and constants.
if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'thresholds'), opt.thresholds = 0:0.05:1; end;

if isfield(results, 'data');
  lazy_load = false;
elseif isfield(results, 'load_cmds');
  lazy_load = true;
else
  error('invalid results - use LoadTrackingResults to load tracking results.');
end

num_trackers = numel(results.trackers);
num_seqs = numel(results.seqs);

thresholds = opt.thresholds;
num_thresholds = numel(thresholds);

gt_rects = cell(size(results.seqs));
for seq_idx = 1:num_seqs
  seq = results.seqs(seq_idx);
  gt_rects{seq_idx}.rect = seq.gt_rect;
  gt_rects{seq_idx}.range = eval(seq.gt_rect_range_str);
end

%- Compute the success rates for all trackers and sequences.
success_rates = nan(num_trackers, num_seqs, num_thresholds);

for tracker_idx = 1:num_trackers
  disp(['processing ' results.trackers{tracker_idx} ' ...']);
  
  for seq_idx = 1:num_seqs
    gt_rect = gt_rects{seq_idx};
%     fprintf('  %s [%d-%d]', results.seqs(seq_idx).name, gt_rect.range(1), gt_rect.range(end));
  
%     sum_success = zeros(size(thresholds));
%     sum_total = zeros(size(thresholds));
    success_rate = 0;
    num_trial = 0;
    
    if lazy_load
      res = eval(results.load_cmds{tracker_idx, seq_idx});
    else
      res = results.data{tracker_idx, seq_idx};
    end
    
    sum_success = zeros(size(thresholds));
    sum_total = zeros(size(thresholds));
    
    num_res = numel(res);
    for i = 1:num_res
      [success, total] = ComputeSuccessRateFromResults(res{i}, gt_rect, thresholds);
      sum_success = sum_success + success;
      sum_total = sum_total + total;
    end
    success_rate = success_rate + (sum_success ./ sum_total);
    num_trial = num_trial + 1;
    
%     success_rates{tracker_idx, seq_idx} = sum_success ./ sum_total;
    success_rates(tracker_idx, seq_idx, :) = success_rate ./ num_trial;
  end
end

end


function [num_success, num_total] = ComputeSuccessRateFromResults(result, gt_rect, thresholds)

rect = ConvertResultToRects(result);
rect_range = eval(result.seq_range_str);
[~, idx, idx_gt] = intersect(rect_range, gt_rect.range);
% if idx(1) ~= idx_gt(1) || idx(end) ~= idx_gt(end), fprintf('**'); end;
%   fprintf('  %d-%d, %d-%d,%d-%d\n', rect_range(1), rect_range(end), idx(1), idx(end), idx_gt(1), idx_gt(end));

overlap = ComputeRectOverlap(rect(idx, :), gt_rect.rect(idx_gt, :));

num_thresholds = numel(thresholds);
num_success = zeros(size(thresholds));
for i = 1:num_thresholds
  num_success(i) = sum(overlap > thresholds(i));
end
num_total = ones(size(thresholds)) * numel(idx);

% center = [rectMat(:,1)+(rectMat(:,3)-1)/2 rectMat(:,2)+(rectMat(:,4)-1)/2];
% 
% errCenter = sqrt(sum(((center(1:seq_length,:) - centerGT(1:seq_length,:)).^2),2));
% 
% index = rect_anno>0;
% idx=(sum(index,2)==4);
% % errCoverage = calcRectInt(rectMat(1:seq_length,:),rect_anno(1:seq_length,:));
% tmp = calcRectInt(rectMat(idx,:),rect_anno(idx,:));
% 
% errCoverage=-ones(length(idx),1);
% errCoverage(idx) = tmp;
% errCenter(~idx)=-1;
% 
% aveErrCoverage = sum(errCoverage(idx))/length(idx);
% 
% aveErrCenter = sum(errCenter(idx))/length(idx);

end


function overlap = ComputeRectOverlap(rect0, rect1)
%
%each row is a rectangle.
% A(i,:) = [x y w h]
% B(j,:) = [x y w h]
% overlap(i,j) = area of intersection
% normoverlap(i,j) = overlap(i,j) / (area(i)+area(j)-overlap)
%
% Same as built-in rectint, but faster and uses less memory (since avoids repmat).

if size(rect0, 1) < size(rect1, 1)
  warning('TrackerBenchmark:Generic', ...
    ['tracking results ' num2str(size(rect0, 1))
     ' are fewer than ground-truth markings ' num2str(size(rect1, 1)) '.']);
  rect0(size(rect1, 1), end) = 0;
end;
if size(rect0, 1) > size(rect1, 1)
  warning('TrackerBenchmark:Generic', ...
    ['tracking results ' num2str(size(rect0, 1)) ...
     ' are more than ground-truth markings ' num2str(size(rect1, 1)) '.']);
  rect0 = rect0(1:size(rect1, 1), :);
end;
% if size(rect0, 1) > size(rect1, 1), rect1(size(rect0, 1), end) = 0; end;

leftA = rect0(:,1);
bottomA = rect0(:,2);
rightA = leftA + rect0(:,3) - 1;
topA = bottomA + rect0(:,4) - 1;

leftB = rect1(:,1);
bottomB = rect1(:,2);
rightB = leftB + rect1(:,3) - 1;
topB = bottomB + rect1(:,4) - 1;

tmp = (max(0, min(rightA, rightB) - max(leftA, leftB)+1 )) .* (max(0, min(topA, topB) - max(bottomA, bottomB)+1 ));
areaA = rect0(:,3) .* rect0(:,4);
areaB = rect1(:,3) .* rect1(:,4);
overlap = tmp ./ (areaA + areaB - tmp);
end
