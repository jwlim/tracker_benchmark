% Estimate Gaussian sigma value for time t+1
% 
% [estSig] = estimateSigma(F1,F2,flow,curSig,priorVar,priorVarW,alpha)
% 
% Input :
%             F1,F2- Signatures for EMD calculation
%             flow - EMD flow matrix {from,to,amount}
%             curSig - Sigma value from time t
%             priorVar - Gaussian variance prior
%             priorVarW - Gaussian variance prior weight
%             alpha - Moving average "forgetness" factor
% 
% Output:
%             estSig - Estimated sigma value  
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [estSig] = estimateSigma(F1,F2,flow,curSig,priorVar,priorVarW,MAalpha)

% Build cost matrix
distParam.sigA = curSig;
D = buildCostMatrix(F1,F2,'l2',distParam);

% Build flow matrix
N = size(F1,1);
M = size(F2,1);
F = zeros(N,M);
F(flow(:,1)+1 + (flow(:,2))*N) = flow(:,3);

% Calculate ML variance based on last time step
newVar = (1/size(F1,2))*sum2(D.^2.*F)/sum2(F);

% Calculate MAP variance based on last time step
estVar = (newVar + priorVar*priorVarW)/(1 + priorVarW);

% Regulate sigma (std) using MA process over time
estSig = sqrt((1-MAalpha)*curSig^2 + MAalpha*estVar);