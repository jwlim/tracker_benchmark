%%% main file for running trackers
clear all;
close all;

%directory and filename prefix
prefix = '.\sample\frame0';

% start frame
fstart = 1;

% first frame
fname = sprintf('%s%04d.jpg',prefix,fstart);
im = imread(fname);
fprintf('Intialize frame: %s\n', fname);

%get size
nrows = size(im,1);
ncols = size(im,2);

%display image
figure(1);clf;
imagesc(im);
%axis equal;

%get 4 vertices of object
%fprintf('Please click 4 corners of the object to track:');
%[xbox,ybox] = ginput(4);  %user inputs corners of bounding box

xbox = [225 265 304 262];
ybox = [255 248 311 324];

%get object mask;
[xx, yy] = meshgrid(1:ncols, 1:nrows);
in = inpolygon(xx,yy,xbox,ybox);
objMask = zeros(nrows, ncols);
objMask(find(in)) = 255;
objMask = uint8(objMask);
% figure(2);
% imagesc(objMask);

%get object bounding box
xbox = round(xbox);
ybox = round(ybox);
left = min(xbox);    
right = max(xbox); 
top = min(ybox);     
bottom = max(ybox); 
objCenterx = round((left+right)/2);
objCentery = round((top+bottom)/2);
objBox = [left,right,top,bottom]; 
figure(1);
drawboxmm(objBox(1),objBox(2),objBox(3),objBox(4),'b',3);

%use object mask or not
maskFlag = 1;

%tracker selection
trackerIdx = 2;

%initialize tracker on first frame
switch trackerIdx
    case 1
        if maskFlag == 1
            initModel = tkTemplateMatch_Init(im, objBox, objMask);            
        else
            initModel = tkTemplateMatch_Init(im, objBox);
        end
    case 2
        if maskFlag == 1
            initModel = tkMeanShift_Init(im, objBox, objMask);
        else
            initModel = tkMeanShift_Init(im, objBox);
        end
    case 3
        if maskFlag == 1
            initModel = tkVarianceRatio_Init(im, objBox,objMask);
        else
            initModel = tkVarianceRatio_Init(im, objBox);
        end
    case 4
        if maskFlag == 1
            initModel = tkPeakDifference_Init(im, objBox,objMask);
        else
            initModel = tkPeakDifference_Init(im, objBox);
        end
    case 5
        if maskFlag == 1
            initModel = tkRatioShift_Init(im, objBox,objMask);                
        else
            initModel = tkRatioShift_Init(im, objBox);                
        end
end


% now go to next frame...
nextframe = fstart+1;
step=1;
loopCount = 9;
for findex = nextframe:step:nextframe+loopCount*step-1
    trainframe=findex;
    
    % read the next frame
    fname = sprintf('%s%04d.jpg',prefix,trainframe);
    im = imread(fname);
    fprintf('tracking frame: %s\n', fname);
    
    % display image
    figure(1); clf; 
    imagesc(im) 
    %axis equal;
        
    
    switch trackerIdx
        case 1
            [rstBox, objMask] = tkTemplateMatch_Next(initModel, im, objBox);
        case 2
            [rstBox, objMask] = tkMeanShift_Next(initModel, im, objBox);
        case 3 
            [rstBox, objMask] = tkVarianceRatio_Next(initModel, im, objBox);            
        case 4 
            [rstBox, objMask] = tkPeakDifference_Next(initModel, im, objBox);            
        case 5 
            [rstBox, objMask] = tkRatioShift_Next(initModel, im, objBox);                    
    end
    
    objBox = rstBox;
        
    % inner bounding box (containing object)
    figure(1);
    drawboxmm(objBox(1),objBox(2),objBox(3),objBox(4),'k',3);
    
    % display mask
%      figure(3); clf; 
%      imagesc(objMask)     
end  % loop back and continue
