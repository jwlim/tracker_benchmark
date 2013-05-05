
function [avail_trackers] = SetupTrackers(trackers, varargin)
%
% SetupTrackers : setup necessary running environment for trackers.
%
% Usage:
%   SetupTrackers
%     - scan the tracker_dir and setup all available trackers.
%
%   SetupTrackers(<tracker_name>) OR
%   SetupTrackers({<tracker_name1>, ..., <tracker_nameN>})
%     - setup the listed trackers.
%
%   SetupTrackers(..., varargin) : options
%     - 'tracker_dir': the directory containing the trackers
%           (default: './trackers')
%
%   [avail_trackers] = SetupTrackers(...)
%     - returns the list of available trackers (among the given list).

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%

if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct('tracker_dir', './trackers');
  if ~isempty(varargin), opt = setfield(opt, varargin{:}); end;
end

if ~exist('trackers', 'var') || isempty(trackers)
  dir_trackers = dir(opt.tracker_dir);
  trackers = {};
  disp(['scanning ' opt.tracker_dir '...']);
  for i = 1:numel(dir_trackers)
    d = dir_trackers(i);
    if d.isdir && d.name(1) ~= '.' && ...
        exist([opt.tracker_dir '/' d.name '/Run_' d.name], 'file')
      trackers{end+1} = d.name;
    end
  end
  disp(['found ' num2str(numel(trackers)) ' trackers...']);
end
if ~iscell(trackers), trackers = {trackers}; end;

avail_trackers = {};
for tracker_idx = 1:numel(trackers)
  tracker_name = trackers{tracker_idx};
  old_dir = cd([opt.tracker_dir '/' tracker_name]);
  
  if ~exist(['Setup_' tracker_name])
    disp(['nothing to setup for ' tracker_name '...']);
    avail_trackers{end+1} = tracker_name;
  else
    disp(['setting up ' tracker_name '...']);
    try
      feval(['Setup_' tracker_name]);
      avail_trackers{end+1} = tracker_name;
    catch err
      warning('TrackerBenchmark:TrackerError', ...
        ['tracker setup error (' tracker_name ') - \n  ', ...
        err.identifier ': ' err.message]);
    end
  end
  cd(old_dir);
end

if nargout < 1, clear avail_trackers; end;

end
