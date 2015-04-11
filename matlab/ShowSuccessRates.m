
function [success_rates, thresholds, results] = ...
  ShowSuccessRates(results, varargin)
%
% ShowSuccessRates
% - shows the success rate tables for the trackers in results.
%
% Usage:
% ShowSuccessRates(results, success_rates, thresholds, ...)
% - results : the tracking results loaded by LoadTrackingResults().
% - success_rates, thresholds : the returned values from ComputeSuccessRates().
%
% [success_rates, threshods] = ShowSuccessRates(results, ...)
%
% [..., results] = ShowSuccessRates(test_name, sequences, trackers, ...)
%
% Options:
% - display_seqs : the sequence or attribute name(s) to show. (default: '')
% - sort : the flag if the results are sorted -
%     'none', 'ascend', 'descend'. (default: 'descend')
% - max_tracker : the number of trackers to show in plot. (default: off)

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)


if ~isstruct(results) && numel(varargin) >= 2
  results = LoadTrackingResults(results, varargin{1}, varargin{2}, varargin{3:end});
  success_rates = [];
  thresholds = [];
  varargin = varargin(3:end);
elseif numel(varargin) >= 2 && isreal(varargin{1}) && isreal(varargin{2})
  success_rates = varargin{1};
  thresholds = varargin{2};
  varargin = varargin(3:end);
else
  success_rates = [];
  thresholds = [];
end

if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'display_seqs'), opt.display_seqs = ''; end;
if ~isfield(opt, 'display_types'), opt.display_types = 'auc'; end;
if ~isfield(opt, 'sort'), opt.sort = 'descend'; end;
if ~isfield(opt, 'max_trackers'), opt.max_trackers = 0; end;

if isempty(success_rates)
  [success_rates, thresholds] = ComputeSuccessRates(results, opt);
end

trackers = results.trackers;

avail_seqs = {results.seqs(:).name};
display_seqs = results.sequences;
if ~isempty(opt.display_seqs)
  display_seqs = opt.display_seqs;
end
if ~iscell(display_seqs), display_seqs = {display_seqs}; end;

seq_idx = cell(size(display_seqs));
for i = 1:numel(display_seqs)
  seq_names = FindSequenceNames(display_seqs{i});
  seq_idx{i} = FindSeqIdx(avail_seqs, seq_names);
  if any(seq_idx{i} < 1)
    error(['seq ' seq_names(seq_idx{i} < 1) ' not found ...']);
  end
end

display_types = opt.display_types;
if ~iscell(display_types), display_types = {display_types}; end;
display_type_idx = zeros(size(display_types));
for i = 1:numel(display_types)
  if ~ischar(display_types{i})
    display_type_idx(i) = find(abs(thresholds - display_types{i}) < 1e-6);
  end
end

num_trackers = numel(trackers);
num_display_seqs = numel(display_seqs);
num_display_types = numel(display_types);
num_thresholds = numel(thresholds);
average_rates = zeros(num_trackers, num_display_seqs, num_thresholds);
auc = zeros(num_trackers, num_display_seqs);
for i = 1:num_display_seqs
  average_rates(:, i, :) = squeeze(mean(success_rates(:, seq_idx{i}, :), 2));
  auc(:, i) = mean(average_rates(:, i, :), 3);
end
% average_rates = squeeze(mean(success_rates, 2));
% auc = mean(average_rates, 2);

if strcmp(opt.sort, 'ascend') || strcmp(opt.sort, 'descend')
  [auc, idx] = sort(auc, 1, opt.sort);
  average_rates = average_rates(idx, :, :);
  trackers = trackers(idx);
elseif ~strcmp(opt.sort, 'none')
  warning('TrackerBenchmark:InvalidOption', ...
    ['invalid sort option (' opt.sort ') - ignored.']);
end
if opt.max_trackers > 0
  average_rates = average_rates(1:opt.max_trackers, :);
  trackers = trackers(1:opt.max_trackers);
end

for j = 1:num_display_seqs
  fprintf('\t%s', display_seqs{j});
  for k = 2:num_display_types
    fprintf('\t');
  end
end
fprintf('\n');
for j = 1:num_display_seqs
  for k = 1:num_display_types
    if ischar(display_types{k})
      fprintf('\t%s', display_types{k});
    else
      fprintf('\tt=%.2f', display_types{k});
    end
  end
end
fprintf('\n');
for i = 1:num_trackers
  fprintf('%s:', trackers{i});
  for j = 1:num_display_seqs
    for k = 1:num_display_types
      if strcmpi(display_types{k}, 'auc')
        fprintf('\t%.3f', auc(i, j));
      elseif display_type_idx(k) > 0
        fprintf('\t%.3f', average_rates(i, j, display_type_idx(k)));
      else
        fprintf('\t--');
      end
    end
  end
  fprintf('\n');
end

if nargout < 1
  clear success_rates thresholds results;
end
end


function seq_idx = FindSeqIdx(avail_seqs, seq_names)

seq_idx = zeros(size(seq_names));
for i = 1:numel(seq_names)
  seq_idx(i) = find(ismember(avail_seqs, seq_names{i}));
end
end
