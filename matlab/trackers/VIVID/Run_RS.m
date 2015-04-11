
function results = Run_RS(imgfilepath_fmt, img_range_str, init_rect, opt)
% RatioShift

%- Platform check.
if nargin < 1
  results = vivid_trackers;
  return;
end

results = vivid_trackers(5, imgfilepath_fmt, img_range_str, init_rect, opt);

end
