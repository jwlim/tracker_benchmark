function results=run_CPF(seq, res_path, bSaveImage)

close all;

x=seq.init_rect(1)-1;%matlab to c
y=seq.init_rect(2)-1;
w=seq.init_rect(3);
h=seq.init_rect(4);

path = '.\results\';

tic
command = ['ObjTrk.exe 1 ' path ' ' seq.name ' ' seq.path ' ' num2str(seq.startFrame) ' ' num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' seq.ext ' ' num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];
dos(command);
duration=toc;

results.res = dlmread([path seq.name '_CPF.txt']);   
results.res(:,1:2) =results.res(:,1:2) + 1;%c to matlab

results.type='rect';
results.fps=seq.len/duration;

results.fps = dlmread([path seq.name '_CPF_FPS.txt']);

