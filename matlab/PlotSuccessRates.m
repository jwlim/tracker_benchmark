
function [success_rates, thresholds, results] = ...
  PlotSuccessRates(results, varargin)
%
% PlotSuccessRates
% - plots the success rate graphs for the trackers in results.
%
% Usage:
% PlotSuccessRates(results, success_rates, thresholds, ...)
% - results : the tracking results loaded by LoadTrackingResults().
% - success_rates, thresholds : the returned values from ComputeSuccessRates().
%
% [success_rates, threshods] = PlotSuccessRates(results, ...)
%
% [..., results] = PlotSuccessRates(test_name, sequences, trackers, ...)
%
% Options:
% - display_seqs : the sequence or attribute name(s) to show. (default: '')
% - sort : the flag if the results are sorted -
%     'none', 'ascend', 'descend'. (default: 'descend')
% - max_tracker : the number of trackers to show in plot. (default: off)
% - plot_opt : a cell array with the Matlab plot function options.
% - legend_opt : a cell array with the Matlab legend function options.

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)


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
if ~isfield(opt, 'sort'), opt.sort = 'descend'; end;
if ~isfield(opt, 'max_trackers'), opt.max_trackers = 0; end;
if ~isfield(opt, 'plot_opt'), opt.plot_opt = {}; end;
if ~isfield(opt, 'legend_opt'), opt.legend_opt = {}; end;

if isempty(success_rates)
  [success_rates, thresholds] = ComputeSuccessRates(results, opt);
end

trackers = results.trackers;
num_trackers = numel(trackers);

avail_seqs = {results.seqs(:).name};
display_seqs = results.sequences;
if ~isempty(opt.display_seqs)
  display_seqs = opt.display_seqs;
end
if ~iscell(display_seqs), display_seqs = {display_seqs}; end;

seq_names = FindSequenceNames(display_seqs);
seq_idx = FindSeqIdx(avail_seqs, seq_names);
if any(seq_idx < 1)
  error(['seq ' seq_names(seq_idx < 1) ' not found ...']);
end
average_rates = permute(mean(success_rates(:, seq_idx, :), 2), [1, 3, 2]);
auc = mean(average_rates, 2);

if strcmp(opt.sort, 'ascend') || strcmp(opt.sort, 'descend')
  [auc, idx] = sort(auc, 1, opt.sort);
  average_rates = average_rates(idx, :);
  trackers = trackers(idx);
elseif ~strcmp(opt.sort, 'none')
  warning('TrackerBenchmark:InvalidOption', ...
    ['invalid sort option (' opt.sort ') - ignored.']);
end
for i = 1:num_trackers
  trackers{i} = [' ' trackers{i} ' (' sprintf('%.3f', auc(i)) ')'];
end
if opt.max_trackers > 0
  average_rates = average_rates(1:opt.max_trackers, :);
  trackers = trackers(1:opt.max_trackers);
end

figure(gcf);
clf;
plot(thresholds, average_rates, opt.plot_opt{:});

legend(trackers, opt.legend_opt{:});

title(regexprep(['Success plot of ', results.test_name, '  -  ', ...
  ConcatWithCommas(display_seqs)], '_', '\\_'));

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


function str = ConcatWithCommas(seqs)
str = [seqs{1}, sprintf(', %s', seqs{2:end})];
end
