% Updates target state to maximum likelihood state  
%
% [target] = (targetOld,particles,w,param,maxX,maxY)
% 
% Input:
%             targetOld - Target state from frame t-1
%             particles - State of all particles
%             w - Weight of each particle 
%             param - Run parameter struct (see "loadDefaultParams" for more info.)
%             maxX,maxY - Frame support
%
% Output:
%             target - New target state at frame t
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [target] = updateTargetState(targetOld,particles,w,param,maxX,maxY)

ind = find(sum(isnan(particles),2));
particles(ind,:) = [];
w(ind) = [];

target = sum(bsxfun(@times,particles,w),1);
target(3:4) = targetOld(3:4)*(1-param.MAalpha) + target(3:4)*param.MAalpha;
target = fix(target);
if target(1)<1
    target(1) = 1;
end
if target(2)<1
    target(2) = 1;
end
if target(1)+target(3)-1>maxX
    target(3) = maxX-target(1);
end
if target(2)+target(4)-1>maxY
    target(4) = maxY-target(2);
end
% fprintf('target = [');fprintf('%d ',target);fprintf(']\n');