
function results = Run_PD(imgfilepath_fmt, img_range_str, init_rect, opt)
% PeakDifference

%- Platform check.
if nargin < 1
  results = vivid_trackers;
  return;
end

results = vivid_trackers(4, imgfilepath_fmt, img_range_str, init_rect, opt);

end
