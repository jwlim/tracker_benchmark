function q = affparaminv(p,q)
% function q = affparaminv(p[, q])
%
%    p(6,n) : [dx dy sc th sr phi]'
%    q(6,n) : [q(1) q(3) q(4); q(2) q(5) q(6)]

% Copyright (C) Jongwoo Lim and David Ross.  All rights reserved.

if (length(p) == 6)
  p = p(:);
end
if (nargin > 1)
  q = inv([p(3) p(4); p(5) p(6)]) * [q(1)-p(1) q(3:4); q(2)-p(2) q(5:6)];
else
  q = inv([p(3) p(4); p(5) p(6)]) * [-p(1) 1 0; -p(2) 0 1];
end
q = q([1,2,3,5,4,6]);
