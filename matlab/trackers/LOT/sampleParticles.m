% Sample new particles from given set according to CDF
% 
% [particles] = sampleParticles(particles,w,CDF,N)
% 
% Input :
%             particles - Particle state vectors
%             w - particle weights
%             CDF - Cumulative Distribution Function of particle meaured probability
%             N - Number of particles
% 
% Output:
%             particles - New sampled particles 
%             w - Sampled particle weights
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [particles,w] = sampleParticles(particles,w,CDF,N)

[dummy,M] = size(particles);
sampledParticles = zeros(N,M);
sampledWeights = zeros(N,1);
for n = 1:N
        r = rand;
        idx = sum(CDF < r) + 1;
        sampledParticles(n,:) = particles(idx,:);
        sampledWeights(n) = w(idx);
end

particles = sampledParticles;
w = sampledWeights/sum(sampledWeights(:));