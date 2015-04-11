
function PlotResultRect(img, frame_idx, rect, dumppath_fmt, additional_imgs)

figure(gcf);  % Bring the figure to front.
clf;
ResizeFigure(size(img,2), size(img,1));
set(gca, 'position', [0 0 1 1]);
imshow(uint8(img));

if isstruct(rect)
  [rect, corner] = ConvertResultToRects(rect);
  x = corner(1:2:end);
  y = corner(2:2:end);
  line([x(1), x(2), x(3), x(4), x(1)], [y(1), y(2), y(3), y(4), y(1)], ...
    'LineWidth', 1, 'Color', 'g');
end
rectangle('Position', rect, 'LineWidth', 2, 'EdgeColor', 'r');

text(5, 16, ['#' num2str(frame_idx)], 'Color', 'y', ...
  'FontWeight', 'bold', 'FontSize', 20);

if nargin > 4
  if ~iscell(additional_imgs), additional_imgs = {additional_imgs}; end;
  height = 0;
  for i = numel(additional_imgs):-1:1
    [h, w, ~] = size(additional_imgs{i});
    if h <= 0 || w <= 0, continue; end;
    axes('Position', [0, 0, 1, 1]);
    set(gca, 'Units', 'pixels');
    set(gca, 'Position', [0, height, w, h]);
    imshow(additional_imgs{i});
    height = height + h;
  end
end
drawnow;

if exist('dumppath_fmt', 'var') && ~strcmp(dumppath_fmt, '-')
  imwrite(frame2im(getframe(gcf)), sprintf(dumppath_fmt, frame_idx));
end

end


function ResizeFigure(w, h)

old_units = get(gcf, 'Units');
set(gcf, 'Units', 'pixels');
figpos = get(gcf, 'Position');
newpos = [figpos(1), figpos(2), w, h];
set(gcf, 'Position', newpos);
set(gcf, 'Units', old_units);
set(gcf, 'Resize', 'off');

end
