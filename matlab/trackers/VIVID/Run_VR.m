
function results = Run_VR(imgfilepath_fmt, img_range_str, init_rect, opt)
% VarianceRatio

%- Platform check.
if nargin < 1
  results = vivid_trackers;
  return;
end

results = vivid_trackers(3, imgfilepath_fmt, img_range_str, init_rect, opt);

end
