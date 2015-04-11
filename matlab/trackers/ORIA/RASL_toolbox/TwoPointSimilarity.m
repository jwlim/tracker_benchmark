function A = TwoPointSimilarity( Pts1, Pts2 )

% TwoPointSimilarity
%
%   Computes a similarity transform (represented as a 2 x 3 matrix)
%   from two matched point pairs
%
%   Inputs:
%      Pts1 -- columns are the points in the first image (should be 2x2)
%      Pts2 -- columns are the points in the second image (should be 2x2)
%
%   Outputs:
%      2x3 matrix A representing the similarity transform

% Yigang Peng, Arvind Ganesh, November 2009.
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing



%%% add a third point
Delta = [0 -1; 1 0];
Pts1 = [ Pts1, Pts1(:,1) + Delta*(Pts1(:,2)-Pts1(:,1)) ];
Pts2 = [ Pts2, Pts2(:,1) + Delta*(Pts2(:,2)-Pts2(:,1)) ];
Pts1 = [ Pts1; ones(1,3) ];
D = kron(eye(2),Pts1');
A_tr_vec = inv(D) * [Pts2(1,:)'; Pts2(2,:)'];
A = nan(2,3);
A(1,:) = A_tr_vec(1:3)';
A(2,:) = A_tr_vec(4:6)';