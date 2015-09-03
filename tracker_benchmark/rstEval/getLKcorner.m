function [warp_pts center]= getLKcorner(warp_p, sz)

template_nx = sz(2);
template_ny = sz(1);

tmplt_pts= [1, 1;
        1, template_ny;
        template_nx, template_ny;
        template_nx, 1]';

if size(warp_p,1)==2
    M = [warp_p; 0 0 1];
    M(1,1) = M(1,1) + 1;
    M(2,2) = M(2,2) + 1;
else
    M = warp_p;
%     M(1,3) = M(1,3) + 1;
%     M(2,3) = M(2,3) + 1;
end

warp_pts = M * [tmplt_pts; ones(1, size(tmplt_pts,2))];

c = [(1+template_nx)/2; (1+template_ny)/2; 1];

center = M * c;

warp_pts = warp_pts(1:2,:);

center = center(1:2)';