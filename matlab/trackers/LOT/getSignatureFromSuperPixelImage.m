%Build signature representation for provided ROI based on superpixel image  
%
% [C,W] = getSignatureFromSuperPixelImage(I,idxImg,ROI)
%
% Input:
%             I - Input image in clustering format (e.g. HSV,normalized RGB etc.)
%             idxImg -  Super Pixels index image      
%             ROI - Region of intrest [x,y,w,h]
%
% Output:
%             C - Cluster centriods in R^5
%             W - Cluster normalized weights
%             varargout - ROI area in normalized coordinates (per demand)
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [C,W,varargout] = getSignatureFromSuperPixelImage(I,idxImg,ROI)

% Crop input image and index image to ROI
I = I(ROI(2):ROI(2)+ROI(4)-1,ROI(1):ROI(1)+ROI(3)-1,:);
idxImg = idxImg(ROI(2):ROI(2)+ROI(4)-1,ROI(1):ROI(1)+ROI(3)-1);
idxImg = idxImg(:);
% idxImg(idxImg<1) = 1; %by yi wu
% Calculate geometric COG(x,y) for each cluster (equal weights)
[Y,X,D] = size(I);
if X>Y
        l1 = 1; l2 = Y/X;
else
        l1 = X/Y; l2 = 1;
end
if nargout >= 3
        varargout{1} = l1*l2;
end
[xx,yy] = meshgrid(linspace(0,l1,X),linspace(0,l2,Y));
mm = ones(size(xx));
W = accumarray(idxImg,mm(:));
x = accumarray(idxImg,xx(:))./W;
y = accumarray(idxImg,yy(:))./W;

% Calculate average appearance value per band for each cluster 
B = I(:,:,1);
b1 = accumarray(idxImg,B(:))./W;
B = I(:,:,2);
b2 = accumarray(idxImg,B(:))./W;
B = I(:,:,3);
b3 = accumarray(idxImg,B(:))./W;

% Pack to signature and normalize cluster weights
C = horzcat(x,y,b1,b2,b3);
C(W==0,:) = [];
W(W==0) = [];
W = W./sum(W(:));
