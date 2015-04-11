
function cfg = SaveSequenceConfig(seq_name, img_filename_fmt, img_range_str, ...
  images_url, annotations, gt_rect_filename, gt_rect_range_str, data_dir)
% function cfg = SaveSequenceConfig(name, imgpath_fmt, range_str, data_dir)
%  - Makes a config using the parameters, and saves it to the data
%    directory as 'cfg.mat'.
%  - Look for the groundtruth files: groundtruth_rect.txt
% [input]
%   name  : the sequence name string.
%   img_filename_fmt  : the image filename (printf format including one index).
%       e.g. 'frame%03d.jpg', 'image_%d.png'
%   img_range_str  : the image index range (in string).
%       e.g. '1:100', '201:2:543'
%   images_url: the url for download images in the sequence.
%   annotations  : a cell array of anntotations (e.g. {'LV','FM'}).
%   gt_rect_filename (optional)  : the filepath with groundtruth rectalgnes <x,y,w,h>
%       (default: 'groundtruth_rect.txt')
%   gt_rect_range_str : the gt_rect index range (in string).
%       (default: img_range_str)
%   data_dir (optional)  : the data directory (default: '../data/').
% [output]
%   cfg (optional)  : the constructed config struct.

if ~exist('data_dir', 'var')
  data_dir = '../data/';
end
if ~exist(data_dir, 'dir')
  error(['data directory (' data_dir ') not found.']);
end
if ~exist('gt_rect_filename', 'var') || isempty(gt_rect_filename)
  gt_rect_filename = 'groundtruth_rect.txt';
end
if ~exist('gt_rect_range_str', 'var') || isempty(gt_rect_range_str)
  gt_rect_range_str = img_range_str;
end

tok = regexp(seq_name, '([^.]*)[.]?(.*)', 'tokens');
dir_name = seq_name;
seq_idx = 1;
if ~isempty(tok{1}{2})
  dir_name = tok{1}{1};
  seq_idx = str2double(tok{1}{2});
end

seq_path = [data_dir '/' dir_name '/cfg.mat'];
if exist(seq_path, 'file')
  seq_mat = load(seq_path);
  if isfield(seq_mat, 'seq')
    seq = seq_mat.seq;
  end
end

%   for i = 2:2:numel(gt_rect_path)
%     if isempty(gt_rect_path{i}), gt_rect_path{i} = img_range_str; end
%   end
% end
% if mod(numel(gt_rect_path), 2) ~= 0
%   error('invalid gt_rect_info.');
% end
% if ~exist('gt_rect_range_str', 'var')
%   gt_rect_range_str = img_range_str;
% end

seq_dir = [data_dir '/' dir_name '/'];
if ~exist(seq_dir, 'dir')
  warning(['data directory (' seq_dir ') does not exist - creating']);
  mkdir(seq_dir);
end

gt_rect = zeros(2, 0);
if ~exist([seq_dir '/' gt_rect_filename], 'file')
  warning(['gt_rect_filename not found (' gt_rect_filename ')']);
else
  gt_rect = dlmread([seq_dir '/' gt_rect_filename]);
  if size(gt_rect, 1) ~= numel(eval(gt_rect_range_str))
    error(['gt_rect_range_str (' gt_rect_range_str ') does not match to' ...
      ' the size of gt_rect_data (' num2str(size(gt_rect, 1)) ')']);
  end
  if numel(setdiff(eval(gt_rect_range_str), eval(img_range_str))) > 0
    error(['gt_rect_range str (' gt_rect_range_str ') include indices' ...
      ' outside of img_range_rect (' img_range_str ')']);
  end
end
  
%   num_gt_rect = numel(gt_rect_path) / 2;
% gt_rect = repmat(struct('rect', [], 'range_str', ''), [1, num_gt_rect]);
% for i = 1:num_gt_rect
%   gt_rect_filename = gt_rect_path{2 * i - 1};
%   gt_rect_range_str = gt_rect_path{2 * i};
%   
%   if ~exist([seq_dir gt_rect_filename], 'file')
%     if numel(gt_rect_path > 2)
%       error(['gt_rect_file not found (' gt_rect_filename ')']);
%     else
%       break;
%     end
%   end
%     
%   gt_rect = dlmread([seq_dir gt_rect_filename]);
%   if size(gt_rect, 1) ~= numel(eval(gt_rect_range_str))
%     error(['gt_rect_range_str (' gt_rect_range_str ') does not match to' ...
%       ' the size of gt_rect_data (' num2str(size(gt_rect, 1)) ')']);
%   end
%   if numel(setdiff(eval(gt_rect_range_str), eval(img_range_str))) > 0
%     error(['gt_rect_range str (' gt_rect_range_str ') include indices' ...
%       ' outside of img_range_rect (' img_range_str ')']);
%   end
%   gt_rect(i).rect = gt_rect;
%   gt_rect(i).range_str = gt_rect_range_str;
% end

cfg = struct('name', seq_name, 'img_filename_fmt', img_filename_fmt, ...
  'img_range_str', img_range_str, 'images_url', images_url);
cfg.annotations = annotations;
cfg.gt_rect = gt_rect;
cfg.gt_rect_range_str = gt_rect_range_str;

seq(seq_idx) = cfg;
save([seq_dir 'cfg.mat'], 'seq');

end
