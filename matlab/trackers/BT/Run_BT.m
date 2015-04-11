
function results = Run_BT(imgfilepath_fmt, img_range_str, init_rect, opt)

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

x = init_rect(1) - 1;  %- Matlab to C.
y = init_rect(2) - 1;
w = init_rect(3);
h = init_rect(4);

cfg = opt.test_cfg;

% seq = FindSeqInfo(imgfilepath_fmt, img_range_str, opt);

% command = ['BoostingTracker.exe 100 0.99 2 0 0 0 ' seq.name ' ' seq.path ' ' ...
%   num2str(seq.startFrame) ' ' num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' ...
%   seq.ext ' ' num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];

command = sprintf(...
  '%s/BoostingTracker.exe 100 0.99 2 0 0 0 %s %s %d %d %d %s %d %d %d %d', ...
  opt.tracker_dir, cfg.name, cfg.img_dir, cfg.start, cfg.end, 1, cfg.ext, ...
  x, y, w, h);

command = strrep(command, '/', '\\');
disp(command);
keyboard;

tic
% dos(command);
system(command);
duration = toc;
num_frames = (cfg.end - cfg.start + 1);

results.res = dlmread([seq.name '_BT.txt']);   
results.res(:,1:2) = results.res(:, 1:2) + 1;  %- C to Matlab.
results.type = 'rect';
results.fps = num_frames / duration;
% results.fps = dlmread([seq.name '_BT_FPS.txt']);

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, duration, results.fps);
end


% function seq = FindSeqInfo(imgfilepath_fmt, img_range_str, opt)
% 
% tok = regexp(imgfilepath_fmt, [opt.data_dir '[/\\]*([^/\\]*).*\.([^\.]*)'], 'tokens');
% seq.name = tok{1}{1};
% seq.ext = tok{1}{2};
% 
% tok = regexp(imgfilepath_fmt, '(.*)[/\\]([^\\]*)', 'tokens');
% seq.img_dir = tok{1}{1};
% seq.file_fmt = tok{1}{2};
% 
% tok = regexp(img_range_str, '([^:]*):([^:]*):?([^:]*)?', 'tokens');
% if isempty(tok{1}{3})
%   seq.start = str2double(tok{1}{1});
%   seq.step = 1;
%   seq.end = str2double(tok{1}{2});
% else
%   seq.start = str2double(tok{1}{1});
%   seq.step = str2double(tok{1}{2});
%   seq.end = str2double(tok{1}{3});
% end
% 
% seq
% end
