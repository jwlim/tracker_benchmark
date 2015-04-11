% Update the particles for the next frame
% 
% [particles,ROI] = updateParticles(particles,w,maxX,maxY,param)
% 
% Input :
%             particles - State vectors for all particles
%             w - Particle weights
%             maxX,maxY - Frame support 
%             param - Run parameters (see "loadDefaultParams" for more info.)
% 
% Output:
%             particles - Predicted particle state vectors
%             ROI - For building superpixel
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [particles,ROI] = updateParticles(particles,w,maxX,maxY,param)

% Build CDF
[particles,CDF] = buildParticleCDF(particles,w);

% Sample new particles according to CDF
[particles,w] = sampleParticles(particles,w,CDF,param.numOfParticles);

% Predict new particles state based on state model + Noise
[particles,w] = predictParticles(particles,w,param,maxX,maxY);

% Get ROI for superpixel 
ROI = getParticleROI(particles,[maxX maxY],param.dxySP);