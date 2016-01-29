function [out,a,b] = gly_zmuv(in)
% GLY_ZMUV create zero-mean-unit-variance images in a gallery and form a new gallery
%
%  in     -- MNxC
%  out    -- MNxC

MN = size(in,1);
a = mean(in);
b = std(in)+1e-14;
out = (in - ones(MN,1)*a) ./ (ones(MN,1)*b);