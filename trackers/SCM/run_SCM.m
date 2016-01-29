function results=run_SCM(seq, res_path, bSaveImage)
%32bit is much faster than 64bit matlab. 2s VS 7s

close all

s_frames = seq.s_frames;

para=paraConfig_SCM(seq.name);

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

%%******************************************* Experimental Settings *********************************************%%

% addpath('./Affine Sample Functions');
% trackparam;                                                       % initial position and affine parameters
% opt.tmplsize = [32 32];                                           % [height width]
% sz = opt.tmplsize;

rect=seq.init_rect;
p = [rect(1)+rect(3)/2, rect(2)+rect(4)/2, rect(3), rect(4), 0];
sz = para.psize;
param0 = [p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0]; %param0 = [px, py, sc, th,ratio,phi];   
param0 = affparam2mat(param0); 
opt = para.opt;
opt.psize=para.psize;

n_sample = opt.numsample;

% param0 = [p(1), p(2), p(3)/sz(2), p(5), p(4)/p(3), 0];
p0 = p(4)/p(3);
% param0 = affparam2mat(param0);
param = [];
param.est = param0';

num_p = 50; % obtain positive and negative templates for the SDC
num_n = 200;

img_color = imread(s_frames{1});

if size(img_color,3)==3
    img	= double(rgb2gray(img_color));
else
    img	= double(img_color);
end
    
[A_poso A_nego] = affineTrainG(img, sz, opt, param, num_p, num_n, p0);        
A_pos = A_poso;
A_neg = A_nego;                                                     

patchsize = [6 6];% obtain the dictionary for the SGM
patchnum(1) = length(patchsize(1)/2 : 2: (sz(1)-patchsize(1)/2));
patchnum(2) = length(patchsize(2)/2 : 2: (sz(2)-patchsize(2)/2));
Fisize = 50;
[Fio patcho] = affineTrainL(img, param0, opt, patchsize, patchnum, Fisize);
Fi = Fio;    

% temp = importdata([dataPath 'datainfo.txt']);
% num = temp(3);
num=seq.endFrame-seq.startFrame+1;

paramSR.lambda2 = 0;
paramSR.mode = 2;
% paramSR.numThreads=1;
alpha_p = zeros(Fisize, prod(patchnum), num);
res = zeros(num, 6);

imageSize = [size(img,1), size(img,2)];

duration = 0;

res(1,:) = param.est';

%%******************************************* Do Tracking *********************************************%%

