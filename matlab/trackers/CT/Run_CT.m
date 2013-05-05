
function results = Run_CT(imgfilepath_fmt, img_range, init_rect, dumppath_fmt)

% mex function integral needs to be compiled.

rand('state', 0);
randn('state', 0);

% function results=run_CT(seq, res_path, bSaveImage)

%----------------------------------------------------------------
trparams.init_negnumtrain = 50;  % number of trained negative samples
trparams.init_postrainrad = 4.0;  % radical scope of positive samples
trparams.srchwinsz = 15; %20;  % size of search window

ftrparams.minNumRect = 2;  % number of rectangles
ftrparams.maxNumRect = 4;

lRate = 0.85;  % learning rate parameter
M = 150;  % number of all weaker classifiers, i.e,feature pool

initstate = init_rect;  % object position [x y width height]

num_frames = numel(img_range);

img = imread(sprintf(imgfilepath_fmt, img_range(1)));
if size(img,3) == 3, img = rgb2gray(img); end;
img = double(img);
img = img - mean(img(:));


% Sometimes, it affects the results.
%-------------------------
% classifier parameters
clfparams.width = initstate(3);
clfparams.height= initstate(4);
            
%-------------------------
posx.mu = zeros(M,1);% mean of positive features
negx.mu = zeros(M,1);
posx.sig = ones(M,1);% variance of positive features
negx.sig = ones(M,1);

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

%--------------------------------------------------------
x = initstate(1);% x axis at the Top left corner
y = initstate(2);
w = initstate(3);% width of the rectangle
h = initstate(4);% height of the rectangle
%--------------------------------------------------------
res = initstate;
duration = 0;
if ~isempty(dumppath_fmt)
    img = imread(sprintf(imgfilepath_fmt, img_range(1)));
    if size(img,3) == 3, img = rgb2gray(img); end;
    PlotResultRect(img, img_range(1), initstate, dumppath_fmt);
end

for i = 2:num_frames
    img = imread(sprintf(imgfilepath_fmt, img_range(i)));
    if size(img,3) == 3, img = rgb2gray(img); end;
    img = double(img);
%     img = imread(s_frames{i});
%     img = double(img(:,:,1));
    
    tic
    
    detectx.sampleImage = sampleImg(img,initstate,trparams.srchwinsz,0,100000);   
    iH = integral(img);%Compute integral image
    detectx.feature = getFtrVal(iH,detectx.sampleImage,ftr,selector);
    %----------------------------------
    %----------------------------------
    r = weakClassifier(posx,negx,detectx,selector);% compute the classifier for all samples
    prob = sum(r);% linearly combine the weak classifier in r to the strong classifier prob
    %-------------------------------------
    [~,index] = max(prob);
    %--------------------------------
    x = detectx.sampleImage.sx(index);
    y = detectx.sampleImage.sy(index);
    w = detectx.sampleImage.sw(index);
    h = detectx.sampleImage.sh(index);
    initstate = [x y w h];

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
    
    duration = duration + toc;
    
    res = [res; initstate];
    
    if ~isempty(dumppath_fmt)
        PlotResultRect(img, img_range(i), initstate, dumppath_fmt);
    end
end

% fileName = sprintf('%s%s_CT.mat',res_path,seq.name);
% save(fileName,'result');

results.res=res;
results.type='rect';
results.fps=(num_frames - 1) / duration;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, duration, results.fps);
% save([res_path seq.name '_CT.mat'], 'results');