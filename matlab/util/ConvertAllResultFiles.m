% Convert all result files in a directory.

ScanSequences
global SEQUENCE_ANNOTATIONS

% srcdir_path = '../TSRE-7';
% srcdir_path = '../TSRE-13-CSK';
% dstdir_path = '../results/TSRE7';

% srcdir_path = '../pami_rev/results/results_SRE_pami/';
% dstdir_path = '../results/pami14_SRE_rev';
% srcdir_path = '../pami_rev/results/results_TRE_pami_len30/';
% dstdir_path = '../results/pami14_TRE_rev';
% srcdir_path = '../pami_rev/TSRE-7/';  %- Yi's TSRE-7 results
% dstdir_path = '../results/pami14_TSRE_rev';
srcdir_path = '../pami_rev/TSRE-7/';  %- FoT results
dstdir_path = '../results/pami14_TSRE_rev';

% srcdir_path = '../results/results_TSRE-7_pami_rev';
% dstdir_path = '../results/pami14_TSRE-7_rev';
% srcdir_path = '../results/results_SRE_pami';
% dstdir_path = '../results/SRE';

if ~exist(dstdir_path, 'dir')
  mkdir(dstdir_path);
end

srcdir = dir([srcdir_path, '/*.mat']);
seq_names = {};
tracker_names = {};

for i = 1:numel(srcdir)
  entry = srcdir(i);
  if entry.isdir || entry.name(1) == '.', continue; end;
  
%   [seq_name, str] = strtok(entry.name, '_.');
%   tracker_name = strtok(str, '_.');
  
  [~, seq_name, tracker_name] = ConvertName(entry.name);
  
  seq_names = unique([ seq_names(:)', { seq_name }]);
  tracker_names = unique([ tracker_names(:)', { tracker_name }]);
end

num_seq = numel(seq_names);
num_tracker = numel(tracker_names);


%%

seq_names = SEQUENCE_ANNOTATIONS.V11_50;
tracker_names;
srcdir_path = '../pami_rev/results/results_TSRE/sub/';
dstdir_path = '../pami_rev/results/results_TSRE/';

% seqs=configSeqs_pami;
% seqs2=configSeqsRobust;
% seqs=[seqs,seqs2]; 
% trackers=configTrackers_pami;
trackers = trackers(1);
trackers{1}.name = 'FoT';

for si = 1:numel(seqs)
  s_name = seqs{si}.name;
  
  for ti = 1:numel(trackers)
    t_name = trackers{ti}.name;
    
    files = dir([srcdir_path s_name '_' t_name '_*.mat']);
    fprintf('%s%s_%s: %d files\n', srcdir_path, s_name, t_name, numel(files));
    
    num_subseqs = numel(files) / 6;
    results = {};
    for idx_shift = [1:4, 10,11]
      for i = 1:num_subseqs
        res = load([srcdir_path s_name '_' t_name '_' num2str(i+1) '_' num2str(idx_shift) '.mat']);
        results{i+1}{idx_shift} = res;
%                 save([finalPath '/sub/' s.name '_' t.name '_' num2str(i) '_' num2str(idxShift) '.mat'], 'res');
      end
    end
    save([dstdir_path s_name '_' t_name '.mat'], 'results');
  end
end
% 
% for ii = 1:numel(seqs)
%     idxSeq = selectedIdx(ii);
%     
%     s_name = seqs{idxSeq};
%     
%     s.len = s.endFrame - s.startFrame + 1;
% %     count = count + s.len;
% %     continue;
%     
%     s.s_frames = cell(s.len,1);
%     nz	= strcat('%0',num2str(s.nz),'d'); %number of zeros in the name of image
%     for i=1:s.len
%         image_no = s.startFrame + (i-1);
%         id = sprintf(nz,image_no);
%         s.s_frames{i} = strcat(s.path,id,'.',s.ext);
%     end
%     
%     img = imread(s.s_frames{1});
%     [imgH,imgW,ch]=size(img);
%     
%     rect_anno = dlmread([pathAnno s.name '.txt']);
%     numSeg = 20;
%     
% %     [subSeqs, subAnno]=splitSeqTRE(s,numSeg,rect_anno);
%     [subSeqs, subAnno]=splitSeqTRE_len(s,30,rect_anno);
% %     count = count+length(subSeqs);
% %     continue;
%     for idxTrk = 1:numel(tracker_names)
%         t_name = tracker_names{idxTrk};
%         results = [];      
% 
%         for i=2:length(subSeqs)%length(subSeqs):-1:2
%             for idxShift=[1:4, 10,11]%[5:8, 11,12]%[1:4, 9,10]%1:12
%                 res = load([final_path s.name '_' t.name '_' num2str(i) '_' num2str(idxShift) '.mat']);
%                 results{i}{idxShift} = res;
% %                 save([finalPath '/sub/' s.name '_' t.name '_' num2str(i) '_' num2str(idxShift) '.mat'], 'res');
%             end
%         end
%         save([finalPath s.name '_' t.name '.mat'], 'results');
%     end
% end

%%
tracker_names = { 'CCT', 'PCOM' };
% tracker_names = { 'FOT' };

%- Convert Yi's results_SRE to SRE format.
% tracker_names = setdiff(tracker_names, 'SPT');
% tracker_names = tracker_names(setdiff(1:numel(tracker_names), find(strcmp(tracker_names, 'SPT'))));
% tracker_names = tracker_names(setdiff(1:numel(tracker_names), find(strcmp(tracker_names, 'ITDT'))));
% results = ConvertResultFiles(srcdir_path, dstdir_path, tracker_names, seq_names);

%- HACKED in ConvertResultFiles - ConvertRes function
% results = ConvertResultFiles(srcdir_path, dstdir_path, 'ASLA', 'BlurBody');
% results = ConvertResultFiles(srcdir_path, dstdir_path, 'TLD', 'BlurCar2');
% results = ConvertResultFiles(srcdir_path, dstdir_path, 'TLD', 'BlurFace');
% results = ConvertResultFiles(srcdir_path, dstdir_path, 'TLD', 'BlurOwl');

%- For TSRE results
%- CSK result files have different format - change ConvertResultFiles
% results = ConvertResultFiles(srcdir_path, dstdir_path, 'CSK', SEQUENCE_ANNOTATIONS.V11_50, 'tsre_sre_test', 'SRE');
% tracker_names = tracker_names(setdiff(1:numel(tracker_names), find(strcmp(tracker_names, 'CSK'))));

% results = ConvertResultFiles(srcdir_path, dstdir_path, tracker_names, SEQUENCE_ANNOTATIONS.V11_100, 'tsre_sre_test', 'SRE');
results = ConvertResultFiles(srcdir_path, dstdir_path, tracker_names, SEQUENCE_ANNOTATIONS.V11_50, 'tsre_sre_test', 'SRE');
