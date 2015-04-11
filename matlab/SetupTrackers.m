
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

global TRACKER_DIRS;  % TRACKER_DIRS is tracker_name to directory map.

%- Process options.
if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  if ~isempty(varargin), opt = setfield(opt, varargin{:}); end;
end
if ~isfield(opt, 'tracker_dir'), opt.tracker_dir = './trackers'; end;

%- If no arguments are given, scan the trackers directory.
if ~exist('trackers', 'var') || isempty(trackers) || isempty(TRACKER_DIRS)
  dir_trackers = dir(opt.tracker_dir);
  disp(['scanning ' opt.tracker_dir '...']);
  TRACKER_DIRS = [];
  for i = 1:numel(dir_trackers)
    d = dir_trackers(i);
    if ~d.isdir || d.name(1) == '.', continue; end;
    if d.name(1) == '_'
      disp(['.. skipping ' d.name ' - dir_name starts with _.']);
      continue;
    end
    entries = dir([opt.tracker_dir '/' d.name '/Run_*.m']);
    if numel(entries) <= 0
      disp(['.. no Run_' d.name '.m script found in ' opt.tracker_dir '/' d.name]);
      continue;
    end
    %- Check the found tracker scripts.
    dir_path = [opt.tracker_dir '/' d.name];
    addpath(dir_path);
    for j = 1:numel(entries)
      tracker_name = entries(j).name(5:end-2);
      disp(['.. found ' tracker_name ' in ' dir_path]);
      try
        %- Try to run it without any param to check planform support.
        eval(['Run_' tracker_name ';']);
      catch err
        warning('TrackerBenchmark:UnsupportedPlatform', ...
          [err.identifier ': ' err.message]);
        continue;
      end
      TRACKER_DIRS.(tracker_name) = d.name;
    end
    rmpath(dir_path);
  end
  if ~exist('trackers', 'var') || isempty(trackers)
    trackers = fieldnames(TRACKER_DIRS);
  end
  disp(['found ' num2str(numel(trackers)) ' trackers...']);
end
if ~iscell(trackers), trackers = {trackers}; end;

%- For given trackers, run setup scripts (e.g. compile mex files).
avail_trackers = struct();
for tracker_idx = 1:numel(trackers)
  tracker_name = trackers{tracker_idx};
  dir_name = tracker_name;
  if isfield(TRACKER_DIRS, tracker_name)
    dir_name = TRACKER_DIRS.(tracker_name);
  end
  old_dir = cd([opt.tracker_dir '/' dir_name]);
  
  if ~exist(['Setup_' tracker_name '.m'], 'file')
    disp(['.. nothing to setup for ' tracker_name '...']);
    avail_trackers.(tracker_name) = 1;
  else
    disp(['.. setting up ' tracker_name '...']);
    try
      feval(['Setup_' tracker_name]);
      avail_trackers.(tracker_name) = 1;
    catch err
      warning('TrackerBenchmark:TrackerError', ...
        ['.. tracker setup error (' tracker_name ') - \n  ', ...
        err.identifier ': ' err.message]);
    end
  end
  cd(old_dir);
end
disp(['finished setting up ' num2str(numel(trackers)) ' trackers...']);
avail_trackers = fieldnames(avail_trackers);
if nargout < 1, clear avail_trackers; end;

end
