
function results = ConvertResultFiles(src_test_name, dst_test_name, trackers, sequences, varargin)
%
% ConvertResultFiles : ...
%
% Usage:
%   ConvertResultFiles(src_test_name, dst_test_name, trackers, sequences, ...)
%     - scan the tracker_dir and setup all available trackers.
%     -> src/dst_test_name : an arbitrary string for identifying the test.
%     -> trackers : a string or a cell array of tracker names.
%     -> sequences : a string or a cell array of test sequence names.
%    Options:
%     - result_dir : the directory to store the test results (optional).
%           (default: ../results)

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu ()
%

if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'result_dir'), opt.result_dir = '../results/'; end;
if ~isfield(opt, 'ref_datestr'), opt.ref_datestr = ''; end;
if ~isfield(opt, 'tsre_sre_test'), opt.tsre_sre_test = ''; end;

if ~isempty(opt.result_dir) && ~exist(opt.result_dir, 'dir')
  error(['result directory (' opt.result_dir ') does not exist.']);
elseif ~exist([opt.result_dir '/' dst_test_name], 'dir')
  mkdir([opt.result_dir '/' dst_test_name]);
end

if ~iscell(trackers), trackers = {trackers}; end;
if ~iscell(sequences), sequences = {sequences}; end;

num_sequences = numel(sequences);
num_trackers = numel(trackers);

if ~isempty(opt.ref_datestr)
  ref_datenum = datenum(opt.ref_datestr);
else
  ref_datenum = datenum(clock);
end
start_time = datevec(ref_datenum);

for tracker_idx = 1:num_trackers
  tracker_name = trackers{tracker_idx};
  
  for seq_idx = 1:num_sequences
    seq_name = sequences{seq_idx};
    
    src_seq_name = seq_name;
    switch seq_name
      case 'ClifBar', src_seq_name = 'cliffbar';
    end
    src_seq_name(src_seq_name == '.') = '-';
    
    path = [opt.result_dir '/' src_test_name '/' src_seq_name '_' tracker_name '.mat'];
    disp(['loading ' path '.']);
%     try
    results = getfield(load(path), 'results');
%     catch err
%       disp(err)
%       continue
%     end
    num_results = numel(results);
    
    dst_tracker_name = ToUpper(tracker_name);
    switch dst_tracker_name
      case 'L1_APG', dst_tracker_name = 'L1APG';
    end
    
    dst_seq_name = seq_name;
    switch dst_seq_name
      case 'faceocc1', dst_seq_name = 'FaceOcc1';
      case 'faceocc2', dst_seq_name = 'FaceOcc2';
      case 'fleetface', dst_seq_name = 'FleetFace';
      case 'jogging', dst_seq_name = 'Jogging.1';
      case 'jogging-2', dst_seq_name = 'Jogging.2';
    end
    dst_seq_name(1) = ToUpper(dst_seq_name(1));
    
    new_results = cell(size(results));
    for i = 1:num_results
      res = results{i};
      if isempty(res) && i == 1
        if isempty(opt.tsre_sre_test)
          error('to load SRE result, set tsre_sre_test');
        end
        r = LoadTrackingResults(opt.tsre_sre_test, dst_seq_name, dst_tracker_name);
        new_results{i} = eval(r.load_cmds{1});
%         t = eval(r.load_cmds{1}); %- JWLIM - pami_rev hack for TRE results
%         new_results{i} = t{1}; %- JWLIM - pami_rev hack for TRE results
        continue;
      elseif isempty(res)
        error('something is wrong');
      end
      
      if numel(res) > 1
        new_results{i} = cell(size(res));
        for j = 1:numel(res)
%- HACK CSK format problem.
%           if isempty(res{j}.res), continue; end;
%           new_results{i}{j} = ConvertRes(res{j}, ...
%             dst_tracker_name, dst_seq_name, start_time, ref_datenum);
          if isempty(res{j}), continue; end;
          if isempty(res{j}.res), continue; end;
          new_results{i}{j} = ConvertRes(res{j}.res, ...
            dst_tracker_name, dst_seq_name, start_time, ref_datenum);
        end
      elseif ~isempty(res.res)
        new_results{i} = ConvertRes(res, ...
          dst_tracker_name, dst_seq_name, start_time, ref_datenum);
      end
