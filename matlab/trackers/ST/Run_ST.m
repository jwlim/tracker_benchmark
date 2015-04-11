function results=run_ST(seq, res_path, bSaveImage)

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

close all;

x=seq.init_rect(1)-1;%matlab to c
y=seq.init_rect(2)-1;
w=seq.init_rect(3);
h=seq.init_rect(4);

%featureName kernelName param svmC svmBudgetSize searchRadius seed
%featureName: raw haar histogram
%kernelName: linear gaussian intersection chi2
%seed: default - 0
tic
command = ['struck.exe haar gaussian 0.2 100 100 30 10 ' num2str(bSaveImage) ' ' num2str(bSaveImage) ' ' seq.name ' ' seq.path ' ' num2str(seq.startFrame) ' ' num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' seq.ext ' ' num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];
dos(command);
duration=toc;

results.res = dlmread([seq.name '_ST.txt']);
results.res(:,1:2) =results.res(:,1:2) + 1;%c to matlab

results.type='rect';
results.fps=seq.len/duration;

results.fps = dlmread([seq.name '_ST_FPS.txt']);