
function ResizeFigure(w, h)

old_units = get(gcf, 'Units');
set(gcf, 'Units', 'pixels');
figpos = get(gcf, 'Position');
newpos = [figpos(1), figpos(2), w, h];
set(gcf, 'Position', newpos);
set(gcf, 'Units', old_units);
set(gcf, 'Resize', 'off');

end
