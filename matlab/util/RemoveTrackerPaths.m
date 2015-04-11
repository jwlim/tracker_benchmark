
% RemoveTrackerPaths.m
% A script that removes the path to the tracker directories.

paths = regexp(path(), '([^:]+):', 'tokens');
for i = 1:numel(paths)
  if ~isempty(strfind(paths{i}{1}, './trackers'))
    disp(['removing path to ' paths{i}{1} '...']);
    rmpath(paths{i}{1});
  end
end
