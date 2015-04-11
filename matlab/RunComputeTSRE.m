% run_tsre


% load tsre_results.mat
ScanSequences
global SEQUENCE_ANNOTATIONS
tracker_names = { 'ASLA', 'BSBT', 'CPF', 'CT', 'CXT', 'DFT', 'FRAG', 'IVT', 'KMS', 'L1APG', 'LOT', 'LSHT', 'LSK', 'LSS', 'MIL', 'MS', 'MTT', 'OAB', 'ORIA', 'PD', 'RS', 'SBT', 'SCM', 'SMS', 'STRUCK', 'TLD', 'TM', 'VR', 'VTD', 'VTS' };
% results = LoadTrackingResults('TSRE7', 'V11_50', tracker_names);
results = LoadTrackingResults('TSRE7', 'David', tracker_names);
% [tsre_res, tsre, thresholds, results] = ComputeTSRERates(results);
[tsre_res, tsre] = ComputeTSRERates(results);
save tsre_results.mat

seq_idx = cell(12, 1);
titles = cell(12, 1);
titles{1} = 'ALL';   seq_idx{1} = 1:50;
titles{2} = 'BC';    seq_idx{2} = SEQUENCE_ANNOTATIONS.V11_50_BCidx;
titles{3} = 'DEF';   seq_idx{3} = SEQUENCE_ANNOTATIONS.V11_50_DEFidx;
titles{4} = 'FM';    seq_idx{4} = SEQUENCE_ANNOTATIONS.V11_50_FMidx;
titles{5} = 'IPR';   seq_idx{5} = SEQUENCE_ANNOTATIONS.V11_50_IPRidx;
titles{6} = 'IV';    seq_idx{6} = SEQUENCE_ANNOTATIONS.V11_50_IVidx;
titles{7} = 'LR';    seq_idx{7} = SEQUENCE_ANNOTATIONS.V11_50_LRidx;
titles{8} = 'MB';    seq_idx{8} = SEQUENCE_ANNOTATIONS.V11_50_MBidx;
titles{9} = 'OCC';   seq_idx{9} = SEQUENCE_ANNOTATIONS.V11_50_OCCidx;
titles{10} = 'OPR';  seq_idx{10} = SEQUENCE_ANNOTATIONS.V11_50_OPRidx;
titles{11} = 'OV';   seq_idx{11} = SEQUENCE_ANNOTATIONS.V11_50_OVidx;
titles{12} = 'SV';   seq_idx{12} = SEQUENCE_ANNOTATIONS.V11_50_SVidx;

for i = 1:numel(seq_idx)
  tsre_res_avg = squeeze(mean(tsre_res(:,:,seq_idx{i},:), 3));
  
  [~,idx] = sort(-tsre_res_avg(6,:,1)'); idx = idx(1:end);
  max_fail_count = ceil(max(max(tsre_res_avg(:,idx,2))));
  figure(i)
  plot(tsre_res_avg(:,idx,2), tsre_res_avg(:,idx,1), '.-', tsre_res_avg(6,idx,2),tsre_res_avg(6,idx,1), 'ko', 'MarkerSize', 10);
  legend(tracker_names(idx),'Location','NorthEastOutside');
  axis([0, max_fail_count, 0, 0.5])
  title(titles{i});
end
