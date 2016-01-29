% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing

% Computes projective matrix based on input parameters and transformation
% type.

function T = parameters_to_projective_matrix( transformType, xi )
T = eye(3);
if strcmp(transformType,'TRANSLATION'),
    T(1,3) = xi(1);
    T(2,3) = xi(2);
elseif strcmp(transformType,'EUCLIDEAN'),
    R = [ cos(xi(1)), -sin(xi(1)); ...
        sin(xi(1)), cos(xi(1)) ];
    T(1:2,1:2) = R;
    T(1,3) = xi(2);
    T(2,3) = xi(3);
elseif strcmp(transformType,'SIMILARITY'),
    R = [ cos(xi(2)), -sin(xi(2)); ...
        sin(xi(2)), cos(xi(2)) ];
    T(1:2,1:2) = xi(1)*R;
    T(1,3) = xi(3);
    T(2,3) = xi(4);
elseif strcmp(transformType,'AFFINE'),
    T(1:2,:) = [ xi(1:3)'; xi(4:6)' ];
elseif strcmp(transformType,'HOMOGRAPHY'),
    T = [ xi(1:3)'; xi(4:6)'; [xi(7:8)' 1] ];
else
    error('Unrecognized transformation');
end