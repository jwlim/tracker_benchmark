% Compute the "Gaussian-Distance" between point sets X and Y
% Computes the distance between a set of points X in R^n to a second point or 
% set of points using a multi-dimentional gaussian distance (with 0 mean)
% 
% [d] = computeGaussGaussDist(X,Y,sig)
% 
% Input :
%             X - Input of data in Rn (X(:,1:2) = {x,y})
%             Y - Second point or set of points for distance calculation 
%                     Must have same number of rows as X or a single row
%             sig - Gaussian sigma values
% 
% Output:
%             d - Distances vector  
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [d] = computeGaussDist(X,Y,sig)

[n,m] = size(X);
if numel(X) == numel(Y)
        L = X - Y;
elseif size(Y,1) == 1
        L = bsxfun(@minus,X,Y);
else
        error('Y must have a single row or the same number of rows as X');
end
L = sum(L.^2,2);

d = L./(2*sig.^2);