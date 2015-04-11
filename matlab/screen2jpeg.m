function screen2jpeg(filename)

%SCREEN2JPEG Generate a JPEG file of the current figure with
%   dimensions consistent with the figure's screen dimensions.
%
%   SCREEN2JPEG('filename') saves the current figure to the
%   JPEG file "filename".
%
%    Sean P. McCarthy
%    Copyright (c) 1984-98 by MathWorks, Inc. All Rights Reserved
if nargin < 1
     error('Not enough input arguments!')
end
old_screenunits = get(gcf, 'Units');
old_paperunits = get(gcf, 'PaperUnits');
old_paperpos = get(gcf, 'PaperPosition');
set(gcf, 'Units', 'pixels');
scr_pos = get(gcf, 'Position')
new_pos = scr_pos
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', new_pos);
saveas(gcf, filename);
% print('-djpeg', filename, '-r100');
drawnow
set(gcf,'Units',old_screenunits,...
     'PaperUnits',old_paperunits,...
     'PaperPosition',old_paperpos)
end
