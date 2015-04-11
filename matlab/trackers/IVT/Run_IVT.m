
function results = Run_IVT(imgfilepath_fmt, img_range_str, init_rect, run_opt)

%- Platform check.
if nargin < 1
  switch computer('arch')
    case {'win32', 'win64', 'glnx86', 'glnx64', 'maci64'}
      results = {};  %- Supported platforms. Do nothing.
    case {}
      error(['Unsupported planform - ' computer('arch') '.']);
    otherwise
      error(['Unknown planform - ' computer('arch') '.']);
  end
  return;
end

if nargin < 4, run_opt = struct('dumppath_fmt','-', 'tracker_path','./'); end;

img_range = eval(img_range_str);
num_frames = numel(img_range);


% The parameters for tracking.
cfg = struct('numsample',600, 'condenssig',0.75, 'ff',.95, ...
             'batchsize',5,'affsig', [4,4,0.01,0.0,0.005,0]);
% 'affsig',[5,5,.01,.02,.02,.01]

if ~isfield(cfg,'tmplsize')   cfg.tmplsize = [32,32];  end
if ~isfield(cfg,'numsample')  cfg.numsample = 500;  end
if ~isfield(cfg,'affsig')     cfg.affsig = [20,20,.02,.02,.005,.001];  end
if ~isfield(cfg,'condenssig') cfg.condenssig = 0.01;  end

if ~isfield(cfg,'maxbasis')   cfg.maxbasis = 16;  end
if ~isfield(cfg,'batchsize')  cfg.batchsize = 5;  end
if ~isfield(cfg,'errfunc')    cfg.errfunc = 'L2';  end
if ~isfield(cfg,'ff')         cfg.ff = 1.0;  end
if ~isfield(cfg,'minopt')
  cfg.minopt = optimset; cfg.minopt.MaxIter = 25; cfg.minopt.Display='off';
end

% Initial window for tracking.
rect = init_rect;
p = [rect(1) + rect(3)/2, rect(2) + rect(4)/2, rect(3), rect(4), 0];
param0 = affparam2mat([p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0]);

% Setup output 
total_time = 0; 
result_affmat = zeros(6, num_frames);
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

res_struct = struct('type', 'affine_ivt', 'tmplsize', cfg.tmplsize, ...
  'res', param0);
if ~isempty(run_opt.dumppath_fmt)
  PlotResultRect(img, img_range(1), res_struct, run_opt.dumppath_fmt);
end


% initialize variables
frame = double(img) / 255;

tmpl.mean = warpimg(frame, param0, cfg.tmplsize);
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

% if ~isempty(run_opt.dumppath_fmt)
%     % draw initial track window
%     drawopt = drawtrackresult([], 0, frame, tmpl, param, pts);
%     drawopt.showcondens = 0;  drawopt.thcondens = 1/cfg.numsample;
%     
%     if run_opt.dumppath_fmt ~= '-'
%         imwrite(frame2im(getframe(gcf)), sprintf(run_opt.dumppath_fmt, img_range(1)));
%     end
% end

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
    
    param = estwarp_condens(frame, tmpl, param, cfg);
    
    % do update
    wimgs = [wimgs, param.wimg(:)];
    if (size(wimgs,2) >= cfg.batchsize)
        if (isfield(param,'coef'))
            ncoef = size(param.coef,2);
            recon = repmat(tmpl.mean(:),[1,ncoef]) + tmpl.basis * param.coef;
            [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
                sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, cfg.ff);
            param.coef = tmpl.basis'*(recon - repmat(tmpl.mean(:),[1,ncoef]));
        else
            [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
                sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, cfg.ff);
        end
        %    wimgs = wimgs(:,2:end);
        wimgs = [];
        
        if (size(tmpl.basis,2) > cfg.maxbasis)
            %tmpl.reseig = opt.ff^2 * tmpl.reseig + sum(tmpl.eigval(tmpl.maxbasis+1:end).^2);
            tmpl.reseig = cfg.ff * tmpl.reseig + sum(tmpl.eigval(cfg.maxbasis+1:end));
            tmpl.basis  = tmpl.basis(:,1:cfg.maxbasis);
            tmpl.eigval = tmpl.eigval(1:cfg.maxbasis);
            if (isfield(param,'coef'))
                param.coef = param.coef(1:cfg.maxbasis,:);
            end
        end
    end
    
    total_time = total_time + toc;
    
    % draw result
    if ~isempty(run_opt.dumppath_fmt)
        res_struct.res = param.est';
        additional_imgs{1} = cat(2, tmpl.mean, param.wimg, abs(param.err)*2, param.recon);
        [h, w] = size(tmpl.mean);
        nb = min(size(tmpl.basis, 2), 10);
        basis_img = reshape(tmpl.basis(:, 1:nb), [h, w * nb]);
        basis_img(:, end + 1) = ((1:h) - 1)' / (h - 1) - 0.5;
        additional_imgs{2} = max(-0.5, min(0.5, basis_img * 4)) + 0.5;
        PlotResultRect(img, img_range(f), res_struct, run_opt.dumppath_fmt, additional_imgs);
    end
    
%     if (exist('truepts','var'))
%         trackpts(:,:,f) = param.est([3,4,1;5,6,2])*[pts0; ones(1,npts)];
%         pts = cat(3, pts0+repmat(sz'/2,[1,npts]), truepts(:,:,f), trackpts(:,:,f));
%         idx = find(pts(1,:,2) > 0);
%         if (length(idx) > 0)
%             % trackerr(f) = mean(sqrt(sum((pts(:,idx,2)-pts(:,idx,3)).^2,1)));
%             trackerr(f) = sqrt(mean(sum((pts(:,idx,2)-pts(:,idx,3)).^2,1)));
%         else
%             trackerr(f) = nan;
%         end
%         meanerr(f) = mean(trackerr(~isnan(trackerr)&(trackerr>0)));
%         if (exist('dispstr','var'))  fprintf(repmat('\b',[1,length(dispstr)]));  end;
%         dispstr = sprintf('%d: %.4f / %.4f',f,trackerr(f),meanerr(f));
%         fprintf(dispstr);
%         figure(2);  plot(trackerr,'r.-');
%         figure(1);
%     end
%     
%     %%% UNCOMMENT THIS TO SAVE THE RESULTS (uses a lot of memory)
%     %%% saved_params{f} = param;
%     if ~isempty(run_opt.dumppath_fmt)
%         drawopt = drawtrackresult(drawopt, f, frame, tmpl, param, pts);
%         if run_opt.dumppath_fmt ~= '-'
%             imwrite(frame2im(getframe(gcf)), sprintf(run_opt.dumppath_fmt, img_range(f)));
%         end
%     end
    
    result_affmat(:,f) = param.est;
end


results.type = 'affine_ivt';
results.res = result_affmat';
results.tmplsize = cfg.tmplsize;
results.fps = (num_frames - 1) / total_time;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, total_time, results.fps);

end
