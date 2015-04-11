%Estimate gound distance parameters sigA, R & alpha based on EMD flow
% 
% [distParams] = estimateGaussUniformParams(S0,S,flow,param,distParams)
% 
% Input :
%             S0,S- Signatures of template and current patch 
%             flow - EMD flow matrix {from,to,amount} 
%             param - Run parameter struct (see "loadDefaultParams" for more info.)
%             distParams - Parameters for distance calculation 
% 
% Output:
%             distParams - updated params  
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [distParams] = estimateGaussUniformParams(S0,S,flow,param,distParams)

sigA = distParams.sigA;
R = distParams.RL;
alpha = distParams.alphaL;
VL = distParams.SL;

fprintf('(sigA,R,alpha) = (%.3f,%.3f,%.3f) <-- ',sigA,R,alpha);

sigA = estimateSigma(S0(:,3:end),S(:,3:end),flow,sigA,param.priorVarA,param.priorVarAW,param.MAalpha);
[R,alpha] = estimateUniforMixAlphaAndR(S0(:,1:2),S(:,1:2),flow,alpha,R,VL,...
        param.priorAlphaL,param.priorAlphaLW,param.priorRL,param.priorRLW,param.MAalpha);

fprintf('(%.3f,%.3f,%.3f)\n',sigA,R,alpha);

distParams.sigA = sigA;
distParams.RL = R;
distParams.alphaL = alpha;