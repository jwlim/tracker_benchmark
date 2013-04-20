
function cfg = SaveSequenceConfig(name, imgfilename_fmt, range_str, ...
  annotations, gt_rect_file, data_dir)
% function cfg = SaveSequenceConfig(name, imgpath_fmt, range_str, data_dir)
%  - Makes a config using the parameters, and saves it to the data
%    directory as 'cfg.mat'.
%  - Look for the groundtruth files: groundtruth_rect.txt
% [input]
%   name  : the sequence name string.
%   imgfilename_fmt  : the image filename (printf format including one index).
%       e.g. 'frame%03d.jpg', 'image_%d.png'
%   range_str  : the image index range (in string).
%       e.g. '1:100', '201:2:543'
%   annotations  : a cell array of anntotations (e.g. {'LV','FM'}).
%   gt_rect_file (optional)  : the filepath with groundtruth rectalgnes <x,y,w,h>
%       (default: 'groundtruth_rect.txt')
%   data_dir (optional)  : the data directory (default: '../data/').
% [output]
%   cfg (optional)  : the constructed config struct.

if ~exist('data_dir', 'var')
  data_dir = '../data/';
end
if ~exist(data_dir, 'dir')
  error(['data directory (' data_dir ') not found.']);
end
if ~exist('gt_rect_file', 'var')
  gt_rect_file = 'groundtruth_rect.txt';
end

path = [data_dir name '/'];
if ~exist(path, 'dir')
  warning(['data directory (' path ') does not exist - creating']);
  mkdir(path);
end

gt_rect = [];
if exist([path gt_rect_file], 'file')
  gt_rect = dlmread([path gt_rect_file]);
end

cfg = struct('name', name, 'imgfilename_fmt', imgfilename_fmt, 'range_str', range_str);
cfg.annotations = annotations;
cfg.gt_rect = gt_rect;

save([path 'cfg.mat'], 'cfg');

end
