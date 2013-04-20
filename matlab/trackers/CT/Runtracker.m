% Demo for compressive tracking % 
% Matlab code implemented by Kaihua Zhang, Dept.of Computing, HK PolyU.
% Email: zhkhua@gmail.com
% Date: 11/12/2011
% Revised by Kaihua Zhang, 15/12/2011
% 
clc;clear all;close all;

rand('state',0);%important
%----------------------------------
addpath('./data');
%----------------------------------
% ImgFileName = 'david'
load init.txt;
initstate = init;%initial tracker
%----------------------------Set path
% pathName = strcat('e:\trackData\',ImgFileName);
% addpath(pathName,strcat(pathName,'\imgs'));
% fpath = fullfile(strcat(pathName,'\imgs'),'*.png');
img_dir = dir('./data/*.png');
%---------------------------
%---------------------------
img = imread(img_dir(1).name);
img = double(img(:,:,1));
%----------------------------------------------------------------
trparams.init_negnumtrain = 50;%number of trained negative samples
trparams.init_postrainrad = 4.0;%radical scope of positive samples
trparams.initstate = initstate;% object position [x y width height]
trparams.srchwinsz = 20;% size of search window
% Sometimes, it affects the results.
%-------------------------
% classifier parameters
clfparams.width = trparams.initstate(3);
clfparams.height= trparams.initstate(4);
%-------------------------
% feature parameters
% number of rectangle
ftrparams.minNumRect = 2;
ftrparams.maxNumRect = 4;
%-------------------------
M = 50;% number of all weaker classifiers, i.e,feature pool
%-------------------------
posx.mu = zeros(M,1);% mean of positive features
negx.mu = zeros(M,1);
posx.sig= ones(M,1);% variance of positive features
negx.sig= ones(M,1);
%-------------------------Learning rate parameter
lRate = 0.85;
%-------------------------
%compute feature template
[ftr.px,ftr.py,ftr.pw,ftr.ph,ftr.pwt] = HaarFtr(clfparams,ftrparams,M);
%-------------------------
%compute sample templates
posx.sampleImage = sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,50);
%-----------------------------------
%--------ClfMilBoost update
%--------extract haar features
iH = integral(img);%Compute integral image
selector = 1:M;% select all weak classifier in pool
posx.feature = getFtrVal(iH,posx.sampleImage,ftr,selector);
negx.feature = getFtrVal(iH,negx.sampleImage,ftr,selector);
%--------------------------------------------------
%--------------------------------------------------
[posx.mu,posx.sig,negx.mu,negx.sig] = clfStumpUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters

posx.pospred = weakClassifier(posx,negx,posx,selector);% Weak classifiers designed by positive samples
negx.negpred = weakClassifier(posx,negx,negx,selector);% ... by negative samples

num = length(img_dir);
%--------------------------------------------------------
x = initstate(1);% x axis at the Top left corner
y = initstate(2);
w = initstate(3);% width of the rectangle
h = initstate(4);% height of the rectangle
%--------------------------------------------------------
for i = 2:num
    img = imread(img_dir(i).name);
    img = double(img(:,:,1));
    detectx.sampleImage = sampleImg(img,initstate,trparams.srchwinsz,0,100000);   
    iH = integral(img);%Compute integral image
    detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr,selector);
    %----------------------------------
    %----------------------------------
    r = weakClassifier(posx,negx,detectx,selector);% compute the classifier for all samples
    prob = sum(r);% linearly combine the weak classifier in r to the strong classifier prob
    %-------------------------------------
    [c,index] = max(prob);
    %--------------------------------
    x = detectx.sampleImage.sx(index);
    y = detectx.sampleImage.sy(index);
    w = detectx.sampleImage.sw(index);
    h = detectx.sampleImage.sh(index);
    initstate = [x y w h];
     %-------------------------------Show the tracking results
    imshow(uint8(img));
    rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');
    hold on;
    text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
    set(gca,'position',[0 0 1 1]); 
    pause(0.00001); 
    hold off;
    %------------------------------    
    posx.sampleImage = sampleImg(img,initstate,trparams.init_postrainrad,0,100000);
    negx.sampleImage = sampleImg(img,initstate,1.5*trparams.srchwinsz,4+trparams.init_postrainrad,trparams.init_negnumtrain);
    %-----------------------------------  
    %--------------------------------------------------Update all the features in pool
    posx.feature = getFtrVal(iH,posx.sampleImage,ftr,selector);
    negx.feature = getFtrVal(iH,negx.sampleImage,ftr,selector);
    %--------------------------------------------------
    [posx.mu,posx.sig,negx.mu,negx.sig] = clfStumpUpdate(posx,negx,posx.mu,posx.sig,negx.mu,negx.sig,lRate);% update distribution parameters
    posx.pospred = weakClassifier(posx,negx,posx,selector);
    negx.negpred = weakClassifier(posx,negx,negx,selector);  
end