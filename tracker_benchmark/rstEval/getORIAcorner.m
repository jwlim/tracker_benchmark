function [warp_pts center]= getORIAcorner(xi, sz, transformType)

template_nx = sz(2);
template_ny = sz(1);

tmplt_pts= [1, 1;
        1, template_ny;
        template_nx, template_ny;
        template_nx, 1]';

warp_p = parameters_to_projective_matrix(transformType,xi);
    
M = [warp_p; 0 0 1];
M(1,1) = M(1,1) + 1;
M(2,2) = M(2,2) + 1;
warp_pts = M * [tmplt_pts; ones(1, size(tmplt_pts,2))];

c = [(1+template_nx)/2; (1+template_ny)/2; 1];

center = M * c;

warp_pts = warp_pts(1:2,:);

center = center(1:2)';

% fr = [1 1          sz(2) sz(2) 1; ...
%     1 sz(1) sz(1) 1          1; ...
%     1 1          1          1          1 ];
% 
% c = [(1+template_nx)/2; (1+template_ny)/2; 1];
% 
% T_in = parameters_to_projective_matrix(transformType,xi);
% Tfm = fliptform(maketform('projective',inv(T_in')));
% warp_pts = tformfwd(fr(1:2,:)', Tfm )';
% center = 

