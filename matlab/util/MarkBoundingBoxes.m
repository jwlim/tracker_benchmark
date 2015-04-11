
function rects = MarkBoundingBoxes(img_pathfmt, img_range, rects)

figure;
clf;
axes('position', [0, 0, 1, 1]);
colormap gray;

num_imgs = numel(img_range);

if nargin < 3
  rects = zeros(num_imgs, 4);
end

idx = 1;
while idx > 0 && idx < num_imgs
  frame_idx = img_range(idx);
  frame_path = sprintf(img_pathfmt, frame_idx);
  frame = imread(frame_path);
  [h, w, ~] = size(frame);
  pos = get(gcf, 'position');
  set(gcf, 'position', [pos(1), pos(2), w, h]);
  
  accept = false;
  while ~accept && idx > 0 && idx < num_imgs
    imagesc(frame);
    axis image off;
    text(5, 10, frame_path, ...
      'Color','y', 'Interpreter','none', 'FontName','FixedWidth', ...
      'FontWeight','bold', 'FontSize',12);
    
    if any(rects(idx, :)) > 0
      DrawRect(rects(idx, :), 'green')
    end
    
    disp('click two corners, or enter=next, p=prev, q=quit, any other key=re-click');
    [x,y,button] = ginput(2);
    if numel(x) == 2 && numel(y) == 2
      rects(idx, :) = [min(x), min(y), abs(x(1) - x(2)), abs(y(1) - y(2))];
    elseif isempty(x) || button == 'y' || button == 'Y'
      accept = true;
      if idx < num_imgs, idx = idx + 1; end;
    elseif button == 'p' || button == 'P'
      accept = true;
      if idx > 1, idx = idx - 1; end;
    elseif button == 'q' || button == 'Q'
      return;
    end
  end
end
end


function DrawRect(rect, cr)

p = [rect(1), rect(2), rect(1) + rect(3) - 1, rect(2) + rect(4) - 1];
line([p(1), p(1), p(3), p(3), p(1)], [p(2), p(4), p(4), p(2), p(2)], 'Color', cr);

end
