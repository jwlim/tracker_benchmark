% Sets initial target position as defined in param or from user
% 
% [target0,T] = setInitialTargetPosition(I,param)
% 
% Input :
%             I - Initial frame
%             param - Parameter structure see loadDefaultParams.m 
%                 for more info.
% 
% Output:
%             target0 - target state [x,y,w,h]
%             T - Target patch
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [target0,T] = setInitialTargetPosition(I,param)

if isempty(param.target0)
        figure(1);
        [T,target0] = imcrop(I);
        close(1);
else
        target0 = param.target0;
        T = imcrop(I,target0);
end
fprintf('Initial State Vector [');fprintf('%.2f ',target0);fprintf(']\n');