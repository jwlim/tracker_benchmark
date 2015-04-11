function results=run_SBT(seq, res_path, bSaveImage)
%bug exists

close all;

x=seq.init_rect(1)-1;%matlab to c
y=seq.init_rect(2)-1;
w=seq.init_rect(3);
h=seq.init_rect(4);

tic
command = ['SemiBoostingTracker_d.exe 100 0.99 2 0 0 0 ' seq.name ' ' seq.path ' ' num2str(seq.startFrame) ' ' num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' seq.ext ' ' num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];
dos(command);
duration=toc;

results.res = dlmread([seq.name '_SBT.txt']);   
results.res(:,1:2) =results.res(:,1:2) + 1;%c to matlab

results.type='rect';
results.fps=seq.len/duration;

results.fps = dlmread([seq.name '_SBT_FPS.txt']);

