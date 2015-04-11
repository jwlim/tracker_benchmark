% Perform over segmentation of input image ROI into N clusters (or less)
% Based on TurboPixels code taken from: http://www.cs.toronto.edu/~babalex/research.html
% Related publication:
% TurboPixels: Fast Superpixels Using Geometric Flows" Alex Levinshtein, Adrian Stere, 
% Kiriakos N. Kutulakos, David J. Fleet, Sven J. Dickinson, and Kaleem Siddiqi. TPAMI 2009
% (vol. 31, no. 12). 
% 
% [idxImg,varargout] = buildSuperPixelsIndexImage(I,N,ROI)
%
% Input:
%             I - Input image (RGB)
%             N - Max number of clusters
%
% Output:
%             idxImg -  Super Pixels index image  
%             disp_img - Image with superpixel overlay (per request)
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [idxImg,varargout] = buildSuperPixelsIndexImage(I,N,ROI)

% Get super pixel boundry
[phi,boundary,disp_img] = superpixels(im2double(I(ROI(2):ROI(2)+ROI(4)-1,ROI(1):ROI(1)+ROI(3)-1,:)),N); 

% Assign a label to each connected component
idx = bwlabel(~boundary, 4);

% Assign labels to boundry lines
idx = ordfilt2(idx,9,ones(3));   
idxImg = -ones(size(I,1),size(I,2));
idxImg(ROI(2):ROI(2)+ROI(4)-1,ROI(1):ROI(1)+ROI(3)-1) = idx;

if nargout==2
    varargout{1} = disp_img;
end