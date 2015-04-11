% Build a the cost/ground distance matrix for the EMD calculation
% 
% [C] = buildCostMatrix(S1,S2,distType,vargin)
% 
% Input :
%             S1,S2- Signatures for EMD calculation
%             distType - Type of distance to be used (default is L2  norm)              
%             distParams - Parameters for distance calculation 
% 
% Output:
%             C - Cost matrix  
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [C] = buildCostMatrix(S1,S2,distType,distParams)

switch lower(distType)
    case 'l2' 
        C = buildCostMatrixL2(S1,S2);
    case 'l1'
        C = buildCostMatrixL1(S1,S2); 
    case 'gaussgauss'
        C = buildCostMatrixGaussGauss(S1,S2,distParams.sigA,distParams.sigL);
    case 'gaussuniform'
        C = buildCostMatrixGaussUniform(S1,S2,distParams.sigA,distParams.alphaL,distParams.RL,distParams.SL);
    otherwise
        error(sprintf('%s is an invalid distance type',distType));        
end

%-----------------------------------------------------------------

function [C] = buildCostMatrixL2(S1,S2)

[n1,dummy] = size(S1);
[n2,dummy] = size(S2);

C = zeros(n1,n2);

for ii = 1:n2
        C(:,ii) = sqrt(sum(bsxfun(@minus,S1,S2(ii,:)).^2,2));        
end

%-----------------------------------------------------------------

function [C] = buildCostMatrixL1(S1,S2)

[n1,dummy] = size(S1);
[n2,dummy] = size(S2);

C = zeros(n1,n2);

for ii = 1:n2
        C(:,ii) = sum(abs(bsxfun(@minus,S1,S2(ii,:))),2);        
end

%-----------------------------------------------------------------

function [C] = buildCostMatrixGaussGauss(S1,S2,sigA,sigL)

[n1,m] = size(S1);
[n2,m] = size(S2);

C = zeros(n1,n2);

for ii = 1:n2
        C(:,ii) = computeGaussDist(S1(:,1:2),S2(ii,1:2),sigL) + ...
                computeGaussDist(S1(:,3:end),S2(ii,3:end),sigA);
end

%-----------------------------------------------------------------

function [C] = buildCostMatrixGaussUniform(S1,S2,sigA,alpha,R,S)

[n1,m] = size(S1);
[n2,m] = size(S2);

C = zeros(n1,n2);

for ii = 1:n2
        C(:,ii) = computeUniformMixDist(S1(:,1:2),S2(ii,1:2),alpha,R,S) + ...
                computeGaussDist(S1(:,3:end),S2(ii,3:end),sigA);
end

