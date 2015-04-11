function results=run_LSK(seq, res_path, bSaveImage)
%LSK is based on matlab

close all;

outputPath = './results';
configPath = './config/';

% seq.len = 100;
% seq.endFrame = seq.startFrame + seq.len - 1;

r = seq.init_rect;

name_sub_gt=[configPath seq.name '_gt.txt'];
dlmwrite(name_sub_gt,r);

xmlName = [configPath seq.name '.xml'];
fid=fopen(xmlName,'w');

sizeC=[30,30];

ratio = (sizeC(1)*sizeC(2))/(r(3)*r(4));
if ratio>=1
    ratio = 1;
else
    ratio = ceil(ratio*10)/10;
end

fprintf(fid,'<xml>\n');
fprintf(fid,'\t<properties>\n');
fprintf(fid,'\t\t<!-- resize the image to specified scale for tracking  -->\n');
fprintf(fid,'\t\t<imgScale>%.2f</imgScale>\n',ratio);
fprintf(fid,'\t\t<!-- the patch size -->\n');
fprintf(fid,'\t\t<patchSize>5</patchSize>\n');
fprintf(fid,'\t\t<!-- dictionary size (percentage) -->\n');
fprintf(fid,'\t\t<dictionarySize>0.15</dictionarySize>\n');
fprintf(fid,'\t\t<!-- the sparsity parameter K -->\n');
fprintf(fid,'\t\t<sparsityK>3</sparsityK>\n');
fprintf(fid,'\t</properties>\n');

fprintf(fid,'\t<sequence>\n');
fprintf(fid,'\t\t<name>%s</name>\n',seq.name);
fprintf(fid,'\t\t<gtFile>%s</gtFile>\n',name_sub_gt);
fprintf(fid,'\t\t<imgFolder>%s</imgFolder>\n',seq.path);
fprintf(fid,'\t\t<imgIdFormat>%%0%dd</imgIdFormat>\n',seq.nz);
fprintf(fid,'\t\t<imgExt>%s</imgExt>\n',seq.ext);
fprintf(fid,'\t\t<startFrame>%d</startFrame>\n',seq.startFrame);
fprintf(fid,'\t\t<endFrame>%d</endFrame>\n',seq.endFrame);
fprintf(fid,'\t\t<writeImage>%d</writeImage>\n', 0);
fprintf(fid,'\t\t<showResult>%d</showResult>\n', 0);
%fprintf(fid,'\t\t<outputFolder>./out_%s_%d</outputFolder>\n', s.name, idx);
fprintf(fid,'\t\t<outputFolder>%s</outputFolder>\n',outputPath);
fprintf(fid,'\t</sequence>\n');

fprintf(fid,'</xml>\n');
fclose(fid);

if ~exist(outputPath,'dir')
    mkdir(outputPath)
end

tic
command = ['spt64.exe ' xmlName];
dos(command);
duration=toc;

pause(1)

results.res = dlmread([outputPath '/' seq.name '.txt']);

results.type='rect';
results.fps=seq.len/duration;

% results.fps = dlmread([outputPath seq.name '_MIL_FPS.txt']);

