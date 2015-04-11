
function results = LoadTrackingResults(test_name, sequences, trackers, varargin)
%
% LoadTrackingResults
% - loads tracking results from saved files.
%
% Usage:
% [results] = LoadTrackingResults(test_name, sequences, trackers, ...)
% - test_name : the test name.
% - sequences : a string or a cell array of test sequence names.
% - trackers : a string or a cell array of tracker names.
% - results : the struct with parameters and loaded tracking results.
%
% Options:
% - lazy_load : whether the tracking results are loaded now or later when needed.
%       (default: true)
% - data_dir : the directory containing the test sequences. (default: ../data)
% - result_dir : the directory where the test results are stored.
%       (default: ../results)
%
% Examples:
%   results = LoadTrackingResults('cvpr13_SRE', 'basketball', 'CSK')
%   results = LoadTrackingResults('cvpr13_SRE', {'IV','OCC','Jogging','Ironman'}, {'IVT','ASLA','CT','ST','VTS','VTD','MTT'})

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)


if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'data_dir'), opt.data_dir = '../data'; end;
if ~isfield(opt, 'result_dir'), opt.result_dir = '../results'; end;
if ~isfield(opt, 'lazy_load'), opt.lazy_load = true; end;

if isempty(opt.result_dir) || ~exist(opt.result_dir, 'dir')
  error(['output directory (' opt.result_dir ') does not exist.']);
end

if ~iscell(trackers), trackers = {trackers}; end;
if ~iscell(sequences), sequences = {sequences}; end;

[seqs, seq_maps] = LoadSequenceConfig(sequences, opt);
num_sequences = numel(seqs);
num_trackers = numel(trackers);

results.test_name = test_name;
results.trackers = trackers;
results.sequences = sequences;
results.seqs = seqs;
results.seq_maps = seq_maps;
if opt.lazy_load
  results.load_cmds = cell(num_trackers, num_sequences);
else
  results.data = cell(num_trackers, num_sequences);
end
results.opt = opt;

for seq_idx = 1:num_sequences
  seq = seqs(seq_idx);
  
  for tracker_idx = 1:num_trackers
    tracker_name = trackers{tracker_idx};
    
    path = [opt.result_dir '/' test_name '/' seq.name '_' tracker_name '.mat'];
    load_cmd = ['getfield(load(''' path '''), ''results'')'];
    
    if opt.lazy_load
      results.load_cmds{tracker_idx, seq_idx} = load_cmd;
    else
      disp(['loading ' path '.']);
      results.data{tracker_idx, seq_idx} = eval(load_cmd);
    end
  end
end

end
