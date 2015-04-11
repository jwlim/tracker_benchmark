% Display tracking results
%
% displayTrackingReuslts(I,target,particles,W,T0,IDX0,T,IDX,frame,param)
% 
% Input:
%             I - Current frame
%             target - Target state 
%             frame - Frame number
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function displayTrackingReuslts(I,target,fno)

% figure(10);
% colormap gray;
x0 = target(1);
y0 = target(2);
w = target(3);
h = target(4);
% imagesc(I);
imshow(I)
hold on; 
% axis off;
plot([x0,x0+w,x0+w,x0,x0],...
    [y0,y0,y0+h,y0+h,y0],'-r','LineWidth',4);hold off;
% set(gca,'Unit','normalized','Position',[0 0 1 1]);
% text(0.1,0.1,num2str(fno),'fontsize',14);

text(10, 15, '#', 'Color','y', 'FontWeight','bold', 'FontSize',24);
text(30, 15, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',24);

drawnow;