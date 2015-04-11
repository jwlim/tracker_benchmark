
function results = Run_SCM(imgfilepath_fmt, img_range_str, init_rect, opt)
% function results = run_SCM(seq, res_path, bSaveImage)
%32bit is much faster than 64bit matlab. 2s VS 7s

if nargin < 4, opt = struct('dumppath_fmt','-', 'tracker_path','./'); end;

img_range = eval(img_range_str);
num_frames = numel(img_range);

addpath([opt.tracker_dir 'affine_util']);

% para = paraConfig_SCM(seq.name);
para.opt = struct('numsample', 600, 'affsig', [4,4,0.01,0.0,0.005,0]);
para.SC_param.mode = 2;
para.SC_param.lambda = 0.01;
% SC_param.lambda2 = 0.001; 
para.SC_param.pos = 'ture'; 

para.patch_size = 16;
para.step_size = 8;

para.psize = [32, 32];
para.opt.psize = para.psize;


%*************************************************************
% Copyright (C) Wei Zhong.
% All rights reserved.
% Date: 05/2012

%******************************************* Experimental Settings *********************************************%%

% addpath('./Affine Sample Functions');
% trackparam;                                                       % initial position and affine parameters
% opt.tmplsize = [32 32];                                           % [height width]
% sz = opt.tmplsize;

rect = init_rect;
p = [rect(1) + rect(3) / 2, rect(2) + rect(4) / 2, rect(3), rect(4), 0];
sz = para.psize;
param0 = [p(1), p(2), p(3)/sz(1), p(5), p(4)/p(3), 0];
% param0 = [px, py, sc, th,ratio,phi];
param0 = affparam2mat(param0); 

n_sample = para.opt.numsample;

% param0 = [p(1), p(2), p(3)/sz(2), p(5), p(4)/p(3), 0];
p0 = p(4) / p(3);
% param0 = affparam2mat(param0);
param = [];
param.est = param0';

num_p = 50; % obtain positive and negative templates for the SDC
num_n = 200;

img_color = imread(sprintf(imgfilepath_fmt, img_range(1)));
if size(img_color,3) == 3, img_color = rgb2gray(img_color); end;
img = double(img_color);
    
[A_poso, A_nego] = affineTrainG(img, sz, para.opt, param, num_p, num_n, p0);        
A_pos = A_poso;
A_neg = A_nego;                                                     

patchsize = [6 6];  % obtain the dictionary for the SGM
patchnum(1) = length(patchsize(1)/2 : 2: (sz(1)-patchsize(1)/2));
patchnum(2) = length(patchsize(2)/2 : 2: (sz(2)-patchsize(2)/2));
Fisize = 50;
[Fio patcho] = affineTrainL(img, param0, para.opt, patchsize, patchnum, Fisize);
Fi = Fio;    

% temp = importdata([dataPath 'datainfo.txt']);
% num = temp(3);

paramSR.lambda2 = 0;
paramSR.mode = 2;
% paramSR.numThreads=1;
alpha_p = zeros(Fisize, prod(patchnum), num_frames);

res = zeros(num_frames, 6);
res(1,:) = param.est';
duration = 0;

%%******************************************* Do Tracking *********************************************%%

for f = 2:num_frames
    
    img_color = imread(sprintf(imgfilepath_fmt, img_range(1)));
    if size(img_color,3) == 3, img_color = rgb2gray(img_color); end;
    img = double(img_color);
    
    %%----------------- Sparsity-based Discriminative Classifier (SDC) ----------------%%
    gamma = 0.4;
    
    tic
    
    [wimgs Y param] = affineSample(img, sz, para.opt, param);    % draw N candidates with particle filter
    
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
        [A_neg alpha_qq] = updateDic(img, sz, para.opt, param, num_n, p0, abs(alpha_q), abs(alpha_p(:,:,id_max)), (b(id_max)/lambda_thr)/prod(patchnum));
    end

    duration = duration + toc;
    
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

rmpath([opt.tracker_dir 'affine_util']);

results.type = 'affine_ivt';  % 'ivtAff';
results.res = res;
results.tmplsize = para.psize;
results.fps = (num_frames - 1) / duration;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, duration, results.fps);

end
