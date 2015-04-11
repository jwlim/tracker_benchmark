% Set ROI for superpixel calculation
% 
% [ROI] = getParticleROI(particles,siz,d)
% 
% Input :
%             particles - State vectors for all particles
%             siz - Frame support [maxX maxY]
%             d - Additional support expansion parameter  
% 
% Output:
%             particles - Predicted particle state vectors
%             w - Updated weight vector
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [ROI] = getParticleROI(particles,siz,d)

x0 = max(1,min(particles(:,1)-d));
y0 = max(1,min(particles(:,2)-d));
x1 = min(siz(1),max(particles(:,1)+particles(:,3)-1)+d);
y1 = min(siz(2),max(particles(:,2)+particles(:,4)-1)+d);

ROI = [x0 y0 x1-x0+1 y1-y0+1];