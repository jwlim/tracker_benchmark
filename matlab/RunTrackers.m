
function [results, opt] = RunTrackers(test_name, trackers, sequences, varargin)
%
% RunTrackers : run the trackers for the test sequences.
%
% Usage:
%   RunTrackers(test_name, trackers, sequences, ...)
%     - scan the tracker_dir and setup all available trackers.
%     -> test_name : an arbitrary string for identifying the test.
%     -> trackers : a string or a cell array of tracker names.
%     -> sequences : a string or a cell array of test sequence names.
%    Options:
%     - tracker_dir : the directory containing the trackers.
%           (default: ./trackers)
%     - data_dir : the directory containing the test sequences.
%           (default: ../data)
%     - out_dir : the directory to store the test results (optional).
%           (default: ../results)
%     - result_img_dump : flag if the tracking result image is dumped.
%           It requires out_dir set. (default: false)
%
%   [results, opt] = RunTrackers(...)
%     - returns the test results and the options used for testing.

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu ()
%

if ~iscell(trackers), trackers = {trackers}; end;
if ~iscell(sequences), sequences = {sequences}; end;

if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct('tracker_dir', './trackers', 'data_dir', '../data', ...
    'out_dir', '../results/', 'result_img_dump', false);
  if ~isempty(varargin), opt = setfield(opt, varargin{:}); end;
end

if ~isempty(opt.out_dir)
  if ~exist(opt.out_dir, 'dir')
    warning('TrackerBenchmark:Generic', ...
      ['output directory (' opt.out_dir ') does not exist - creating.']);
    mkdir(opt.out_dir);
  end
elseif opt.result_img_dump
  warning('TrackerBenchmark:InvalidOption', ...
    'result_img_dump is set but out_dir is empty - turning off result_img_dump.');
  opt.result_img_dump = false;
end

num_sequences = numel(sequences);
num_trackers = numel(trackers);

seqs = cell(num_sequences, 1);
for seq_idx = 1:num_sequences
  seq = LoadSequenceConfig(sequences{seq_idx}, opt);
  seqs{seq_idx} = seq;
end

results = cell(num_trackers, num_sequences);

for tracker_idx = 1:num_trackers
  tracker_name = trackers{tracker_idx};
  addpath([opt.tracker_dir '/' tracker_name]);
  
  for seq_idx = 1:num_sequences
    seq = seqs{seq_idx};
    disp([sprintf('[t%d/%d,s%d/%d] ', ...
                  tracker_idx, num_trackers, seq_idx, num_sequences), ...
      'running ' tracker_name ' on ' seq.name ' (' ...
      num2str(numel(seq.img_range)) ' frames)...']);
    
    dumppath_fmt = '';
    if opt.result_img_dump
      dumppath_dir = [opt.out_dir '/' test_name '/' tracker_name '/' seq.name '/'];
      if ~exist(dumppath_dir, 'dir'), mkdir(dumppath_dir); end;
      dumppath_fmt = [dumppath_dir '%04d.png'];
    end
    start_time = clock;
    
%     try
      result = feval(['Run_' tracker_name], ...
        seq.imgfilepath_fmt, seq.img_range, seq.init_rect, dumppath_fmt);
%     catch err
%       warning('TrackerBenchmark:TrackerError', ...
%         ['tracker error (' tracker_name ',' seq.name ') - \n  ', ...
%         err.identifier ': ' err.message]);
%       result = struct('error', err);
%     end
    
    result.tracker = tracker_name;
    result.seq_name = seq.name;
    result.seq_range_str = seq.range_str;
    result.start_time = start_time;
    result.end_time = clock;
    results{tracker_idx, seq_idx} = result;
  end
  rmpath([opt.tracker_dir '/' tracker_name]);
end

if ~isempty(opt.out_dir)
  result_mat_path = [opt.out_dir, '/', test_name, '.mat'];
  save(result_mat_path, 'test_name', 'results', 'opt');
end
end

%   cfg = struct('name', name, 'imgfilename_fmt', imgfilename_fmt, 'range_str', range_str);
%   frames = eval(seq.range_str);
%   for idx = 1:numel(frames)
%     img_path = sprintf(seq.imgfilenam_fmt, frames(idx));
%     img = imread(img_path);
%     
%     
%     
%     numSeg = 20;
%     [subSeqs, subAnno]=splitSeqTRE(s,numSeg,rect_anno);
%     rect_anno = subAnno{1};
%     s.init_rect = rect_anno(1,:);
%     
%     for idxTrk=1:numTrk
%       t = trackers{idxTrk};
%       results = [];
%       switch t.name
%         case {'VTD','VTS'}
%           continue;
%       end
%       disp([num2str(idxSeq) ':' s.name ' ' num2str(idxTrk) ':' t.name]);
%       
%       rp = [res_path s.name '_' t.name '\'];
%       
%       if bSaveImage&~exist(rp,'dir')
%         mkdir(rp);
%       end
%       
%       funcName = ['res=run_' t.name '(s, rp, bSaveImage);'];
%       try
%         switch t.name
%           case {'VR','TM','RS','PD','MS'}
%           otherwise
%             cd(['./trackers/' t.name]);
%             addpath(genpath('./'))
%         end
%         
%         eval(funcName);
%         
%         switch t.name
%           case {'VR','TM','RS','PD','MS'}
%           otherwise
%             rmpath(genpath('./'))
%             cd('../../');
%         end
%         
%         if isempty(res)
%           results = [];
%           break;
%         end
%       catch err
%         disp('error');
%         rmpath(genpath('./'))
%         cd('../../');
%         res=[];
%         continue;
%       end
%       res.len = s.len;
%       %         res.annoBegin = s.annoBegin;
%       res.startFrame = s.startFrame;
%       res.anno = rect_anno;
%       
%       results = res;
%       
%       save([finalPath s.name '_' t.name '.mat'], 'results');
%     end
%   end
%   % fclose(fid);
%   t=clock;
%   t=uint8(t(2:end));
%   disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);
%   

