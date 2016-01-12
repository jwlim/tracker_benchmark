function results=run_CXT(seq, res_path, bSaveImage)

close all;

x=seq.init_rect(1)-1;%matlab to c
y=seq.init_rect(2)-1;
w=seq.init_rect(3);
h=seq.init_rect(4);

path = './results/';

if ~exist(path,'dir')
    mkdir(path);
end

tic
command = ['CXT.exe 1 0 0 1 ' seq.name ' ' seq.path ' ' path ' '   num2str(seq.startFrame) ' ' num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' seq.ext ' ' num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];

dos(command);
duration=toc;

results.res = dlmread([path seq.name '_CXT.txt']);   
results.res(:,1:2) =results.res(:,1:2) + 1;%c to matlab
length(results.res)

results.type='rect';
results.fps=seq.len/duration;

results.fps = dlmread([path seq.name '_CXT_FPS.txt']);

