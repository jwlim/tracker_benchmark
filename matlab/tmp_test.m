% tmp = {};
for i = 1:numel(seqs)
  disp(['../results/TSRE7/' seqs(i).name '_FOT.mat'])
  r = load(['../results/TSRE7/' seqs(i).name '_FOT.mat']);
  r1 = load(['../results/TRE/' seqs(i).name '_FOT.mat']);
  for k = 1:numel(r.results)
    r.results{k}{13} = r1.results{k};
  end
  results = r.results;
%   tmp{i} = results.results;
  save(['../results/TSRE7/' seqs(i).name '_FOT.mat'], 'results');
end
% tsre_res_30 = ComputeTSRERates(tsre_results);
