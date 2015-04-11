% Estimate ground distance parameters sigA & sigL based on EMD flow
% 
% [distParams] = estimateGaussGaussParams(S0,S,flow,param,distParams)
% 
% Input :
%             S0,S- Signatures of template and final candidate 
%             flow - EMD flow matrix {from,to,amount} 
%             param - Run parameter struct (see "loadDefaultParams" for more info.)
%             distParams - Parameters for distance calculation 
% 
% Output:
%             distParams - Updated params 
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [distParams] = estimateGaussGaussParams(S0,S,flow,param,distParams)

sigA = distParams.sigA;
sigL = distParams.sigL;

% fprintf('(sigA,sigL) = (%.3f,%.3f) <-- ',sigA,sigL);

sigA = estimateSigma(S0(:,3:end),S(:,3:end),flow,sigA,param.priorVarA,param.priorVarAW,param.MAalpha);
sigL = estimateSigma(S0(:,1:2),S(:,1:2),flow,sigL,param.priorVarL,param.priorVarLW,param.MAalpha);

% fprintf('(%.3f,%.3f)\n',sigA,sigL);

distParams.sigA = sigA;
distParams.sigL = sigL;
