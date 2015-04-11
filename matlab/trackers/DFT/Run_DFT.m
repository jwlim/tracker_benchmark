
function results = Run_DFT(imgfilepath_fmt, img_range_str, init_rect, run_opt)

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


% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

% default input parameters 
params.init_pos = [init_rect(2), init_rect(1)]; %[r(1)+r(3)/2, r(2)+r(4)/2];
params.wsize = [init_rect(4), init_rect(3)];

params.nbins = 16; 
params.feat_width = 5; 
params.feat_sig = 0.625; 
params.sp_width = [9, 15];
params.sp_sig = [1, 2];
params.max_shift = 30;

% track target along sequence 
% results = trackDF(params, res_path); 

%%% INPUT PARAMETERS FOR IMAGE SEQUENCE 

% -- file_path: path where frame sequence is found, including the invariant
% part of the frames name 
% -- file_format: string containing the format of the frames 
% -- output_name: name of the output file with the positions of tracking 
% -- start_fr: number of the first frame where the target appears 
% -- end_fr: number of the last frame where you want to track the target
% -- init_pos: position of the target in the first frame, specified as [row, col]
% -- wsize: size of target specified as [height, width]

%%% INPUT PARAMETERS FOR DISTRIBUTION FIELDS 

% -- nbins: number of bins used to quantize the feature space in a DF  
% -- feat_width: width of kernel for convolving a DF in feature space 
% -- feat_sig: std dev of the gaussian kernel for convolving a DF in feat space
% -- sp_width: set of widths of the kernels for convolving a DF in image space
% -- sp_sig: set of std devs of the gaussian kernels for convolving a DF in image space
% -- max_shift: maximum number of pixels the target is expected to move 

%%% OUTPUT

% -- positions: n-by-2 array containing the positions of the object at each
% frame 


% rename variables for clarity
init_pos = params.init_pos;
wsize = params.wsize;
nbins = params.nbins;
feat_width = params.feat_width; 
feat_sig = params.feat_sig;
sp_width = params.sp_width;
sp_sig = params.sp_sig;
max_shift = params.max_shift;

% Read first frame and crop target
img = imread(sprintf(imgfilepath_fmt, img_range(1)));
f1 = double(img);
f1 = f1(init_pos(1):init_pos(1)+wsize(1)-1, init_pos(2):init_pos(2)+wsize(2)-1);

% Compute and smooth DF of target with different levels of blur
df = img2df(f1, nbins);
for i=1:length(sp_width)
    target_models{i} = smoothDF(df, [sp_width(i) feat_width], [sp_sig(i), feat_sig]);
end;


% track the object along the sequence 
% num_frames = end_fr - start_fr +1; 
positions = zeros(num_frames, 2);
positions(1,:) = init_pos;
last_motion = [0, 0];


res = zeros(num_frames, 4);
res(:,3:4) = repmat([wsize(2), wsize(1)], [num_frames,1]);
res(1,1:2) = [init_pos(2), init_pos(1)];
if ~isempty(run_opt.dumppath_fmt)
    PlotResultRect(img, img_range(1), res(i,:), run_opt.dumppath_fmt);
end

duration = 0;

for i=2:num_frames

    % read image
    img = imread(sprintf(imgfilepath_fmt, img_range(i)));
    f2 = double(img);
    
    tic
    % compute new starting position using last motion
    init_pos = computeStartingPoint(init_pos, last_motion, wsize, size(f2));
    % crop the image around the starting position for speed
    crop_params = computeCropParams(init_pos, size(f2), wsize, max_shift, sp_width(end));
    f2 = f2(crop_params(1):crop_params(1)+crop_params(3)-1, crop_params(2):crop_params(2)+crop_params(4)-1);
    
    % find target in frame 
    pts = findTargetHier(target_models, f2, init_pos-crop_params(1:2)+1, wsize, sp_width, sp_sig, feat_width, feat_sig, nbins); 
    end_pos = pts(end, :);
    
    % update target model 
    f2 = f2(end_pos(1):end_pos(1)+wsize(1)-1, end_pos(2):end_pos(2)+wsize(2)-1);
    df2 = img2df(f2, nbins);
    for j = 1:length(sp_width)
        df2_s = smoothDF(df2, [sp_width(j) feat_width], [sp_sig(j), feat_sig]);
        target_models{j} = 0.95.*target_models{j} + 0.05.*df2_s;
    end;
    
    duration = duration + toc;
    
    % store res
    end_pos = end_pos + crop_params(1:2) - 1;
    positions(i, :) = end_pos;
    res(i,2:-1:1) = end_pos;
    
    last_motion = end_pos - init_pos;
    init_pos = end_pos; 
    
    if ~isempty(run_opt.dumppath_fmt)
        PlotResultRect(img, img_range(i), res(i,:), run_opt.dumppath_fmt);
    end
end

results.res = res;
results.type = 'rect';
results.fps = (num_frames - 1) / duration;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, duration, results.fps);

end


