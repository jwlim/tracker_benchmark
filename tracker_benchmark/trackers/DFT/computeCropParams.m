
% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function cropParams = computeCropParams(currPos, imsize, wsize, maxShift, gaussWidth)

% Computes the cropping parameters (startHeight, startWidth, sizeHeight, sizeWidth) of the window 

% INPUT parameters: 
% origPos -- current position of the tracked object 
% imsize -- size of the big image that will be cropped 
% wsize -- size of the patch that is being tracked
% maxShift -- max shift that the algorithm is going to look for (in pixels)
% gaussWidth -- width of the kernel that will be used to convolve 

startHeight = max(1, currPos(1) - floor(gaussWidth/2) - maxShift);
startWidth = max(1, currPos(2) - floor(gaussWidth/2) - maxShift);

endHeight = min(imsize(1), currPos(1) + wsize(1) + 2*floor(gaussWidth/2) + 2*maxShift -1);
endWidth = min(imsize(2), currPos(2) + wsize(2) + 2*floor(gaussWidth/2) + 2*maxShift -1);

cropParams = [startHeight, startWidth, endHeight-startHeight+1, endWidth-startWidth+1]; 





