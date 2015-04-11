
function results = Run_MS(imgfilepath_fmt, img_range_str, init_rect, opt)
% MeanShift

%- Platform check.
if nargin < 1
  results = vivid_trackers;
  return;
end

results = vivid_trackers(2, imgfilepath_fmt, img_range_str, init_rect, opt);

end
