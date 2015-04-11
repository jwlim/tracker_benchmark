%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

%%**************************************************************
temp      = importdata([ 'Datasets\' title '\' 'dataInfo.txt' ]);
imageSize = [ temp(2) temp(1) ];

trackResult     = load([   title '.mat']);
frameNum  = size(trackResult.result, 1);

figure('position',[ 100 100 imageSize(2) imageSize(1) ]); 
set(gcf,'DoubleBuffer','on','MenuBar','none');


for num = 1:frameNum
    framePath = [ 'Datasets\' title '\'  int2str(num) forMat];
    imageRGB  = imread(framePath);
    axes(axes('position', [0 0 1.0 1.0]));
    imagesc(imageRGB, [0,1]); 
    hold on; 
    numStr = sprintf('#%03d', num);
    text(10,20,numStr,'Color','r', 'FontWeight','bold', 'FontSize',20);

    if  num<=size(trackResult.result,1)
        color = [ 1 0 0 ];
        est = trackResult.result(num,:);
        [ center corners ] = drawbox([32 32], est, 'Color', color, 'LineWidth', 2.5);
    end
    
    axis off;
    hold off;
    drawnow;
    savePath = ['images\' title '\' sprintf('%s_%04d.jpg', title, num)];
    imwrite(frame2im(getframe(gcf)),savePath);
    clf;
end