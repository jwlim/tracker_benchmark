% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function im = drawRect(im, pos, wsize, edgecolor, linewidth)

rgb_val = name2rgb(edgecolor);

startx = max(pos(1), 1);
endx = min(pos(1)+wsize(1)-1, size(im, 1));
starty = max(pos(2), 1);
endy = max(pos(2)+linewidth-1,1);

fr = 255*ones(endx-startx+1, endy-starty+1);
fr = cat(3, fr*rgb_val(1), fr*rgb_val(2), fr*rgb_val(3));
im(startx:endx, starty:endy, :) = fr;

starty = min(pos(2)+wsize(2)-linewidth, size(im, 2));
endy = min(pos(2)+wsize(2)-1, size(im, 2));

fr = 255*ones(endx-startx+1, endy-starty+1);
fr = cat(3, fr*rgb_val(1), fr*rgb_val(2), fr*rgb_val(3));
im(startx:endx, starty:endy, :) = fr;

startx = max(pos(1), 1);
endx = max(pos(1)+linewidth-1, 1);
starty = max(pos(2), 1);
endy = min(pos(2)+wsize(2)-1, size(im, 2));

fr = 255*ones(endx-startx+1, endy-starty+1);
fr = cat(3, fr*rgb_val(1), fr*rgb_val(2), fr*rgb_val(3));
im(startx:endx, starty:endy, :) = fr;

startx = min(pos(1)+wsize(1)-linewidth, size(im, 1));
endx = min(pos(1)+wsize(1)-1, size(im, 1));

fr = 255*ones(endx-startx+1, endy-starty+1);
fr = cat(3, fr*rgb_val(1), fr*rgb_val(2), fr*rgb_val(3));
im(startx:endx, starty:endy, :) = fr;

end


function rgb_val = name2rgb(c)

colors = ['r', 'c', 'g', 'k', 'm', 'b', 'y', 'w', 'd'];
rgb_values = [1 0 0; 0 1 1; 0 1 0; 0 0 0; 1 0 1; 0 0 1; 1 1 0; 1 1 1; 0.5, 0.5, 0.5];

rgb_val = rgb_values((colors == c), :);

end