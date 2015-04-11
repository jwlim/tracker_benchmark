% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing

% Compute image Jacobians wrt various parametric domain transformations


function J = image_Jaco(Iu, Iv, imgSize, transformType, xiTemp)

u   = vec(repmat(1:imgSize(2),imgSize(1),1));
v   = vec(repmat((1:imgSize(1))',1,imgSize(2)));

if strcmp(transformType,'TRANSLATION'),
    J = [ Iu, Iv ];
    
elseif strcmp(transformType,'EUCLIDEAN'),
    J = [ Iu .* ( -sin(xiTemp(1))*u-cos(xiTemp(1))*v ) + Iv.*(cos(xiTemp(1))*u - sin(xiTemp(1))*v), ...
                    Iu, Iv ];
                
elseif strcmp(transformType,'SIMILARITY'),
    J = [ Iu .* ( cos(xiTemp(2)) * u - sin(xiTemp(2)) * v ) + Iv .* ( sin(xiTemp(2)) * u + cos(xiTemp(2)) * v ), ...
        Iu .* ( -xiTemp(1)*sin(xiTemp(2))*u-xiTemp(1)*cos(xiTemp(2))*v ) + Iv.*(xiTemp(1)*cos(xiTemp(2))*u - xiTemp(1)*sin(xiTemp(2))*v), ...
        Iu, Iv ];
                
elseif strcmp(transformType,'AFFINE'),
    J = [ Iu.*u,   Iu.*v,   Iu,   Iv.*u,   Iv.*v,   Iv ];
                
elseif strcmp(transformType,'HOMOGRAPHY'),

     T = ones(3,3);
     T(1,:) = xiTemp(1:3);
     T(2,:) = xiTemp(4:6);
     T(3,1:2) = xiTemp(7:8);
     X = T(1,1)*u + T(1,2)*v + T(1,3);
     Y = T(2,1)*u + T(2,2)*v + T(2,3);
     N = T(3,1)*u + T(3,2)*v + 1;

     J = [ Iu .* u ./ N, Iu .* v ./ N, Iu ./ N, ...
                    Iv .* u ./ N, Iv .* v ./ N, Iv ./ N, ...
                    ( -Iu .* X .* u ./ ( N.^2 ) - Iv .* Y .* u ./ (N.^2) ), ...
                    ( -Iu .* X .* v ./ ( N.^2 ) - Iv .* Y .* v ./ (N.^2) ) ];
                
else
    error('Unrecognized transformation type in test_face_alignment.m');
end