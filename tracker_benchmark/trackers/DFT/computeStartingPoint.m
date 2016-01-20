% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************


function pt = computeStartingPoint(pt, last_motion, wsize, imsize)

% returns the initial pt displaced by last_motion 
% if this motion is too large and doesn't fit in the frame, it returns the
% closest valid location 

hyp = pt+last_motion;

if hyp(1) >= 1
    if hyp(1)+wsize(1)-1 <= imsize(1)
        pt(1) = hyp(1);
    else
        pt(1) = imsize(1)-wsize(1)+1;
    end;
else
    pt(1) = 1;
end;

if hyp(2) >= 1
    if hyp(2)+wsize(2)-1 <= imsize(2)
        pt(2) = hyp(2);
    else
        pt(2) = imsize(2)-wsize(2)+1;
    end;
else
    pt(2) = 1;
end;




    






