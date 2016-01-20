% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing



function xi = projective_matrix_to_parameters( transformType, T )
xi = [];
if strcmp(transformType,'TRANSLATION'),
    xi = T(1:2,3);
elseif strcmp(transformType,'EUCLIDEAN'),
    xi = nan(3,1);
    theta = acos(T(1,1));
    if T(2,1) < 0,
        theta = -theta;
    end
    xi(1) = theta;
    xi(2) = T(1,3);
    xi(3) = T(2,3);
elseif strcmp(transformType,'SIMILARITY'),
    xi = nan(4,1);
    sI = T(1:2,1:2)' * T(1:2,1:2);
    xi(1) = sqrt(sI(1));
    theta = acos(T(1,1)/xi(1));
    if T(2,1) < 0,
        theta = -theta;
    end
    xi(2) = theta;
    xi(3) = T(1,3);
    xi(4) = T(2,3);
elseif strcmp(transformType,'AFFINE'),
    xi = nan(6,1);
    xi(1:3) = T(1,:)';
    xi(4:6) = T(2,:)';
elseif strcmp(transformType,'HOMOGRAPHY'),
    xi = nan(8,1);
    xi(1:3) = T(1,:)';
    xi(4:6) = T(2,:)';
    xi(7:8) = T(3,1:2)';
else
    error('Unrecognized transformation');
end