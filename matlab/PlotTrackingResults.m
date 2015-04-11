
function [results] = PlotTrackingResults(results, varargin)
%
% PlotTrackingResults
% - plots the tracking results on each frame of the test sequences.
%
% Usage:
% PlotTrackingResults(results, ...)
% - results : the tracking results loaded by LoadTrackingResults().
%
% [results] = PlotTrackingResults(test_name, sequences, trackers, ...)
% - test_name, sequences, trackers : parameters for LoadTrackingResults().
% - results : the returned struct from LoadTrackingResults().
%
% Options:
% - out_dir : directory to output plotted tracking results. (default: '')
% - out_filename_fmt : the file format for output. (default: '%04d.png')
% - plot_corners : whether plot the corners of non-bounding-box results.
%     (default: true)
%
% Examples:
%   PlotTrackingResults('cvpr13_SRE', 'basketball', 'CSK');
%   PlotTrackingResults('TSRE', 'basketball', 'CSK');

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)


if ~isstruct(results) && numel(varargin) >= 2
  results = LoadTrackingResults(results, varargin{1}, varargin{2}, varargin{3:end});
  varargin = varargin(3:end);
end

if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'out_dir'), opt.out_dir = ''; end;
if ~isfield(opt, 'out_filename_fmt'), opt.out_filename_fmt = '%04d.png'; end;
if ~isfield(opt, 'plot_corners'), opt.plot_corners = false; end;

if ~isempty(opt.out_dir) && ~exist(opt.out_dir, 'dir')
  mkdir(opt.out_dir);
end

if isfield(results, 'data');
  lazy_load = false;
elseif isfield(results, 'load_cmds');
  lazy_load = true;
else
  error('invalid results - use LoadTrackingResults to load tracking results.');
end

test_name = results.test_name;
num_trackers = numel(results.trackers);
num_seqs = numel(results.seqs);

figure(gcf);
clf;
axes('position', [0, 0, 1, 1]);
colormap gray;

for seq_idx = 1:num_seqs
  seq = results.seqs(seq_idx);
  seq_name = seq.name;
  
  img_range = eval(seq.img_range_str);
  gt_range = eval(seq.gt_rect_range_str);
  img_gt_idx = AlignRange(img_range, gt_range);
  
  if isempty(results.trackers)  % Show only the ground-truths.
    for i = 1:numel(img_range)
      frame_idx = img_range(i);
      frame = imread(sprintf(seq.img_filepath_fmt, frame_idx));
      DrawFrame(frame, ...
        sprintf('%s/%s/%d', test_name, seq_name, frame_idx));
      
      if img_gt_idx(i) > 0
        DrawRect(seq.gt_rect(img_gt_idx(i), :), 'green')
      end
      drawnow;
%       pause;
    end
    continue;
  end
  
  for tracker_idx = 1:num_trackers  % Plot all tracking results.
    tracker_name = results.trackers{tracker_idx};
    
    if lazy_load
      res = eval(results.load_cmds{tracker_idx, seq_idx});
    else
      res = results.data{tracker_idx, seq_idx};
    end
    
    num_res = numel(res);
    for i = 1:num_res  % Overwriting res{}.
      [rect, corner] = ConvertResultToRects(res{i});
      if iscell(rect) && numel(rect) > 1
        for j = 1:numel(rect)
          seq_range = eval(res{i}{j}.seq_range_str);
          res_idx = AlignRange(img_range, seq_range);
          res{i}{j} = struct('rect', rect, 'corner', corner, 'idx', res_idx);
        end
      else
        seq_range = eval(res{i}.seq_range_str);
        res_idx = AlignRange(img_range, seq_range);
        res{i} = struct('rect', rect, 'corner', corner, 'idx', res_idx);
      end
    end
    res = FlattenRes(res);
    num_res = numel(res);
    
    res_idx = zeros(num_res, numel(img_range));
    for i = 1:num_res
      res_idx(i, :) = res(i).idx(:);
    end
    
    out_dir = '';
    if ~isempty(opt.out_dir)
      out_dir = [opt.out_dir '/' seq_name '_' tracker_name];
      if ~exist(out_dir, 'dir'), mkdir(out_dir); end
    end
    
    for i = 1:numel(img_range)
      frame_idx = img_range(i);
      frame = imread(sprintf(seq.img_filepath_fmt, frame_idx));
      DrawFrame(frame, ...
        sprintf('%s/%s_%s/%d', test_name, seq_name, tracker_name, frame_idx));
      
      if img_gt_idx(i) > 0
        DrawRect(seq.gt_rect(img_gt_idx(i), :), 'green')
      end
      ii = find(res_idx(:, i) > 0);
      for j = 1:numel(ii)
        rj = res(ii(j));
        idx = res_idx(ii(j), i);
        if opt.plot_corners
          DrawRect(rj.rect(idx, :), 'red', rj.corner(idx, :), 'blue', ...
            num2str(j));
        else
          overlap = ComputeRectOverlap(rj.rect(idx, :), seq.gt_rect(img_gt_idx(i), :));
          DrawRect(rj.rect(idx, :), 'red', [], '', [num2str(j) ':' num2str(overlap)]);
        end
      end
        
