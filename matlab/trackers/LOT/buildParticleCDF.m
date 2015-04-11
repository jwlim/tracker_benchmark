% Build particle Cumulative Distribution Function
% 
% [particles,CDF] = buildCDF(particles,w)
% 
% Input :
%             particles - particle state vectors
%             w - particle weights or probabilities
% 
% Output:
%             particles - particles sorted by weight
%             CDF - Cumulative Distribution Function of particle measured probabilities
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [particles,CDF] = buildParticleCDF(particles,w)

[particles] = sortrows([particles,w],size(particles,2)+1);
w = particles(:,end);
particles(:,end) = [];
CDF = cumsum(w);