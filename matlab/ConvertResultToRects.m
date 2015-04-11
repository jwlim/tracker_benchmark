
function [rects, corners] = ConvertResultToRects(results)
%
% ConvertResultToRects : converts various tracker outputs into bounding box
% rectangle (rect).
%
% Usage:
%   rect = ConvertResultToRect(results)
%     -> results : a tracker generated result.
%           .type, .res, .tmplsize

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu ()

is_cell_results = iscell(results);
if ~is_cell_results, results = {results}; end;

rects = cell(size(results));
corners = cell(size(results));

for idx = 1:numel(results)
  result = results{idx};
  if isempty(result)
    continue;
  end
  res = result.res;
  tmplsize = result.tmplsize;
  
  switch result.type
    case 'rect', rect = res;  corner = CornersFromRect(rect);
    case 'affine_ivt',   [rect, corner] = RectAffineIVT(tmplsize, res);
    case 'affine_L1',    [rect, corner] = RectAffineL1(tmplsize, res);
    case 'affine_LK',    [rect, corner] = RectAffineLK(tmplsize, res);
    case 'four_corners', [rect, corner] = RectFourCorners(res);
    case 'affine',       [rect, corner] = RectFourCorners(res);
    case 'similarity',   [rect, corner] = RectSimilarity(tmplsize, res);
    otherwise, error(['unknown result type ' result.type]);
  end
  invalid_rect_idx = any(isnan(rect), 2) | any(rect(:,3:4) <= 0, 2);
  rect(invalid_rect_idx, :) = 0;
  
  rects{idx} = rect;
  corners{idx} = corner;
end

if ~is_cell_results
  rects = rects{1};
  corners = corners{1};
end;
end


function corners = CornersFromRect(rect)

p0 = rect(:, 1:2);
p2 = rect(:, 1:2) + rect(:, 3:4) - 1;
p1 = [p0(:, 1), p2(:,2)];
p3 = [p2(:, 1), p0(:,2)];
corners = [p0, p1, p2, p3];
end


function rect = CornersToRect(pts)

minv = min(pts, [], 2);
diff = max(pts, [], 2) - minv + 1;
rect = [minv(1), minv(2), diff(1), diff(2)];
end


function [rect, corners] = RectAffineIVT(tmplsize, res)

[w, h] = deal(tmplsize(1), tmplsize(2));
corners0 = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2 ]';

num_res = size(res, 1);
rect = zeros(num_res, 4);
corners = zeros(num_res, 8);
for i = 1:num_res
  p = res(i, :);
  M = [p(1) p(3) p(4); p(2) p(5) p(6)];
  c = M * corners0;
  rect(i, :) = CornersToRect(c);
  corners(i, :) = c(:);
%   rect(i, :) = [c(1, 1), c(2,1), c(1,3) - c(1,1), c(2,3) - c(2,1)];
end
end


function [rect, corners] = RectAffineL1(tmplsize, res)

[w, h] = deal(tmplsize(1), tmplsize(2));
% corners0	= [	1, w, 1, w;  1, 1, h, h;  1, 1, 1, 1];  % ORG
corners0	= [	1, w, w, 1;  1, 1, h, h;  1, 1, 1, 1];
num_res = size(res, 1);
rect = zeros(num_res, 4);
corners = zeros(num_res, 8);
for i = 1:num_res
  p = res(i, :);
%   M = [p(1) p(2) p(5); p(3) p(4) p(6)];  % ORG
  M = [p(3) p(4) p(6); p(1) p(2) p(5)];
  c = M * corners0;
  rect(i, :) = CornersToRect(c);
  corners(i, :) = c(:);
%   rect(i, :) = [c(2,1), c(1,1), c(2,4) - c(2,1) + 1, c(1,4) - c(1,1) + 1];
end
end


function [rect, corners] = RectAffineLK(tmplsize, res)

[h, w] = deal(tmplsize(1), tmplsize(2));
corners0 = [1, 1, 1;  1, h, 1;  w, h, 1;  w, 1, 1]';
num_res = size(res, 1) / 2;
rect = zeros(num_res, 4);
corners = zeros(num_res, 8);
for i = 1:num_res
  p = res((2 * i - 1):(2 * i), :);
  M = [p(1) p(2) p(5); p(3) p(4) p(6)];
  c = M * corners0;
  rect(i, :) = CornersToRect(c);
  corners(i, :) = c(:);
end
end


function [rect, corners] = RectFourCorners(res)

num_res = size(res, 1) / 2;
rect = zeros(num_res, 4);
corners = zeros(num_res, 8);
for i = 1:num_res
  p = res((2 * i - 1):(2 * i), :);
  rect(i, :) = CornersToRect(p);
  corners(i, :) = p(:);
end
end


function [rect, corners] = RectSimilarity(tmplsize, res)

if size(res, 2) ~= 4 && size(res, 1) == 4, res = res'; end;
[h, w] = deal(tmplsize(1), tmplsize(2));
% corners0 = [1, 1, 1;  1, h, 1;  w, h, 1;  w, 1, 1]';
corners0	= [	1, w, w, 1;  1, 1, h, h;  1, 1, 1, 1];
num_res = size(res, 1);
rect = zeros(num_res, 4);
corners = zeros(num_res, 8);
for i = 1:num_res
  p = res(i, :);
  M = [p(1) * [ cos(p(2)), -sin(p(2)); sin(p(2)), cos(p(2)) ], [p(3); p(4)]];
  c = M * corners0;
  rect(i, :) = CornersToRect(c);
  corners(i, :) = c(:);
end
end
