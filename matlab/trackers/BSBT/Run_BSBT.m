
function results = Run_BSBT(imgfilepath_fmt, img_range_str, init_rect, run_opt)

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

if nargin < 4, run_opt = struct('dumppath_fmt','-', 'tracker_path','./'); end;

% function results=run_BSBT(seq, res_path, bSaveImage)

[pathstr, name, ext] = fileparts(imgfilepath_fmt);
nz = str2double(name(end-1));
img_range = eval(img_range_str);
% num_frames = numel(img_range);

x = init_rect(1) - 1;  % matlab to c
y = init_rect(2) - 1;
w = init_rect(3);
h = init_rect(4);

tic
command = sprintf(...
    'BeyondSemiBoostingTracker.exe 100 0.99 2 0 0 0 %s %s %d %d %d %s %d %d %d %d', ...
    'result', pathstr, img_range(1), img_range(end), nz, ext, x, y, w, h);
% command = ['BeyondSemiBoostingTracker.exe 100 0.99 2 0 0 0 ' ...
%     seq.name ' ' seq.path ' ' num2str(seq.startFrame) ' ' ...
%     num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' seq.ext ' ' ...
%     num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];
dos(command);
duration = toc;

results.res = dlmread('result_BSBT.txt');
results.res(:,1:2) = results.res(:,1:2) + 1;%c to matlab

results.type = 'rect';
results.fps = seq.len/duration;

results.fps = dlmread('result_BSBT_FPS.txt');

end
