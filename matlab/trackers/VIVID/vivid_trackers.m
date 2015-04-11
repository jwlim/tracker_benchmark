
function results = vivid_trackers(tracker_idx, imgfilepath_fmt, img_range_str, init_rect, opt)

%- Platform check.
if nargin < 1
  switch computer('arch')
    case {'win32', 'win64'}
      results = {};  %- Supported platforms. Do nothing.
    case {'glnx86', 'glnx64', 'maci64'}
      error(['Unsupported planform - ' computer('arch') '.']);
    otherwise
      error(['Unknown planform - ' computer('arch') '.']);
  end
  return;
end

if nargin < 4, opt = struct('dumppath_fmt','-', 'tracker_path','./'); end;

% Flag to use object mask or not.
flag_use_obj_mask = false;

img_range = eval(img_range_str);
num_frames = numel(img_range);

img = imread(sprintf(imgfilepath_fmt, img_range(1)));
if size(img, 3) == 1, img = repmat(img, [1,1,3]); end;

% Setup object mask.
[h, w, ~] = size(img);
obj_mask = zeros(h, w, 'uint8');

% Setup object bounding box.
left = init_rect(1);
top = init_rect(2);
right = init_rect(1) + init_rect(3) - 1;
bottom = init_rect(2) + init_rect(4) - 1;

obj_mask(top:bottom, left:right) = 255;
obj_box = [left, right, top, bottom];

if ~isempty(opt.dumppath_fmt)
  PlotResultRect(img, img_range(1), init_rect, opt.dumppath_fmt);
end

% Determine the init and next functions.
switch tracker_idx
  case 1;
    func_tracker_init = 'tkTemplateMatch_Init';
    func_tracker_next = 'tkTemplateMatch_Next';
  case 2;
    func_tracker_init = 'tkMeanShift_Init';
    func_tracker_next = 'tkMeanShift_Next';
  case 3;
    func_tracker_init = 'tkVarianceRatio_Init';
    func_tracker_next = 'tkVarianceRatio_Next';
  case 4;
    func_tracker_init = 'tkPeakDifference_Init';
    func_tracker_next = 'tkPeakDifference_Next';
  case 5;
    func_tracker_init = 'tkRatioShift_Init';
    func_tracker_next = 'tkRatioShift_Next';
  otherwise;
    error(['invalid tracker_idx ' num2str(tracker_idx)]);
end

% Initialize tracker on the first frame.
if flag_use_obj_mask
  model = feval(func_tracker_init, img, obj_box, obj_mask);
else
  model = feval(func_tracker_init, img, obj_box);
end

res = zeros(num_frames, 4);
res(1,:) = init_rect;
duration = 0;
for i = 2:num_frames
  % Read the next frame.
  img = imread(sprintf(imgfilepath_fmt, img_range(i)));
  if size(img, 3) == 1, img = repmat(img, [1,1,3]); end;
  
  tic
  [rst_box, obj_mask] = feval(func_tracker_next, model, img, obj_box);
  duration = duration + toc;
  
  w = rst_box(2) - rst_box(1) + 1;
  h = rst_box(4) - rst_box(3) + 1;
  
  if w < init_rect(3)
    if rst_box(1) + init_rect(3) - 1 <= size(img, 2)
      rst_box(2) = rst_box(1) + init_rect(3) - 1;
    else
      rst_box(1) = rst_box(2) - init_rect(3) + 1;
    end
  end
  
  if h < init_rect(4)
    if rst_box(3) + init_rect(4) - 1 <= size(img, 1)
      rst_box(4) = rst_box(3) + init_rect(4) - 1;
    else
      rst_box(3) = rst_box(4) - init_rect(4) + 1;
    end
  end
  
  res(i,:) = [rst_box(1), rst_box(3), ...
    rst_box(2) - rst_box(1) + 1, rst_box(4) - rst_box(3) + 1];
  obj_box = rst_box;
  
  if ~isempty(opt.dumppath_fmt)
    PlotResultRect(img, img_range(i), res(i,:), opt.dumppath_fmt);
  end
end

results.res = res;
results.type = 'rect';
results.fps = (num_frames - 1) / duration;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, duration, results.fps);

end

