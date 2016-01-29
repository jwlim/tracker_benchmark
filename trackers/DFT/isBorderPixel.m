% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function b = isBorderPixel(Isize, pt, wsize)

if pt(1)<=1 || pt(1)+wsize(1) >= Isize(1)-1 || pt(2)<=1 || pt(2)+wsize(2) >= Isize(2)-1
    
    b = 1;
else
    b = 0;
    
end;