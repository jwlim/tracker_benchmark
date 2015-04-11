% Estimate unifrom mixture parameters 
% 
% [R,alpha] = estimateUniforMixAlphaAndR(F1,F2,flow,alpha,R,priorAlpha,priorAlphaW,priorR,priorRW,MAalpha)
% 
% Input :
%             F1,F2- Signatures for EMD calculation
%             flow - EMD flow matrix {to,from,amount}
%             alpha - Mixture coeficeint 
%             R - Extent on inner uniform
%             prior{R/Alpha} - Priors for R & alpha
%             prior{R/Alpha}W - Priors weights for R & alpha
%             MAalpha - Moving average parameter
% 
% Output:
%             R,alpha - Estimated parameter values  
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [R,alpha] = estimateUniforMixAlphaAndR(F1,F2,flow,alpha,R,S,priorAlpha,priorAlphaW,priorR,priorRW,MAalpha)

% Build flow matrix
[N,L] = size(F1);
M = size(F2,1);

% Build quantized CDF
d = linspace(0.01,S/2,50);
for ii = 1:length(d)
        ind = sum(bsxfun(@le,abs(F1(flow(:,1)+1,:)-F2(flow(:,2)+1,:)),d(ii)),2) == L;
        c(ii) = sum(flow(ind,3))/sum(flow(:,3));
end

% Calculate objective function for maximization at each distance
J = c.*log(c./(2*d).^L)+(1-c).*log((1-c)./(S-(2*d).^L));
J(abs(J)==inf) = log(1./(2*d(abs(J)==inf)).^L);

% Find objective function maximum
[val,ind] = max(J);
newR = d(ind);
newAlpha = (S*c(ind)-(2*d(ind)).^L)/(S-(2*d(ind)).^L);
if newAlpha == -inf
        newAlpha = 1;
end

% Calculate MAP using priors
newR = (newR + priorR*priorRW)/(1+priorRW);
newAlpha = (newAlpha + priorAlpha*priorAlphaW)/(1+priorAlphaW);

% Regulate result using MA process in time
R = newR*MAalpha + R*(1-MAalpha);
alpha = newAlpha*MAalpha + alpha*(1-MAalpha);