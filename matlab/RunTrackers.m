
function [results, opt] = RunTrackers(test_name, sequences, trackers, varargin)
%
% RunTrackers
% - run the trackers on the test sequences.
%
% Usage:
% [results, opt] = RunTrackers(test_name, sequences, trackers, ...)
% - test_name : the test name.
% - sequences : a name string or a cell array of test sequence names.
%       Use 'ALL' to run the trackers on all sequences. Also attribute names
%       or benchmark names such as 'OPR' or 'V11_50' can be used. Check the
%       field names of the global variable SEQUENCE_ANNOTATIONS.
% - trackers : a name string or a cell array of tracker names.
%       Use '*' to run all trackers. To see which trackers are setup, check
%       the field names of the global variable TRACKER_DIRS.
% - results : the struct with parameters and loaded tracking results.
% - opt : the option used in running the tracker.
%
% Options:
% - tracker_dir : the directory containing the trackers. (default: ./trackers)
% - data_dir : the directory containing the test sequences. (default: ../data)
% - result_dir : the directory to store the test results. (default: ../results)
% - test_type : one-pass evaluation (OPE), temporal robustness evaluation (TRE),
%       or spatial robustness evaluation (SRE). (default: 'OPE')
% - warn_tracker_errors : catch tracker errors and warn them (tracker continues).
% - plot_result : flag if the tracking result image is displayed or dumped.
%       If 'show' is given, images are only shown on the screen. If 'dump',
%       the images are stored in a directory under result_dir. (default: 'show')

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%          Yi Wu (ywu.china@gmail.com)


global TRACKER_DIRS;
if isempty(TRACKER_DIRS)
  error('TRACKER_DIR is not set. Run SetupTrackers script first.');
end

%- Process options.
if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'tracker_dir'), opt.tracker_dir = './trackers'; end;
if ~isfield(opt, 'data_dir'), opt.data_dir = '../data'; end;
if ~isfield(opt, 'result_dir'), opt.result_dir = '../results'; end;
if ~isfield(opt, 'test_type'), opt.test_type = 'OPE'; end;
if ~isfield(opt, 'warn_tracker_errors'), opt.warn_tracker_errors = true; end;
if ~isfield(opt, 'plot_result'), opt.plot_result = 'show'; end;

if any(strcmpi(opt.plot_result, {'none', 'dump', 'show'})) == false
  warning('TrackerBenchmark:InvalidOption', ...
    ['invalid plot_result (' opt.plot_result ') - setting plot_result to "none".']);
  opt.plot_result = 'none';
end
if ~isempty(opt.result_dir)
  if ~exist(opt.result_dir, 'dir')
    warning('TrackerBenchmark:Generic', ...
      ['result directory (' opt.result_dir ') does not exist - creating.']);
    mkdir(opt.result_dir);
  end
  if ~exist([opt.result_dir '/' test_name], 'dir')
    mkdir([opt.result_dir '/' test_name]);
  end
elseif strcmpi(opt.plot_result, 'dump')
  warning('TrackerBenchmark:InvalidOption', ...
    'plot_result is set to "dump" but result_dir is empty - setting plot_result to "show".');
  opt.plot_result = 'show';
end

if strcmp(trackers, '*'), trackers = fieldnames(TRACKER_DIRS); end;
if ~iscell(trackers), trackers = {trackers}; end;
num_trackers = numel(trackers);

seqs = LoadSequenceConfig(sequences, opt);
num_sequences = numel(seqs);

all_results = cell(num_trackers, num_sequences);