% 
% % Prepare output directory.
% shift_set =  { 'left', 'right', 'up', 'down', 'topLeft', 'topRight', ...
%   'bottomLeft', 'bottomRight', 'scale_8', 'scale_9', 'scale_11', 'scale_12'};
% 
% for seq_idx = 1:numel(sequences)
%   seq = sequences{seq_idx};
% cfg = struct('name', name, 'imgfilename_fmt', imgfilename_fmt, 'range_str', range_str);
%   frames = eval(seq.range_str);
%   for idx = 1:numel(frames)
%     img_path = sprintf(seq.imgfilenam_fmt, frames(idx));
%     img = imread(img_path);
%     
%     
%     
%     numSeg = 20;    
%     [subSeqs, subAnno]=splitSeqTRE(s,numSeg,rect_anno);
%     rect_anno = subAnno{1};
%     s.init_rect = rect_anno(1,:);
%     
%     for idxTrk=1:numTrk
%         t = trackers{idxTrk};
%         results = [];
%         switch t.name
%             case {'VTD','VTS'}
%                 continue;
%         end
%         disp([num2str(idxSeq) ':' s.name ' ' num2str(idxTrk) ':' t.name]);
%         
%         rp = [res_path s.name '_' t.name '\'];
%         
%         if bSaveImage&~exist(rp,'dir')
%             mkdir(rp);
%         end
%         
%         funcName = ['res=run_' t.name '(s, rp, bSaveImage);'];
%         try
%             switch t.name
%                 case {'VR','TM','RS','PD','MS'}
%                 otherwise
%                     cd(['./trackers/' t.name]);
%                     addpath(genpath('./'))
%             end
%             
%             eval(funcName);
%             
%             switch t.name
%                 case {'VR','TM','RS','PD','MS'}
%                 otherwise
%                     rmpath(genpath('./'))
%                     cd('../../');
%             end
%             
%             if isempty(res)
%                 results = [];
%                 break;
%             end
%         catch err
%             disp('error');
%             rmpath(genpath('./'))
%             cd('../../');
%             res=[];
%             continue;
%         end
%         res.len = s.len;
%         %         res.annoBegin = s.annoBegin;
%         res.startFrame = s.startFrame;
%         res.anno = rect_anno;
%         
%         results = res;
%         
%         save([finalPath s.name '_' t.name '.mat'], 'results');
%     end
% end
% % fclose(fid);
% t=clock;
% t=uint8(t(2:end));
% disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);
% 
% 
% 
%     s.len = s.endFrame - s.startFrame + 1;
%   s.s_frames = cell(s.len,1);
%   nz	= strcat('%0',num2str(s.nz),'d'); %number of zeros in the name of image
%   for i=1:s.len
%     image_no = s.startFrame + (i-1);
%     id = sprintf(nz,image_no);
%     s.s_frames{i} = strcat(s.path,id,'.',s.ext);
%   end
%   
%     
%     results = [];
%     for idxShift=1:12
%       shiftType = shiftTypeSet{idxShift};
%       disp([num2str(idxTrk) '_' t.name ', ' num2str(idxSeq) '_' s.name ': ' num2str(idxShift) '/' num2str(length(shiftTypeSet))])
%       
%       subS = subSeqs{1};
%       r=subS.init_rect;
%       
%       r=shiftInitBB(r,shiftType,imgH,imgW);
%       
%       subS.init_rect = r;
%       
%       rp = [res_path s.name '_' t.name '_' shiftType '\'];
%       if bSaveImage&~exist(rp,'dir')
%         mkdir(rp);
%       end
%       
%       subS.name = [subS.name '_' num2str(idxShift)];
%       subS.s_frames = subS.s_frames(1:20);
%       subS.len=20;
%       subS.endFrame=20;
%       funcName = ['res=run_' t.name '(subS, rp, bSaveImage);'];
%       
%       try
%         switch t.name
%           case {'VR','TM','RS','PD','MS'}
%           otherwise
%             cd(['./trackers/' t.name]);
%             addpath(genpath('./'))
%         end
%         
%         eval(funcName);
%         
%         switch t.name
%           case {'VR','TM','RS','PD','MS'}
%           otherwise
%             rmpath(genpath('./'))
%             cd('../../');
%         end
%         
%         if isempty(res)
%           results = [];
%           break;
%         end
%       catch err
%         disp('error');
%         rmpath(genpath('./'))
%         cd('../../');
%         res=[];
%         continue;
%       end
%       
%       res.len = subS.len;
%       res.annoBegin = subS.annoBegin;
%       res.startFrame = subS.startFrame;
%       res.anno = subAnno{1};
%       res.shiftType = shiftType;
%       
%       results{idxShift} = res;
%       
%     end
%     save([finalPath s.name '_' t.name '.mat'], 'results');
%   end
% end
% % fclose(fid);
% figure
% t=clock;
% t=uint8(t(2:end));
% disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);
% 
