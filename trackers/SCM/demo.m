%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

%%******************************************* Experimental Settings *********************************************%%

clc;
clear all;
addpath('./Affine Sample Functions');
trackparam;                                                       % initial position and affine parameters
opt.tmplsize = [32 32];                                           % [height width]
sz = opt.tmplsize;
n_sample = opt.numsample;

param0 = [p(1), p(2), p(3)/sz(2), p(5), p(4)/p(3), 0];
p0 = p(4)/p(3);
param0 = affparam2mat(param0);
param = [];
param.est = param0';

num_p = 50;                                                         % obtain positive and negative templates for the SDC
num_n = 200;
[A_poso A_nego] = affineTrainG(dataPath, sz, opt, param, num_p, num_n, forMat, p0);        
A_pos = A_poso;
A_neg = A_nego;                                                     

patchsize = [6 6];                                                  % obtain the dictionary for the SGM
patchnum(1) = length(patchsize(1)/2 : 2: (sz(1)-patchsize(1)/2));
patchnum(2) = length(patchsize(2)/2 : 2: (sz(2)-patchsize(2)/2));
Fisize = 50;
[Fio patcho] = affineTrainL(dataPath, param0, opt, patchsize, patchnum, Fisize, forMat);
Fi = Fio;    

temp = importdata([dataPath 'datainfo.txt']);
num = temp(3);
paramSR.lambda2 = 0;
paramSR.mode = 2;
alpha_p = zeros(Fisize, prod(patchnum), num);
result = zeros(num, 6);

%%******************************************* Do Tracking *********************************************%%

for f = 1:num
    f
    img_color = imread([dataPath int2str(f) forMat]);
    if size(img_color,3)==3
        img	= rgb2gray(img_color);
    else
        img	= img_color;
    end
    
    %%----------------- Sparsity-based Discriminative Classifier (SDC) ----------------%%
    gamma = 0.4;
    
    [wimgs Y param] = affineSample(double(img), sz, opt, param);    % draw N candidates with particle filter
    
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
    
    if f==1                                                         % the template histogram in the first frame and before occlusion handling
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
    result(f,:) = param.est';
    displayResult_sf;                                               % display the tracking result in each frame
    
    %%----------------- Update Scheme ----------------%%
    upRate = 5;
    if rem(f, upRate)==0
        [A_neg alpha_qq] = updateDic(dataPath, sz, opt, param, num_n, forMat, p0, f, abs(alpha_q), abs(alpha_p(:,:,id_max)), (b(id_max)/lambda_thr)/prod(patchnum));
    end
end

%%******************************************* Save and Display Tracking Results *********************************************%%

save([ title '.mat'], 'result');
% displayResult;                                                     % display the tracking results in the whole image sequence