%       for j = 1:num_res
%         rj = res(j);
%         if rj.idx(i) <= 0, continue; end
%         idx = rj.idx(i);
%         if opt.plot_corners
%           DrawRect(rj.rect(idx, :), 'red', rj.corner(idx, :), 'blue', ...
%             num2str(j));
%         else
%           DrawRect(rj.rect(idx, :), 'red', [], '', num2str(j));
%         end
%       end
      drawnow;
%       pause;

      if ~isempty(out_dir)
        imwrite(frame2im(getframe(gcf)), ...
          [out_dir '/' sprintf(opt.out_filename_fmt, frame_idx)]);
      end
    end
  end
  
end

end


function DrawFrame(frame, disp_str)
[h, w, ~] = size(frame);
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1), pos(2), w, h]);
imagesc(frame);
axis image off;

text(5, 10, disp_str, ...
  'Color','y', 'Interpreter','none', 'FontName','FixedWidth', ...
  'FontWeight','bold', 'FontSize',12);
end


function DrawRect(rect, cr, corner, cc, str)

if nargin > 2 && ~isempty(corner)
  x = corner(1:2:end);
  y = corner(2:2:end);
  line([x(1), x(2), x(3), x(4), x(1)], [y(1), y(2), y(3), y(4), y(1)], 'Color', cc);
end

if rect(3) > 0 && rect(4) > 0
  p = [rect(1), rect(2), rect(1) + rect(3) - 1, rect(2) + rect(4) - 1];
  line([p(1), p(1), p(3), p(3), p(1)], [p(2), p(4), p(4), p(2), p(2)], 'Color', cr);
  
  if nargin > 4 && ~isempty(str)
    text(p(1), p(2) + 2, str, 'Color','w', 'FontName','FixedWidth', 'FontSize',10);
  end
end

end


function idx = AlignRange(range_ref, range)

[~, ref_idx_tmp, idx_tmp] = intersect(range_ref, range);
idx = zeros(size(range_ref));
idx(ref_idx_tmp) = idx_tmp;
end


function new_res = FlattenRes(res)
if ~iscell(res) % || numel(res) < 2
  new_res = res;
else
  num_res = numel(res);
  new_res = cell(1, num_res);
  for i = 1:num_res
    new_res{i} = FlattenRes(res{i});
  end
  new_res = [new_res{:}];
end
end


function overlap = ComputeRectOverlap(rect0, rect1)
%
%each row is a rectangle.
% A(i,:) = [x y w h]
% B(j,:) = [x y w h]
% overlap(i,j) = area of intersection
% normoverlap(i,j) = overlap(i,j) / (area(i)+area(j)-overlap)
%
% Same as built-in rectint, but faster and uses less memory (since avoids repmat).

if size(rect0, 1) < size(rect1, 1)
  warning('TrackerBenchmark:Generic', ...
    ['tracking results ' num2str(size(rect0, 1))
     ' are fewer than ground-truth markings ' num2str(size(rect1, 1)) '.']);
  rect0(size(rect1, 1), end) = 0;
end;
if size(rect0, 1) > size(rect1, 1)
  warning('TrackerBenchmark:Generic', ...
    ['tracking results ' num2str(size(rect0, 1)) ...
     ' are more than ground-truth markings ' num2str(size(rect1, 1)) '.']);
  rect0 = rect0(1:size(rect1, 1), :);
end;
% if size(rect0, 1) > size(rect1, 1), rect1(size(rect0, 1), end) = 0; end;

leftA = rect0(:,1);
bottomA = rect0(:,2);
rightA = leftA + rect0(:,3) - 1;
topA = bottomA + rect0(:,4) - 1;

leftB = rect1(:,1);
bottomB = rect1(:,2);
rightB = leftB + rect1(:,3) - 1;
topB = bottomB + rect1(:,4) - 1;

tmp = (max(0, min(rightA, rightB) - max(leftA, leftB) + 1)) .* ...
      (max(0, min(topA, topB) - max(bottomA, bottomB) + 1));
areaA = rect0(:,3) .* rect0(:,4);
areaB = rect1(:,3) .* rect1(:,4);
overlap = tmp ./ (areaA + areaB - tmp);
disp(int32([overlap * 100, tmp, areaA + areaB - tmp, areaA, areaB]));
end