% 
% 
% 
% 
% % function results=vivid_trackers(seq, res_path, bSaveImage,trackerIdx)
% 
% fstart = seq.startFrame;
% s_frames = seq.s_frames;
% 
% im = imread(s_frames{1});
% 
% % if size(im,3)==1
% %     results.info = 'Gray! Needs color input';
% %     results.res=[];
% %     return;
% % end
% 
% if size(im,3)==1
%   imRGB(:,:,1)=im;
%   imRGB(:,:,2)=im;
%   imRGB(:,:,3)=im;
%   im = uint8(imRGB);
% end
% 
% %get size
% nrows = size(im,1);
% ncols = size(im,2);
% 
% %display image
% if bSaveImage
%   imshow(im)
% end
% 
% %get object mask;
% objMask = zeros(nrows, ncols)*255;
% objMask = uint8(objMask);
% 
% %get object bounding box
% 
% r=seq.init_rect;
% 
% left=r(1);
% top=r(2);
% right=r(1)+r(3)-1;
% bottom=r(2)+r(4)-1;
% 
% objMask(top:bottom,left:right)=255;
% 
% objBox = [left,right,top,bottom];
% % figure(1);
% if bSaveImage
%   drawboxmm(objBox(1),objBox(2),objBox(3),objBox(4),'b',3);
% end
% %use object mask or not
% maskFlag = 0;
% 
% %tracker selection
% % trackerIdx = 3;
% tracker_name =[];
% 
% %initialize tracker on first frame
% switch trackerIdx
%   case 1
%     if maskFlag == 1
%       initModel = tkTemplateMatch_Init(im, objBox, objMask);
%     else
%       initModel = tkTemplateMatch_Init(im, objBox);
%     end
%   case 2
%     if maskFlag == 1
%       initModel = tkMeanShift_Init(im, objBox, objMask);
%     else
%       initModel = tkMeanShift_Init(im, objBox);
%     end
%   case 3
%     if maskFlag == 1
%       initModel = tkVarianceRatio_Init(im, objBox,objMask);
%     else
%       initModel = tkVarianceRatio_Init(im, objBox);
%     end
%   case 4
%     if maskFlag == 1
%       initModel = tkPeakDifference_Init(im, objBox,objMask);
%     else
%       initModel = tkPeakDifference_Init(im, objBox);
%     end
%   case 5
%     if maskFlag == 1
%       initModel = tkRatioShift_Init(im, objBox,objMask);
%     else
%       initModel = tkRatioShift_Init(im, objBox);
%     end
% end
% 
% 
% % now go to next frame...
% nextframe = fstart+1;
% 
% res = zeros(seq.len,4);
% res(1,:)=seq.init_rect;
% duration = 0;
% for t = 2:seq.len
%   % read the next frame
%   
%   im = imread(s_frames{t});
%   
%   if size(im,3)==1
%     imRGB(:,:,1)=im;
%     imRGB(:,:,2)=im;
%     imRGB(:,:,3)=im;
%     im = uint8(imRGB);
%   end
%   %     fprintf('#%d\n', t);
%   
%   % display image
%   %     figure(1); clf;
%   %     imagesc(im)
%   %     %axis equal;
%   if bSaveImage
%     imshow(im)
%   end
%   
%   tic
%   switch trackerIdx
%     case 1
%       [rstBox, objMask] = tkTemplateMatch_Next(initModel, im, objBox);
%     case 2
%       [rstBox, objMask] = tkMeanShift_Next(initModel, im, objBox);
%     case 3
%       [rstBox, objMask] = tkVarianceRatio_Next(initModel, im, objBox);
%     case 4
%       [rstBox, objMask] = tkPeakDifference_Next(initModel, im, objBox);
%     case 5
%       [rstBox, objMask] = tkRatioShift_Next(initModel, im, objBox);
%   end
%   duration=duration+toc;
%   w = rstBox(2)-rstBox(1)+1;
%   h = rstBox(4)-rstBox(3)+1;
%   
%   if w < seq.init_rect(3)
%     if rstBox(1) + seq.init_rect(3) - 1 <= size(im,2)
%       rstBox(2) = rstBox(1) + seq.init_rect(3) - 1;
%     else
%       rstBox(1) = rstBox(2) - seq.init_rect(3) + 1;
%     end
%   end
%   
%   if h < seq.init_rect(4)
%     if rstBox(3) + seq.init_rect(4) - 1 <= size(im,1)
%       rstBox(4) = rstBox(3) + seq.init_rect(4) - 1;
%     else
%       rstBox(3) = rstBox(4) - seq.init_rect(4) + 1;
%     end
%   end
%   %
%   %     if w < 5
%   %         rstBox(2) = rstBox(1) + 4;
%   %     end
%   %
%   %     if h < 5
%   %         rstBox(4) = rstBox(3) + 4;
%   %     end
%   
%   objBox = rstBox;
%   res(t,:)=[objBox(1), objBox(3), objBox(2)-objBox(1)+1, objBox(4)-objBox(3)+1];
%   
%   % inner bounding box (containing object)
%   %     figure(1);
%   if bSaveImage
%     drawboxmm(objBox(1),objBox(2),objBox(3),objBox(4),'r',4);
%     text(10, 15, ['#' num2str(t)], 'Color','y', 'FontWeight','bold', 'FontSize',24);
%     imwrite(frame2im(getframe(gcf)),sprintf('%s/%04d.jpg',res_path,t));
%   end
%   % display mask
%   %      figure(3); clf;
%   %      imagesc(objMask)
% end  % loop back and continue
% 
% results.type='rect';
% results.res=res;
% results.fps=(seq.len-1)/duration;
% 
% disp(['fps: ' num2str(results.fps)])