for f = 2:seq.len
%     disp(['# ' num2str(f)]);
    
    img_color = imread(s_frames{f});
    
    if size(img_color,3)==3
        img	= double(rgb2gray(img_color));
    else
        img	= double(img_color);
    end    
    
    %%----------------- Sparsity-based Discriminative Classifier (SDC) ----------------%%
    gamma = 0.4;
    
    tic
    
    [wimgs Y param] = affineSample(img, sz, opt, param);    % draw N candidates with particle filter
    
    YY = normVector(Y);                                             % normalization
    AA_pos = normVector(A_pos);
    AA_neg = normVector(A_neg);
    
    P = selectFeature(AA_pos, AA_neg, paramSR);                     % feature selection
    
    YYY = P'*YY;                                                    % project the original feature space to the selected feature space
    AAA_pos = P'*AA_pos;
    AAA_neg = P'*AA_neg;
    
    paramSR.L = length(YYY(:,1));                                   % represent each candidate with training template set
    paramSR.lambda = 0.01;
    beta = mexLasso(YYY, [AAA_pos AAA_neg], paramSR);
    beta = full(beta);
    
    rec_f = sum((YYY - AAA_pos*beta(1:size(AAA_pos,2),:)).^2);      % the confidence value of each candidate
    rec_b = sum((YYY - AAA_neg*beta(size(AAA_pos,2)+1:end,:)).^2);
    con = exp(-rec_f/gamma)./exp(-rec_b/gamma);                     

    %%----------------- Sparsity-based Generative Model (SGM) ----------------%%
    yita = 0.01;
    
    patch = affinePatch(wimgs, patchsize, patchnum);                % obtain M patches for each candidate
    
    Fii = normVector(Fi);                                           % normalization
    
    if f==2                                                         % the template histogram in the first frame and before occlusion handling
        xo = normVector(patcho);
        paramSR.L = length(xo(:,1));
        paramSR.lambda = 0.01;
        alpha_q = mexLasso(xo, Fii, paramSR);
        alpha_q = full(alpha_q);
        alpha_qq = alpha_q;
    end
    
    temp_q = ones(Fisize, prod(patchnum));
    sim = zeros(1,n_sample);
    b = zeros(1,n_sample);
    
    for i = 1:n_sample
        x = normVector(patch(:,:,i));                               % the sparse coefficient vectors for M patches 
        paramSR.L = length(x(:,1));      
        paramSR.lambda = 0.01;
        alpha = mexLasso(x, Fii, paramSR);
        alpha = full(alpha);
        alpha_p(:,:,i) = alpha;      
        
        recon = sum((x - Fii*alpha).^2);                            % the reconstruction error of each patch
        
        thr = 0.04;                                                 % the occlusion indicator            
        thr_lable = recon>=thr;   
        temp = ones(Fisize, prod(patchnum));
        temp(:, thr_lable) = 0;        
        
        p = temp.*abs(alpha);                                       % the weighted histogram for the candidate
        p = reshape(p, 1, numel(p));
        p = p./sum(p);
        
        temp_qq = temp_q;                                           % the weighted histogram for the template
        temp_qq(:, thr_lable) = 0;
        q = temp_qq.*abs(alpha_qq);     
        q = reshape(q, 1, numel(q));
        q = q./sum(q);
        
        lambda_thr = 0.00003;                                       % the similarity between the candidate and the template
        a = sum(min([p; q]));
        b(i) = lambda_thr*sum(thr_lable);
        sim(i) = a + b(i);
    end
    
    %%----------------- Collaborative Model ----------------%%
    likelihood = con.*sim;
    [v_max,id_max] = max(likelihood);    
    
    param.est = affparam2mat(param.param(:,id_max));
    res(f,:) = param.est';
    
        %%----------------- Update Scheme ----------------%%
    upRate = 5;
    if rem(f, upRate)==0
        [A_neg alpha_qq] = updateDic(img, sz, opt, param, num_n, p0, abs(alpha_q), abs(alpha_p(:,:,id_max)), (b(id_max)/lambda_thr)/prod(patchnum));
    end

    duration=duration+toc;
    
    if bSaveImage
        % display the tracking result in each frame
%         te      = importdata([ 'Datasets\' title '\' 'dataInfo.txt' ]);
%         imageSize = [ te(2) te(1) ];

%         if f == 1
%             figure('position',[ 100 100 imageSize(2) imageSize(1) ]);
%             set(gcf,'DoubleBuffer','on','MenuBar','none');
%         end

%         axes(axes('position', [0 0 1.0 1.0]));
%         imagesc(img_color, [0,1]);
        imshow(img_color);
        numStr = sprintf('#%03d', f);
        text(10,20,numStr,'Color','r', 'FontWeight','bold', 'FontSize',20);

        color = [ 1 0 0 ];
        [ center corners ] = drawbox(para.psize, res(f,:), 'Color', color, 'LineWidth', 2.5);

        axis off;
        drawnow;
%         saveas(gcf, [res_path num2str(f) '.jpg']);
        imwrite(frame2im(getframe(gcf)),[res_path num2str(f) '.jpg']); 
    end
end

%%******************************************* Save and Display Tracking Results *********************************************%%

% save([ title '.mat'], 'result');
% fileName = sprintf('%s%s_SCM.mat',res_path,seq.name);
% save(fileName,'result');

results.type = 'ivtAff';
results.res = res;%each row is a rectangle
results.tmplsize = para.psize;%[width, height]
results.fps=(seq.len-1)/duration;

% save([res_path seq.name '_SCM' '.mat'], 'results');

disp(['fps: ' num2str(results.fps)])


% displayResult;                                                     % display the tracking results in the whole image sequence