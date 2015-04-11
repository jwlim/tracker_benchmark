% Compute the "Uniform-Mix-Distance" between point sets X and Y
% Computes the distance between a set of points X in R^n to a second point or 
% set of points using a mixture-of-2-uniforms distance 
% 
% [d] = computeUniformMixDist(X,Y,alpha,R,S)
% 
% Input :
%             X - Input of data in Rn (X(:,1:2) = {x,y})
%             Y - Second point or set of points for distance calculation 
%                     Must have same number of rows as X or a single row
%             alpha - Mixture weight coef. 
%             R - Inner uniform support (for each dim)
%             S - Hyper-volume of probability space
% 
% Output:
%             d - Distances vector  
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [d] = computeUniformMixDist(X,Y,alpha,R,S)

[n,m] = size(X);
if numel(X) == numel(Y)
        A = X - Y;
elseif size(Y,1) == 1
        A = bsxfun(@minus,X,Y);
else
        error('Y must have a single row or the same number of rows as X');
end
% Build indicator to "inliers"
ind = sum(bsxfun(@le,abs(A),R),2)==m;
% Compute distance
d = ind*(-log(alpha/(2*R)^m + (1-alpha)/S )) + (1-ind)*-log((1-alpha)/S);