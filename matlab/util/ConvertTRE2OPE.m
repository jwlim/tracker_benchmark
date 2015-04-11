
function ope_results = ConvertTRE2OPE(tre_results, varargin)
%
% ConvertTRE2OPE
% - extract the ope results from the give tre results.
%
% Usage:

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)


%- Load the tracking results.
if ~isstruct(tre_results) && numel(varargin) >= 2
  tre_results = LoadTrackingResults(tre_results, varargin{1}, varargin{2}, varargin{3:end});
  varargin = varargin(3:end);
end

if isfield(tre_results, 'data');
  lazy_load = false;
elseif isfield(tre_results, 'load_cmds');
  lazy_load = true;
else
  error('invalid results - use LoadTrackingResults to load tracking results.');
end

num_trackers = numel(tre_results.trackers);
num_seqs = numel(tre_results.seqs);

ope_results = rmfield(tre_results, 'load_cmds');
ope_results.data = cell(num_trackers, num_seqs);

for tracker_idx = 1:num_trackers
  disp(['processing ' tre_results.trackers{tracker_idx} ' ...']);
  
  for seq_idx = 1:num_seqs
    if lazy_load
      res = eval(tre_results.load_cmds{tracker_idx, seq_idx});
    else
      res = tre_results.data{tracker_idx, seq_idx};
    end
    
    if isempty(res(1)),
      warning(['empty reslut: ', tre_results.seqs(seq_idx).name]);
    end
    ope_results.data{tracker_idx, seq_idx} = res(1);
  end
end

end
