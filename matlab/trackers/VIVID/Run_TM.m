
function results = Run_TM(imgfilepath_fmt, img_range_str, init_rect, opt)
% TemplateMatch

%- Platform check.
if nargin < 1
  results = vivid_trackers;
  return;
end

results = vivid_trackers(1, imgfilepath_fmt, img_range_str, init_rect, opt);

end
