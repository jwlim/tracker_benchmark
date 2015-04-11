
function results = Run_TLD(imgfilepath_fmt, img_range_str, init_rect, run_opt)

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


rand('state', 0);
randn('state', 0);

min_win             = 24; % minimal size of the object's bounding box in the scanning grid, it may significantly influence speed of TLD, set it to minimal size of the object
patchsize           = [15 15]; % size of normalized patch in the object detector, larger sizes increase discriminability, must be square
fliplr              = 0; % if set to one, the model automatically learns mirrored versions of the object
maxbbox             = 1; % fraction of evaluated bounding boxes in every frame, maxbox = 0 means detector is truned off, if you don't care about speed set it to 1
update_detector     = 1; % online learning on/off, of 0 detector is trained only in the first frame and then remains fixed

init_w = init_rect(3);
init_h = init_rect(4);
if min(init_w, init_h) < min_win
  min_win = min(init_w, init_h);
end

param.model           = struct('min_win',min_win,'patchsize',patchsize,'fliplr',fliplr,'ncc_thesame',0.95,'valid',0.5,'num_trees',10,'num_features',13,'thr_fern',0.5,'thr_nn',0.65,'thr_nn_valid',0.7);
param.p_par_init      = struct('num_closest',10,'num_warps',20,'noise',5,'angle',20,'shift',0.02,'scale',0.02); % synthesis of positive examples during initialization
param.p_par_update    = struct('num_closest',10,'num_warps',10,'noise',5,'angle',10,'shift',0.02,'scale',0.02); % synthesis of positive examples during update
param.n_par           = struct('overlap',0.2,'num_patches',100); % negative examples initialization/update
param.tracker         = struct('occlusion',10);
param.control         = struct('maxbbox',maxbbox,'update_detector',update_detector,'drop_img',1,'repeat',1);
param.plot            = struct('pex',1,'nex',1,'dt',1,'confidence',1,'target',1,'replace',0,'drawoutput',3,'draw',0,'pts',1,'help', 0,'patch_rescale',1,'save',0); 

param.medFB_thred = 10; %for the function tldTracking
% opt.source          = struct('camera',0,'input','F:\data\VIVID\rgb\','bb0',[]); 

num_frames = numel(img_range);
param.nFrames = num_frames;

addpath([run_opt.tracker_dir 'tld']);
addpath([run_opt.tracker_dir 'mex']);
addpath([run_opt.tracker_dir 'img']);
addpath([run_opt.tracker_dir 'bbox']);
addpath([run_opt.tracker_dir 'utils']);


% Run TLD -----------------------------------------------------------------
% function [bb,conf,fps] = tldExample(opt)

% global tld; % holds results and temporal variables

% img = img_alloc(opt.s_frames{1}); 
param.source.im0 = img_alloc(sprintf(imgfilepath_fmt, img_range(1)));
param.source.bb = Rect2BBox(init_rect)';

tic
tld = tldInit(param, []); % train initial detector and initialize the 'tld' structure
total_time = toc;

if ~isempty(run_opt.dumppath_fmt)
  PlotResultRect(tld.img{1}.input, img_range(1), BBox2Rect(tld.source.bb), run_opt.dumppath_fmt);
end
% if ~isempty(dumppath_fmt)                                                                                                        
%   figure(1);
%   imshow(tld.img{1}.input);
%   bb = tld.source.bb;
%   rectangle('Position',[bb(1), bb(2), bb(3)-bb(1), bb(4)-bb(2)], 'LineWidth', 4, 'EdgeColor', 'r');
%   text(10, 15, ['#' num2str(1)], 'Color', 'y', 'FontWeight', 'bold', 'FontSize', 24);
%   
%   imwrite(frame2im(getframe(gcf)), sprintf(dumppath_fmt, img_range(1)));
% end

for i = 2:num_frames
  tld.img{i} = img_alloc(sprintf(imgfilepath_fmt, img_range(i)));
  tic
  tld = tldProcessFrame(tld, i);  % process frame i
  total_time = total_time + toc;
  
  if ~isempty(run_opt.dumppath_fmt)
    PlotResultRect(tld.img{i}.input, img_range(i), BBox2Rect(tld.bb(:,i)), run_opt.dumppath_fmt);
  end
%   if ~isempty(dumppath_fmt)
%     figure(1);
%     imshow(tld.img{i}.input);
%     text(10, 15, ['#' num2str(i)], 'Color','y', 'FontWeight','bold', 'FontSize',24);
%     bb=tld.bb(:,i);
%     if bb(3) > bb(1) && bb(4) > bb(2)
%       rectangle('Position',[bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)],'LineWidth',4,'EdgeColor','r')      
%     end
%     drawnow;
%     imwrite(frame2im(getframe(gcf)), sprintf(dumppath_fmt, img_range(i)));
%   end  
end


% Save results ------------------------------------------------------------
% dlmwrite([opt.output '/tld.txt'],[bb; conf]');
% disp('Results saved to ./_output.');

rmpath([run_opt.tracker_dir 'tld']);
rmpath([run_opt.tracker_dir 'mex']);
rmpath([run_opt.tracker_dir 'img']);
rmpath([run_opt.tracker_dir 'bbox']);
rmpath([run_opt.tracker_dir 'utils']);

results.type = 'rect';
results.res = BBox2Rect(tld.bb)';  % Each row is a rectangle.
% results.res = round(res);
results.res(1,:) = init_rect(1,:);
results.fps = num_frames / total_time;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, total_time, results.fps);

end



function bbox = Rect2BBox(rect)

transpose = false;
if size(rect,2) ~= 4 && size(rect,1) == 4
  transpose = true;
  rect = rect';
end

bbox = rect;
bbox(:,3) = rect(:,1) + rect(:,3) - 1;
bbox(:,4) = rect(:,2) + rect(:,4) - 1;

if transpose
  bbox = bbox';
end

end


function rect = BBox2Rect(bbox)

transpose = false;
if size(bbox,2) ~= 4 && size(bbox,1) == 4
  transpose = true;
  bbox = bbox';
end

rect = zeros(size(bbox));
rect(:,1) = min(bbox(:,1), bbox(:,3));
rect(:,2) = min(bbox(:,2), bbox(:,4));
rect(:,3) = max(bbox(:,1), bbox(:,3)) - rect(:,1) + 1;
rect(:,4) = max(bbox(:,2), bbox(:,4)) - rect(:,2) + 1;

if transpose
  rect = rect';
end

end
