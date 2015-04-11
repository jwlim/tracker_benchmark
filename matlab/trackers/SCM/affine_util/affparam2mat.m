function q = affparam2mat(p)
% function q = affparam2mat(p)
%
%   input  :  p£¬ a 'geometric' affine parameter;
%   output  £º q£¬ a 2x3 matrix;
%
% The functions affparam2geom and affparam2mat convert a 'geometric'
% affine parameter from/to a matrix form (2x3 matrix).
%
% affparam2mat converts 6 affine parameters (x, y, th, scale, aspect, skew) to a 2x3 matrix, 
% and affparam2geom does the inverse.
%
%    p(6) : [dx dy sc th sr phi]'
%    q(6) : [q(1) q(3) q(4); q(2) q(5) q(6)]
%
% Reference "Multiple View Geometry in Computer Vision" by Richard
% Hartley and Andrew Zisserman. 

% Copyright (C) Jongwoo Lim and David Ross.  All rights reserved.
% Thanks to Jongwoo Lim and David Ross for this code.  -- Wei Zhong.

sz = size(p);
if (length(p(:)) == 6)
  p = p(:);
end
s = p(3,:);  th = p(4,:);  r = p(5,:);  phi = p(6,:);
cth = cos(th);  sth = sin(th);  cph = cos(phi);  sph = sin(phi);
ccc = cth.*cph.*cph;  ccs = cth.*cph.*sph;  css = cth.*sph.*sph;
scc = sth.*cph.*cph;  scs = sth.*cph.*sph;  sss = sth.*sph.*sph;
q(1,:) = p(1,:);  q(2,:) = p(2,:);
q(3,:) = s.*(ccc +scs +r.*(css -scs));  q(4,:) = s.*(r.*(ccs -scc) -ccs -sss);
q(5,:) = s.*(scc -ccs +r.*(ccs +sss));  q(6,:) = s.*(r.*(ccc +scs) -scs +css);
q = reshape(q, sz);
