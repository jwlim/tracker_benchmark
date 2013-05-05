
function PlotResultRect(img, frame_idx, rect, dumppath_fmt)

ResizeFigure(size(img,2), size(img,1));
set(gca, 'position', [0 0 1 1]);
imshow(uint8(img));

rectangle('Position', rect, 'LineWidth', 4, 'EdgeColor', 'r');
text(5, 18, ['#' num2str(frame_idx)], 'Color', 'y', ...
  'FontWeight', 'bold', 'FontSize', 20);
drawnow;

if exist('dumppath_fmt', 'var') && ~isempty(dumppath_fmt)
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
