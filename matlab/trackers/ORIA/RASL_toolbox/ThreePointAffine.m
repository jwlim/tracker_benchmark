function A = ThreePointAffine( Pts1, Pts2 )

% ThreePointAffine
%
%   Computes a affine transform (represented as a 2 x 3 matrix)
%   from two matched point pairs
%
%   Inputs:
%      Pts1 -- columns are the points in the first image (should be 2x3)
%      Pts2 -- columns are the points in the second image (should be 2x3)
%
%   Outputs:
%      2x3 matrix A representing the affine transform


% Yigang Peng, Arvind Ganesh, November 2009.
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing


X = [Pts2' ones(3,1)];
U = Pts1';
Tinv = X \ U;
Tinv(:,3) = [0 0 1]';
T = inv(Tinv);
T(:,3) = [0 0 1]';
A = T(:,1:2)';