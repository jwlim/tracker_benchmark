
function results = Run_MIL(imgfilepath_fmt, img_range, init_rect, dumppath_fmt, tmpdir)

% function results=run_MIL(seq, res_path, bSaveImage)

close all;

x=seq.init_rect(1)-1;%matlab to c
y=seq.init_rect(2)-1;
w=seq.init_rect(3);
h=seq.init_rect(4);

% 		int strong = atoi(argv[1]);
% 		int randomSeed = atoi(argv[2]);
% 		int srchwinsz = atoi(argv[3]);%defult: 25
% 		bool bSaveImgResult = atoi(argv[4]);
% 		bool bShowImgResult = atoi(argv[5]);
outputPath = './random-30-4/';
if ~exist(outputPath,'dir')
    mkdir(outputPath)
end
tic
command = ['MIL.exe 1 4 30 0 0 ' outputPath ' ' seq.name ' ' seq.path ' '  num2str(seq.startFrame) ' ' num2str(seq.endFrame) ' '  num2str(seq.nz) ' ' seq.ext ' ' num2str(x) ' ' num2str(y) ' ' num2str(w) ' ' num2str(h)];
dos(command);
duration=toc;

% pause(1)

results.res = dlmread([outputPath seq.name '_MIL.txt']);   
results.res(:,1:2) =results.res(:,1:2) + 1;%c to matlab

results.type='rect';
results.fps=seq.len/duration;

results.fps = dlmread([outputPath seq.name '_MIL_FPS.txt']);

