function results=run_CT(seq, res_path, bSaveImage)

close all;

para=paraConfig_CT(seq.name);

s_frames = seq.s_frames;

% rand('state',0);%important
%----------------------------------

%-------------------------
% feature parameters
% number of rectangle
ftrparams=para.ftrparams;

trparams =para.trparams;

M = para.M;% number of all weaker classifiers, i.e,feature pool
%-------------------------Learning rate parameter
lRate = para.lRate;

initstate = seq.init_rect;%initial tracker

img = imread(s_frames{1});

[h,w,ch] = size(img);

if ch==3
    img = double(rgb2gray(img));
else
    img = double(img);
end
img = img - mean(img(:));
% img = double(img(:,:,1));

trparams.initstate = initstate;% object position [x y width height]

% Sometimes, it affects the results.
%-------------------------
% classifier parameters
clfparams.width = trparams.initstate(3);
clfparams.height= trparams.initstate(4);
            
%-------------------------
posx.mu = zeros(M,1);% mean of positive features
negx.mu = zeros(M,1);
posx.sig= ones(M,1);% variance of positive features
negx.sig= ones(M,1);

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

num = length(s_frames);
%--------------------------------------------------------
x = initstate(1);% x axis at the Top left corner
y = initstate(2);
w = initstate(3);% width of the rectangle
h = initstate(4);% height of the rectangle
%--------------------------------------------------------
res = initstate;
duration = 0;
for i = 2:num
    img = imread(s_frames{i});
    img = double(img(:,:,1));
    
    tic
    
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
    
    if bSaveImage
     %-------------------------------Show the tracking results
        imshow(uint8(img));
        rectangle('Position',initstate,'LineWidth',4,'EdgeColor','r');
        hold on;
        text(5, 18, strcat('#',num2str(i)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
        set(gca,'position',[0 0 1 1]); 
        pause(0.00001); 
        hold off;
         saveas(gcf,[res_path num2str(i) '.jpg'])
        imwrite(frame2im(getframe(gcf)),[res_path num2str(i) '.jpg']);
    end
end

% fileName = sprintf('%s%s_CT.mat',res_path,seq.name);
% save(fileName,'result');

results.res=res;
results.type='rect';
results.fps=(seq.len-1)/duration;
disp(['fps: ' num2str(results.fps)])

% save([res_path seq.name '_CT.mat'], 'results');