%       type = 'unknown';
%       if isfield(res, 'transformType'), type = res.transformType; end;
%       if isfield(res, 'type'), type = res.type; end;
%       switch type
%         case 'ivtAff', type = 'affine_ivt';
%         case 'L1Aff', type = 'affine_L1';
%         case 'LK_Aff', type = 'affine_LK';
%         case '4corner', type = 'four_corners';
%         case 'affine', type = 'affine';
%         case 'SIMILARITY', type = 'similarity';
%       end
%       seq_range_str = sprintf('%d:%d', res.startFrame, ...
%         res.startFrame + res.len - 1);
%       tmplsize = [0 0];
%       fps = 0;
%       if isfield(res, 'tmplsize'), tmplsize = res.tmplsize; end;
%       if isfield(res, 'fps'), fps = res.fps; end;
%       dur_days = (fps * res.len) / (24 * 3600);
%       
%       new_results{i} = struct(...
%         'tracker', dst_tracker_name, 'seq_name', dst_seq_name, ...
%         'seq_range_str', seq_range_str, 'seq_len', res.len, 'type', type, ...
%         'res', res.res, 'tmplsize', tmplsize, 'fps', fps, ...
%         'start_time', start_time, 'end_time', datevec(ref_datenum + dur_days));
%       
%       if isfield(res, 'shiftType'), new_results{i}.shift_type = res.shiftType; end;
    end
    results = new_results;
    path = [opt.result_dir '/' dst_test_name '/' dst_seq_name '_' dst_tracker_name '.mat'];
    disp(['saving ' path '.']);
    save(path, 'dst_test_name', 'results');  % 'opt');
  end
end
end


function new_res = ConvertRes(res, dst_tracker_name, dst_seq_name, start_time, ref_datenum)
type = 'unknown';
if isfield(res, 'transformType'), type = res.transformType; end;
if isfield(res, 'type'), type = res.type; end;
switch type
  case 'ivtAff', type = 'affine_ivt';
  case 'L1Aff', type = 'affine_L1';
  case 'LK_Aff', type = 'affine_LK';
  case '4corner', type = 'four_corners';
  case 'affine', type = 'affine';
  case 'SIMILARITY', type = 'similarity';
  case 'rect', type = 'rect';
  otherwise, error(['invalid type ' type]);
end
%- HACK figure out why this happens.
switch dst_seq_name
  case 'BlurBody', res.startFrame = res.startFrame - 149;
  case 'BlurCar1', res.startFrame = res.startFrame - 246;
  case 'BlurCar2', res.startFrame = res.startFrame - 2;
  case 'BlurCar3', res.startFrame = res.startFrame - 2;
  case 'BlurCar4', res.startFrame = res.startFrame - 17;
  case 'BlurFace', res.startFrame = res.startFrame + 1;
  case 'BlurOwl', res.startFrame = res.startFrame + 1;
  case 'Tiger1', res.startFrame = res.startFrame - 5;
end
seq_range_str = sprintf('%d:%d', res.startFrame, ...
  res.startFrame + res.len - 1);
tmplsize = [0 0];
fps = 0;
if isfield(res, 'tmplsize'), tmplsize = res.tmplsize; end;
if isfield(res, 'fps'), fps = res.fps; end;
dur_days = (fps * res.len) / (24 * 3600);

new_res = struct(...
  'tracker', dst_tracker_name, 'seq_name', dst_seq_name, ...
  'seq_range_str', seq_range_str, 'seq_len', res.len, 'type', type, ...
  'res', res.res, 'tmplsize', tmplsize, 'fps', fps, ...
  'start_time', start_time, 'end_time', datevec(ref_datenum + dur_days));

if isfield(res, 'shiftType'), new_res.shift_type = res.shiftType; end;

end


function s = ToUpper(s)

for i = 1:numel(s)
  if s(i) >= 'a' && s(i) <= 'z'
    s(i) = s(i) - 'a' + 'A';
  end
end
end
