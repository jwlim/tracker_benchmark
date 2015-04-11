
function [tsre_res, tsre, thresholds, results, opt] = ...
  ComputeTSRERates(results, varargin)
%
% ComputeTSRERates
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
% - thresholds : a threshold value array. (default: 0:0.1:1)

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)

% Run commands:
% ScanSequences
% global SEQUENCE_ANNOTATIONS
% tracker_names = { 'ASLA', 'BSBT', 'CPF', 'CSK', 'CT', 'CXT', 'DFT', 'FRAG', 'IVT', 'KMS', 'L1APG', 'LOT', 'LSHT', 'LSK', 'LSS', 'MIL', 'MS', 'MTT', 'OAB', 'ORIA', 'PD', 'RS', 'SBT', 'SCM', 'SMS', 'STRUCK', 'TLD', 'TM', 'VR', 'VTD', 'VTS' };
% tsre_results = LoadTrackingResults('TSRE7', 'V11_50', tracker_names);
%
% [tsre_res, tsre, thresholds, tsre_results] = ComputeTSRERates(tsre_results);
% tsre_res = ComputeTSRERates(tsre_results);
% save tsre_res.mat tsre_res tracker_names SEQUENCE_ANNOTATIONS tsre_results
%
% tsre_res_avg = squeeze(mean(tsre_res,3));
% [~,idx] = sort(-tsre_res_avg(6,:,1)'); idx = idx(1:end);
% plot(tsre_res_avg(:,idx,2), tsre_res_avg(:,idx,1), '.-', tsre_res_avg(6,idx,2),tsre_res_avg(6,idx,1), 'ko', 'MarkerSize', 10); legend(tracker_names(idx),'Location','NorthEastOutside'); axis([0,18,0,0.5])
%
% tsre_res_avg = squeeze(mean(tsre_res(:,:,SEQUENCE_ANNOTATIONS.V11_50_BCidx,:),3));
%
% PlotTrackingResults(tsre{1,1}{5,1})
% % {tracker_idx, seq_idx}{threshold_idx, shift_idx}

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
if ~isfield(opt, 'thresholds'), opt.thresholds = 0:0.1:1; end;
if ~isfield(opt, 'window_size'), opt.window_size = 30;
else disp(['setting window_size = ' num2str(opt.window_size)]); end;

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

% gt_rects = cell(size(results.seqs));
% for seq_idx = 1:num_seqs
%   seq = results.seqs(seq_idx);
%   gt_rects{i}.rect = seq.gt_rect;
%   gt_rects{i}.range = eval(seq.gt_rect_range_str);
% end

%- Compute the success rates for all trackers and sequences.
% success_rates = nan(num_trackers, num_seqs, num_thresholds);

tsre_res = zeros(num_thresholds, num_trackers, num_seqs, 2);
tsre = cell(num_trackers, num_seqs);
for tracker_idx = 1:num_trackers
  tracker_name = results.trackers{tracker_idx};
  fprintf(['processing ' tracker_name ' ']);
  
  for seq_idx = 1:num_seqs
    seq = results.seqs(seq_idx);
    gt_rect.rect = seq.gt_rect;
    gt_rect.range = eval(seq.gt_rect_range_str);
    fprintf('.');
%     gt_rect = gt_rects{seq_idx};
  
%     sum_success = zeros(size(thresholds));
%     sum_total = zeros(size(thresholds));
%     success_rate = 0;
%     num_trial = 0;
    
    if lazy_load
      res = eval(results.load_cmds{tracker_idx, seq_idx});
    else
      res = results.data{tracker_idx, seq_idx};
    end
    
    %- HACK for TSRE-7
    for i = 1:numel(res)
      res{i} = res{i}([1,2,3,4,10,11,13]);
      for j = 1:numel(res{i})
        if isempty(res{i}{j})
          warning(['empty seq: ' seq.name ' ' num2str(i) ',' num2str(j)]);
        end;
      end
    end
    
    %- These res should be from TSRE runs.
    [raw_overlaps, rects, rect_ranges] = ComputeRawOverlaps(res, gt_rect);
    [~, num_shifts] = size(raw_overlaps);
    
    tsres = cell(num_thresholds, num_shifts);
    scores = zeros(num_thresholds, num_shifts, 2);
    for i = 1:num_thresholds
      for j = 1:num_shifts
        %- Build virtual results for the threshold and compute TSRE.
        ret = ComputeTSRE(...
          raw_overlaps(:, j), rects(:, j), rect_ranges(:, j), ...
          thresholds(i), opt.window_size);
        scores(i, j, 1) = ret.score;
        scores(i, j, 2) = ret.num_restart;
        v_rect = ret.data;
        ret.test_name = 'virtual';
        ret.trackers = {tracker_name};
        ret.sequences = {seq.name};
        ret.seqs = seq;
        if num_shifts <= 1
          ret.data = {res(j)};
        else
          ret.data = {res{1}(j)};
        end
        ret.data{1}{1}.type = 'rect';
        ret.data{1}{1}.res = v_rect;
        tsres{i, j} = ret;
      end
    end
    tsre_res(:, tracker_idx, seq_idx, :) = mean(scores, 2);
    tsre{tracker_idx, seq_idx} = tsres;
    
%     sum_success = zeros(size(thresholds));
%     sum_total = zeros(size(thresholds));
%     
%     num_res = numel(res);
%     for i = 1:num_res
%       [success, total] = ComputeSuccessRateFromResults(res{i}, gt_rect, thresholds);
%       sum_success = sum_success + success;
%       sum_total = sum_total + total;
%     end
%     success_rate = success_rate + (sum_success ./ sum_total);
%     num_trial = num_trial + 1;
%     
% %     success_rates{tracker_idx, seq_idx} = sum_success ./ sum_total;
%     success_rates(tracker_idx, seq_idx, :) = success_rate ./ num_trial;
  end
  fprintf('\n');
end

end

function [raw_overlaps, rects, frm_ranges] = ComputeRawOverlaps(res, gt_rect)
num_segments = numel(res);
num_shifts = numel(res{1});  %- # of spatial shifts.
raw_overlaps = cell(num_segments, num_shifts);
frm_ranges = cell(num_segments, num_shifts);
rects = cell(num_segments, num_shifts);
for i = 1:num_segments
  for j = 1:num_shifts
    if num_shifts <= 1
      rij = res{i};
    else
      rij = res{i}{j};
    end
    if isempty(rij), continue; end;
    rect = ConvertResultToRects(rij);
    rect_range = eval(rij.seq_range_str);
    [~, idx, idx_gt] = intersect(rect_range, gt_rect.range);
    
    raw_overlaps{i, j} = ComputeRectOverlap(rect(idx, :), gt_rect.rect(idx_gt, :));
    frm_ranges{i, j} = rect_range(idx);
    rects{i, j} = rect(idx, :);
  end
end
end


function tsre = ComputeTSRE(overlaps, rects, rect_ranges, threshold, window_size)
%- Build a virtual result for the given threshold.
rng = rect_ranges{1};
overlap = overlaps{1};
avg_overlaps = zeros(size(overlap));
rect = rects{1};
num_restart = 0;
last_restart_frmno = 0;
for i = 1:numel(rng)
  frmno = rng(i);
  %- Ignore frames < window_size.
  if frmno < last_restart_frmno + window_size, continue; end;
  %- the main metric is the mean overlap over window_size recent frames.
  avg_overlap = mean(overlap(frmno - window_size < rng & rng <= frmno));
  avg_overlaps(frmno) = avg_overlap;
  if avg_overlap <= threshold %&& last_restart_frmno + window_size < frmno
    %- Restart! Find the segment to replace.
    for j = 1:numel(rect_ranges)
      if ~any(rect_ranges{j} == frmno), break; end;
    end
    seg_idx = j - 1;
    %- Find the elements in overlap that are to be replaced.
    [~, idx, idx_seg] = intersect(rng((i + 1):end), rect_ranges{seg_idx});
    overlap(i + idx) = overlaps{seg_idx}(idx_seg);
    rect(i + idx, :) = rects{seg_idx}(idx_seg, :);
    %- Statistics - count #restarts.
    num_restart = num_restart + 1;
    last_restart_frmno = frmno;
  end
end
tsre.overlap = overlap;
tsre.data = rect;
tsre.rng = rng;
tsre.score = mean(overlap);
tsre.num_restart = num_restart;
tsre.threshold = threshold;

tsre.avg_overlap = avg_overlaps;
%- Removed temporarily to reduce the output size.
% tsre.all_overlaps = zeros(numel(overlaps), numel(overlaps));
% for i = 1:numel(overlaps)
%   [~, idx, idx_seg] = intersect(rng, rect_ranges{i});
%   tsre.all_overlaps(i, idx) = overlaps{i}(idx_seg);
% end
end


% function [overlap, seq_idx] = FindOverlap(overlaps, rect_ranges, seq_idx, prev_seq_idx, frmno)
% rng = rect_ranges{seq_idx};
% if seg_idx == 1 || rng(1) <= frmno - window_size
%   overlap = overlaps{seq_idx}(frmno - window_size < rng & rng <= frmno);
% else
%   prev_rng = rect_ranges{prev_seq_idx};
%   overlap = [overlaps{prev_seq_idx}(d
% end
% 
% end


% function [num_success, num_total] = ComputeSuccessRateFromResults(result, gt_rect, thresholds)
% 
% rect = ConvertResultToRects(result);
% rect_range = eval(result.seq_range_str);
% [~, idx, idx_gt] = intersect(rect_range, gt_rect.range);
% 
% overlap = ComputeRectOverlap(rect(idx, :), gt_rect.rect(idx_gt, :));
% 
% num_thresholds = numel(thresholds);
% num_success = zeros(size(thresholds));
% for i = 1:num_thresholds
%   num_success(i) = sum(overlap > thresholds(i));
% end
% num_total = ones(size(thresholds)) * numel(idx);
% 
% % center = [rectMat(:,1)+(rectMat(:,3)-1)/2 rectMat(:,2)+(rectMat(:,4)-1)/2];
% % 
% % errCenter = sqrt(sum(((center(1:seq_length,:) - centerGT(1:seq_length,:)).^2),2));
% % 
% % index = rect_anno>0;
% % idx=(sum(index,2)==4);
% % % errCoverage = calcRectInt(rectMat(1:seq_length,:),rect_anno(1:seq_length,:));
% % tmp = calcRectInt(rectMat(idx,:),rect_anno(idx,:));
% % 
% % errCoverage=-ones(length(idx),1);
% % errCoverage(idx) = tmp;
% % errCenter(~idx)=-1;
% % 
% % aveErrCoverage = sum(errCoverage(idx))/length(idx);
% % 
% % aveErrCenter = sum(errCenter(idx))/length(idx);
% 
% end


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
