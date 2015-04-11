% Predict chosen paritcle state at time t+1 assuming zero motion and noise
% 
% [particles] = predictParticles(particles,w,param,maxX,maxY)
% 
% Input :
%             particles - State vectors for all particles
%             w - Particle weights
%             param - Run parameters (see "loadDefaultParams" for more info.)
%             maxX,maxY - Frame support 
% 
% Output:
%             particles - Predicted particle state vectors
%             w - Updated weight vector
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [particles,w] = predictParticles(particles,w,param,maxX,maxY)

xyStd = param.xyStd;
whStd = param.whStd;

N = param.numOfParticles;

% Noisify location and scale
particles(:,1:2) = round(particles(:,1:2) + [randn(N,1)*xyStd , randn(N,1)*xyStd]);
particles(:,3:4) = round(bsxfun(@times,particles(:,3:4),1+randn(N,1)*whStd));

% Check new particles are valid (i.e. inside frame support)
i1 = particles(:,1) < 1;
i2 = particles(:,2) < 1;
particles(i1,1) = 1;
particles(i2,2) = 1;
i3 = particles(:,1)+particles(:,3)-1 > maxX;
i4 = particles(:,2)+particles(:,4)-1 > maxY;
particles(i3,3) = maxX - particles(i3,1);
particles(i4,4) = maxY - particles(i4,2);

% Remove invalid particles (e.g. w,h<1 pixel)
i = sum(particles<1,2);
particles(i>0,:)=[];    
w(i>0) = [];