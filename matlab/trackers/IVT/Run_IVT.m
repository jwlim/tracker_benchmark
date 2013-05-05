
function results = Run_IVT(imgfilepath_fmt, img_range, init_rect, dumppath_fmt)

% The parameters for tracking.
opt = struct('numsample',600, 'condenssig',0.75, 'ff',.95, ...
             'batchsize',5,'affsig', [4,4,0.01,0.0,0.005,0]);
% 'affsig',[5,5,.01,.02,.02,.01]

if ~isfield(opt,'tmplsize')   opt.tmplsize = [32,32];  end
if ~isfield(opt,'numsample')  opt.numsample = 500;  end
if ~isfield(opt,'affsig')     opt.affsig = [20,20,.02,.02,.005,.001];  end
if ~isfield(opt,'condenssig') opt.condenssig = 0.01;  end

if ~isfield(opt,'maxbasis')   opt.maxbasis = 16;  end
if ~isfield(opt,'batchsize')  opt.batchsize = 5;  end
if ~isfield(opt,'errfunc')    opt.errfunc = 'L2';  end
if ~isfield(opt,'ff')         opt.ff = 1.0;  end
if ~isfield(opt,'minopt')
  opt.minopt = optimset; opt.minopt.MaxIter = 25; opt.minopt.Display='off';
end

% Initial window for tracking.
rect = init_rect;
p = [rect(1) + rect(3)/2, rect(2) + rect(4)/2, rect(3), rect(4), 0];
param0 = affparam2mat([p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0]);

num_frames = numel(img_range);

% Setup output 
total_time = 0; 
result_affmat = zeros(6, numel(img_range));
result_affmat(:,1) =  param0';

rand('state',0);
randn('state',0);


% script: runtracker.m
% requires:
%   data(h,w,nf)
%   param0
%   opt.tmplsize [h,w]
%      .numsample
%      .affsig [6,1]
%      .condenssig

% Copyright (C) Jongwoo Lim and David Ross.
% All rights reserved.

img = imread(sprintf(imgfilepath_fmt, img_range(1)));
if size(img, 3) == 3, img = rgb2gray(img); end
% initialize variables
frame = double(img) / 255;

tmpl.mean = warpimg(frame, param0, opt.tmplsize);
tmpl.basis = [];
tmpl.eigval = [];
tmpl.numsample = 0;
tmpl.reseig = 0;
sz = size(tmpl.mean);

param = [];
param.est = param0;
param.wimg = tmpl.mean;
if (exist('truepts','var'))
    npts = size(truepts,2);
    aff0 = affparaminv(param.est);
    pts0 = aff0([3,4,1;5,6,2]) * [truepts(:,:,1); ones(1,npts)];
    pts = cat(3, pts0 + repmat(sz'/2,[1,npts]), truepts(:,:,1));
    trackpts = zeros(size(truepts));
    trackerr = zeros(1,npts); meanerr = zeros(1,npts);
else
    pts = [];
end

wimgs = [];
if ~isempty(dumppath_fmt)
    % draw initial track window
    drawopt = drawtrackresult([], 0, frame, tmpl, param, pts);
    drawopt.showcondens = 0;  drawopt.thcondens = 1/opt.numsample;
    
    imwrite(frame2im(getframe(gcf)), sprintf(dumppath_fmt, img_range(1)));    
end

% save(sprintf('%sopt.%s.mat',paraD.res_path, paraD.name),'opt');

% track the sequence from frame 2 onward
for f = 2:num_frames

    img = imread(sprintf(imgfilepath_fmt, img_range(f)));
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    frame = double(img) / 255;

    % do tracking
    %  param = estwarp_grad(frame, tmpl, param, opt);
    
    tic
    
    param = estwarp_condens(frame, tmpl, param, opt);
    
    % do update
    wimgs = [wimgs, param.wimg(:)];
    if (size(wimgs,2) >= opt.batchsize)
        if (isfield(param,'coef'))
            ncoef = size(param.coef,2);
            recon = repmat(tmpl.mean(:),[1,ncoef]) + tmpl.basis * param.coef;
            [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
                sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
            param.coef = tmpl.basis'*(recon - repmat(tmpl.mean(:),[1,ncoef]));
        else
            [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
                sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
        end
        %    wimgs = wimgs(:,2:end);
        wimgs = [];
        
        if (size(tmpl.basis,2) > opt.maxbasis)
            %tmpl.reseig = opt.ff^2 * tmpl.reseig + sum(tmpl.eigval(tmpl.maxbasis+1:end).^2);
            tmpl.reseig = opt.ff * tmpl.reseig + sum(tmpl.eigval(opt.maxbasis+1:end));
            tmpl.basis  = tmpl.basis(:,1:opt.maxbasis);
            tmpl.eigval = tmpl.eigval(1:opt.maxbasis);
            if (isfield(param,'coef'))
                param.coef = param.coef(1:opt.maxbasis,:);
            end
        end
    end
    
    total_time = total_time + toc;
    
    % draw result
    if (exist('truepts','var'))
        trackpts(:,:,f) = param.est([3,4,1;5,6,2])*[pts0; ones(1,npts)];
        pts = cat(3, pts0+repmat(sz'/2,[1,npts]), truepts(:,:,f), trackpts(:,:,f));
        idx = find(pts(1,:,2) > 0);
        if (length(idx) > 0)
            % trackerr(f) = mean(sqrt(sum((pts(:,idx,2)-pts(:,idx,3)).^2,1)));
            trackerr(f) = sqrt(mean(sum((pts(:,idx,2)-pts(:,idx,3)).^2,1)));
        else
            trackerr(f) = nan;
        end
        meanerr(f) = mean(trackerr(~isnan(trackerr)&(trackerr>0)));
        if (exist('dispstr','var'))  fprintf(repmat('\b',[1,length(dispstr)]));  end;
        dispstr = sprintf('%d: %.4f / %.4f',f,trackerr(f),meanerr(f));
        fprintf(dispstr);
        figure(2);  plot(trackerr,'r.-');
        figure(1);
    end
    
    %%% UNCOMMENT THIS TO SAVE THE RESULTS (uses a lot of memory)
    %%% saved_params{f} = param;
    if ~isempty(dumppath_fmt)
        drawopt = drawtrackresult(drawopt, f, frame, tmpl, param, pts);
        imwrite(frame2im(getframe(gcf)), sprintf(dumppath_fmt, img_range(f)));    
    end
    
    result_affmat(:,f) = param.est;
end


results.type = 'affine_ivt';
results.res = result_affmat';
results.tmplsize = opt.tmplsize;
results.fps = (num_frames - 1) / total_time;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, total_time, results.fps);

end