%- Run all trackers for each sequence.
for seq_idx = 1:numel(seqs)
  seq = seqs(seq_idx);
  seq_name = seq.name;
  
  test_cfgs = SetupTestConfigs(opt.test_type, seq, opt);
  num_test_cfgs = numel(test_cfgs);
  
  results = cell(size(test_cfgs));
  for tracker_idx = 1:num_trackers
    tracker_name = trackers{tracker_idx};
    
    dir_name = tracker_name;
    if isfield(TRACKER_DIRS, tracker_name)
      dir_name = TRACKER_DIRS.(tracker_name);
    end
    
    run_opt = opt;
    run_opt.tracker_dir = [opt.tracker_dir '/' dir_name '/'];
    
    addpath(run_opt.tracker_dir);
    
    for test_idx = 1:num_test_cfgs
      test_cfg = test_cfgs(test_idx);
      
      disp([sprintf('[%d/%d,t%d/%d,s%d/%d] ', test_idx, num_test_cfgs, ...
        tracker_idx, num_trackers, seq_idx, num_sequences), ...
        'running ' tracker_name ' on ' seq_name ' (' ...
        test_cfg.img_range_str ' frames)...']);
      
      run_opt.test_cfg = test_cfg;
      run_opt.dump_dir = [opt.result_dir '/' test_name '/' tracker_name '/' seq_name];
      if num_test_cfgs > 1
        run_opt.dump_dir = sprintf('%s.%02d', run_opt.dump_dir, test_idx);
      end
      run_opt.dumppath_fmt = '';
      if strcmpi(opt.plot_result, 'dump')
        if ~exist(run_opt.dump_dir, 'dir'), mkdir(run_opt.dump_dir); end;
        run_opt.dumppath_fmt = [run_opt.dump_dir '/%04d.png'];
      elseif strcmpi(opt.plot_result, 'show')
        run_opt.dumppath_fmt = '-';
      end
      start_time = clock;
    
      if ~opt.warn_tracker_errors
        result = feval(['Run_' tracker_name], ...
          seq.img_filepath_fmt, test_cfg.img_range_str, test_cfg.init_rect, run_opt);
      else
        try  %- Catch tracker errors and warn them (tracker continues).
          result = feval(['Run_' tracker_name], ...
              seq.img_filepath_fmt, test_cfg.img_range_str, test_cfg.init_rect, run_opt);
        catch err
            warning('TrackerBenchmark:TrackerError', ...
                ['tracker error (' tracker_name ',' seq_name ') - \n  ', ...
                err.identifier ': ' err.message]);
            result = struct('error', err);
        end
      end
      result.tracker = tracker_name;
      result.seq_name = seq_name;
      result.seq_range_str = test_cfg.img_range_str;
      result.tmplsize = test_cfg.init_rect(3:4);
      result.start_time = start_time;
      result.end_time = clock;
      
      results{test_idx} = result;
    end
    rmpath(run_opt.tracker_dir);
    
    if ~isempty(opt.result_dir)
      result_mat_path = [opt.result_dir '/' test_name '/' ...
                         seq_name '_' tracker_name '.mat'];
      save(result_mat_path, 'test_name', 'results', 'opt');
    end
    all_results{tracker_idx, seq_idx} = results;
  end
end
results = all_results;
end


function test_cfgs = SetupTestConfigs(test_type, seq, opt)
%- Find the basic sequence info.
tok = regexp(seq.img_filepath_fmt, ...
  [opt.data_dir '[/\\]*([^/\\]*).*\.([^\.]*)'], 'tokens');
test.seq_name = tok{1}{1};  %- Sequence dir.
test.ext = tok{1}{2};  %- File extension.

tok = regexp(seq.img_filepath_fmt, '(.*)[/\\]([^\\]*)', 'tokens');
test.img_dir = tok{1}{1};  %- Full directory.
test.img_file_fmt = tok{1}{2};  %- File name (printf format).

% tok = regexp(img_range_str, '([^:]*):([^:]*):?([^:]*)?', 'tokens');
tok = regexp(seq.img_range_str, '([^:]*):([^:]*)', 'tokens');
test.img_start = str2double(tok{1}{1});
test.img_end = str2double(tok{1}{2});
  
%- Find the frames with gt_rect.
img_range = eval(seq.img_range_str);
gt_rect_range = eval(seq.gt_rect_range_str);
[~, img_idx, gt_rect_idx] = intersect(img_range, gt_rect_range);

%- Setup the test
test.img_start = img_range(img_idx(1));
test.img_range_str = sprintf('%d:%d', test.img_start, test.img_end);
test.init_rect = seq.gt_rect(gt_rect_idx(1), :);

if strcmpi(test_type, 'SRE')
  [x, y] = deal(test.init_rect(1), test.init_rect(2));
  [w, h] = deal(test.init_rect(3), test.init_rect(4));
  init_rects = repmat(test.init_rect, [13, 1]);
  init_rects(1 + 3 * (0:2), 1) = round(x - 0.1 * w);
  init_rects(3 + 3 * (0:2), 1) = round(x + 0.1 * w);
  init_rects((1:3) + 0, 2) = round(y - 0.1 * h);
  init_rects((1:3) + 6, 2) = round(y + 0.1 * h);
  init_rects(10, 3:4) = round([w, h] * 0.8);
  init_rects(11, 3:4) = round([w, h] * 0.9);
  init_rects(12, 3:4) = round([w, h] * 1.1);
  init_rects(13, 3:4) = round([w, h] * 1.2);
  test_cfgs = repmat(test, [1, 13]);
  for i = 1:13
    test_cfgs(i).init_rect = init_rects(i, :);
  end
elseif strcmpi(test_type, 'TRE')
  test_cfgs = repmat(test, [1, 10]);
  num_frames = numel(img_idx);
  for i = 1:10
    test_cfgs(i).img_start = img_idx(round((i - 1) / 10 * num_frames) + 1);
    test_cfgs(i).img_range_str = ...
      sprintf('%d:%d', test_cfgs(i).img_start, test_cfgs(i).img_end);
  end
else
  test_cfgs = test;
end
end
