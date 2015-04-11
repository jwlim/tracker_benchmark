%
%- Yi's results

disp('loading OPE/SRE/TRE results...');
load ../results/overall/aveSuccessRatePlot_31alg_overlap_OPE.mat
overlap_ope = aveSuccessRatePlot;
load ../results/overall/aveSuccessRatePlot_31alg_error_OPE.mat
error_ope = aveSuccessRatePlot;

load ../results/overall/aveSuccessRatePlot_31alg_overlap_SRE.mat
overlap_sre = aveSuccessRatePlot;
load ../results/overall/aveSuccessRatePlot_31alg_error_SRE.mat
error_sre = aveSuccessRatePlot;

load ../results/overall/aveSuccessRatePlot_31alg_overlap_TRE.mat
overlap_tre = aveSuccessRatePlot;
load ../results/overall/aveSuccessRatePlot_31alg_error_TRE.mat
error_tre = aveSuccessRatePlot;

trackers = nameTrkAll;
clear aveSuccessRatePlot nameTrkAll;

%%
% SRE and TRE results
disp('loading SRE100/TRE100 results...');
recompute_success_rates = false;
addpath util;
sre100_results = LoadTrackingResults('SRE', 'V11_100', tracker_names);
success_sre100 = ComputeSuccessRates(sre100_results);
save 140120_sre100.mat sre100_results success_sre100
% load 140120_sre100.mat

tre100_results = LoadTrackingResults('TRE', 'V11_100', tracker_names);
success_tre100 = ComputeSuccessRates(tre100_results);
save 140120_tre100.mat tre100_results success_tre100
% load 140120_tre100.mat

ope100_results = ConvertTRE2OPE(tre100_results);
success_ope100 = ComputeSuccessRates(ope100_results);
save 140120_ope100.mat ope100_results success_ope100
% load 140120_ope100.mat

%
disp('loading SRE50/TRE50 results...');

sre50_results = LoadTrackingResults('SRE', 'V11_50', tracker_names);
success_sre50 = ComputeSuccessRates(sre50_results);
save 140120_sre50.mat sre50_results success_sre50
% load 140120_sre50.mat

tre50_results = LoadTrackingResults('TRE', 'V11_50', tracker_names);
success_tre50 = ComputeSuccessRates(tre50_results);
save 140120_tre50.mat tre50_results success_tre50
% load 140120_tre50.mat

ope50_results = ConvertTRE2OPE(tre50_results);
success_ope50 = ComputeSuccessRates(ope50_results);
save 140120_ope50.mat ope50_results success_ope50
% load 140120_ope50.mat


%%
% To generate the TSRE results, see the comments in ComputeTSRERates.m .
disp('loading TSRE results...');
% load 131126_tsre.mat
load 140108_tsre_res.mat

disp('done');

%%
lw = 1.5;
plot_style ={ ...
  struct('Color',[1,0,0],'LineStyle','-','LineWidth',lw),...
  struct('Color',[0,1,0],'LineStyle','--','LineWidth',lw),...
  struct('Color',[0,0,1],'LineStyle','-','LineWidth',lw),...
  struct('Color',[0,0,0],'LineStyle','--','LineWidth',lw),...%    struct('Color',[1,1,0],'LineStyle','-'),...%yellow
  struct('Color',[1,0,1],'LineStyle','-','LineWidth',lw),...%pink
  struct('Color',[0,1,1],'LineStyle','--','LineWidth',lw),...
  struct('Color',[0.5,0.5,0.5],'LineStyle','-','LineWidth',lw),...%gray-25%
  struct('Color',[136,0,21]/255,'LineStyle','--','LineWidth',lw),...%dark red
  struct('Color',[255,127,39]/255,'LineStyle','-','LineWidth',lw),...%orange
  struct('Color',[0,162,232]/255,'LineStyle','--','LineWidth',lw),...%Turquoise
  struct('Color',[0.8,0.8,0.8],'LineStyle','--','LineWidth',lw),...%gray-25%
  };

%%
mean_overlaps = cat(2, mean(overlap_ope, 2), mean(overlap_sre, 2), mean(overlap_tre, 2));

mean_errors = cat(2, mean(error_ope, 2), mean(error_sre, 2), mean(error_tre, 2));

mo = mean_overlaps(:, :, round(end/2));
me = mean_errors(:, :, round(end/2));

%%

%- Yi's data
% data = squeeze(mean(overlap_ope, 2))';
% data = squeeze(mean(overlap_sre, 2))';
% data = squeeze(mean(overlap_tre, 2))';
% data = squeeze(mean(error_ope, 2))';
% data = squeeze(mean(error_sre, 2))';
% data = squeeze(mean(error_tre, 2))';
% names = trackers;

%- SRE results
% data = squeeze(mean(success_sre50, 2))';  title_str = 'SRE50';
% % data = squeeze(mean(success_tre50, 2))';  title_str = 'TRE50';
% % data = squeeze(mean(success_ope50, 2))';  title_str = 'OPE50';
% % data = squeeze(mean(success_sre100, 2))';  title_str = 'SRE100';
% % data = squeeze(mean(success_tre100, 2))';  title_str = 'TRE100';
% % data = squeeze(mean(success_ope100, 2))';  title_str = 'OPE100';
names = tracker_names;
attr = '';

sre_data = success_sre50; title_str = 'SRE50'; ss = 'V11_50';
% sre_data = success_tre50; title_str = 'TRE50'; ss = 'V11_50';
% sre_data = success_ope50; title_str = 'OPE50'; ss = 'V11_50';
% sre_data = success_sre100; title_str = 'SRE100'; ss = 'V11_100';
% sre_data = success_tre100; title_str = 'TRE100'; ss = 'V11_100';
% sre_data = success_ope100; title_str = 'OPE100'; ss = 'V11_100';

weighted_average = true;
% weighted_average = false;

if weighted_average
  stat_var_cmd = [title_str 'wt = sre_stat;'];
  title_str = [title_str ' (weighted average)'];
else
  stat_var_cmd = [title_str 'sq = sre_stat;'];
  title_str = [title_str ' (sequence average)'];
end

global SEQUENCE_ANNOTATIONS;
seqs = LoadSequenceConfig(ss);
seq_len = zeros(1, numel(seqs));
for i = 1:numel(seqs);
  seq_len(i) = numel(eval(seqs(i).img_range_str));
end

[num_trackers, num_seq, num_thr] = size(sre_data);
num_attributes = 0; %- Draw the overall only.
% num_attributes = numel(SEQUENCE_ANNOTATIONS.attributes);
sre_stat = zeros(num_trackers, num_attributes);
for attr_idx = 0:num_attributes
if attr_idx < 1
  seq_idx = 1:num_seq;
  attr = '';
else
  attr = SEQUENCE_ANNOTATIONS.attributes{attr_idx};
  [~,seq_idx] = intersect(SEQUENCE_ANNOTATIONS.(ss), ...
    SEQUENCE_ANNOTATIONS.([ss '_' attr]));
end

if weighted_average
  wt = repmat(permute(seq_len(seq_idx), [3,2,1]), [num_trackers, 1, num_thr]);
  wt = wt ./ sum(seq_len(seq_idx));
  data = squeeze(sum(sre_data(:,seq_idx,:) .* wt, 2) * 100)';
else
  data = squeeze(mean(sre_data(:, seq_idx,:), 2))' * 100;
end

% figure;
clf;
axes('Position', [0.06, 0.1, 0.92, 0.83]);

agg_data = mean(data, 1);  % AUC
% agg_data = data(round(end/2));  % threshold = 0.5
[sorted, idx] = sort(agg_data, 'descend');

top_k = 10;
hold on;
top_names = cell(numel(idx), 1);
for i = 1:top_k
  plot(0:1/(num_thr-1):1, data(:,idx(i)), plot_style{i});
end
% axis_val = axis();
% line([0.5, 0.5], [0, axis_val(4)], 'Color', 'k', 'LineStyle', ':');  % thr=0.5
for i = numel(idx):-1:1
  j = i;
  if j > top_k, j = 11; end;
  plot(0:1/(num_thr-1):1, data(:,idx(i)), plot_style{j});
  top_names{i} = sprintf(' %s  [%.02f]', names{idx(i)}, sorted(i));
end
hold off;
if isempty(attr)
  title(title_str);
else
  title([title_str ' - ' attr ' (' num2str(numel(seq_idx)) ')']);
end

legend(top_names(1:top_k), 'Interpreter', 'none');
xlabel('thresholds');
grid on
axis([0, 1, 0, 90])

sre_stat(:, attr_idx+1) = agg_data;
if num_attributes, pause; end;

end

eval(stat_var_cmd);

if num_attributes > 0
col_idx = zeros(num_trackers, num_attributes+1);
for i = 0:num_attributes
  [~, col_idx(:,i+1)] = sort(sre_stat(:,i+1,1), 'descend');
end
colors = {'red', 'green', 'blue', 'cyan', 'magenta'};

[~, idx] = sort(sre_stat(:,1,1), 'descend');

fprintf('%s\n', title_str);
for i = 1:num_trackers
  fprintf('%s', tracker_names{idx(i)});
  for j = 0:num_attributes
    ci = find(col_idx(:,j+1) == idx(i));
    if ci <= numel(colors)
      fprintf(' & \\bf\\color{%s} %.01f', colors{ci}, sre_stat(idx(i),j+1));
    else
      fprintf(' & %.01f', sre_stat(idx(i),j+1));
    end
  end;
  fprintf(' \\\\\n');
end
fprintf('\n');
end

%%
tidx = find(strcmp(ope100_results.trackers, 'STRUCK'));
tmp = squeeze(mean(success_ope100(tidx,:,:), 3));
for i=1:numel(tmp)
  fprintf('%s\t%d\t%.04f\n', seqs(i).name, seq_len(i), tmp(i));
end;
disp(sum(tmp.*seq_len)/sum(seq_len))

%% SRE results

% sre50_results = LoadTrackingResults('SRE', 'V11_50', tracker_names);
% success_rates = ComputeSuccessRates(sre50_results);

sre_data = squeeze(mean(success_rates, 2))';
n = size(sre_data, 1);
[~,idx] = sort(sre_data(round(n/2),:), 'descend');  % threshold=0.5

plot(0:(1/(n-1)):1, sre_data(:,idx), '.-');
legend(tracker_names(idx), 'Location', 'NorthEastOutside');


%% Generate TSRE results

ScanSequences
global SEQUENCE_ANNOTATIONS
seqs = LoadSequenceConfig('V11_50');
seq_len = zeros(1, numel(seqs));
for i = 1:numel(seqs);
  seq_len(i) = numel(eval(seqs(i).img_range_str));
end

tracker_names = { 'ASLA', 'BSBT', 'CPF', 'CSK', 'CT', 'CXT', 'DFT', 'FRAG', 'IVT', 'KMS', 'L1APG', 'LOT', 'LSHT', 'LSK', 'LSS', 'MIL', 'MS', 'MTT', 'OAB', 'ORIA', 'PD', 'RS', 'SBT', 'SCM', 'SMS', 'STRUCK', 'TLD', 'TM', 'VR', 'VTD', 'VTS' };
% tracker_names = { 'ASLA', 'CSK', 'CXT', 'SCM', 'STRUCK', 'TLD', 'VTD' };
tsre_results = LoadTrackingResults('TSRE7', 'V11_50', tracker_names);
tsre_res_15 = ComputeTSRERates(tsre_results, 'window_size', 15);

%%
tsre_res_30 = ComputeTSRERates(tsre_results);

tsre_res_60 = ComputeTSRERates(tsre_results, 'window_size', 60);
tsre_res_90 = ComputeTSRERates(tsre_results, 'window_size', 90);
tsre_res_120 = ComputeTSRERates(tsre_results, 'window_size', 120);
tsre_res_150 = ComputeTSRERates(tsre_results, 'window_size', 150);

% save 140111_tsre_res.mat tsre_res tsre_res_60 tsre_res_90 tsre_res_120 tsre_res_150 tsre_res_180 tsre_res_210 tracker_names SEQUENCE_ANNOTATIONS tsre_results

%% Plot TSRE results

%- Simple mean of overlaps.
% tsre_data = squeeze(tsre_res(:,:,1,:));
% tsre_data = squeeze(mean(tsre_res(:,:,2,:), 3));
% tsre_data = squeeze(mean(tsre_res, 3));

%- Weighted mean
% tsre_data = tsre_res_15;  title_str = 'SRER 50 (win=15, weighted average)';
% tsre_data = tsre_res;  title_str = 'SRER 50 (win=30, weighted average)';
% tsre_data = tsre_res_60;  title_str = 'SRER 90 (win=60, weighted average)';
% tsre_data = tsre_res_90;  title_str = 'SRER 50 (win=90, weighted average)';
tsre_data = tsre_res_120;  title_str = 'SRER 50 (win=120, weighted average)';
% tsre_data = tsre_res_150;  title_str = 'SRER 50 (win=150, weighted average)';

global SEQUENCE_ANNOTATIONS;
seqs = LoadSequenceConfig('V11_50');
seq_len = zeros(1, numel(seqs));
for i = 1:numel(seqs);
  seq_len(i) = numel(eval(seqs(i).img_range_str));
end

num_attributes = numel(SEQUENCE_ANNOTATIONS.attributes);
[num_thr, num_trackers, ~] = size(tsre_data);
thr_idx = 6;  % threshold=0.5
tsre_stat = zeros(num_trackers, num_attributes, 2);
for attr_idx = 0:num_attributes
if attr_idx < 1
  seq_idx = 1:size(tsre_data, 3);
  attr = '';
else
  attr = SEQUENCE_ANNOTATIONS.attributes{attr_idx};
  [~,seq_idx] = intersect(SEQUENCE_ANNOTATIONS.V11_50, ...
    SEQUENCE_ANNOTATIONS.(['V11_50_' attr]));
end

data = zeros(num_thr, num_trackers, 2);
wt = repmat(permute(seq_len(seq_idx), [3,1,2]), [num_thr, num_trackers]);
wt = wt ./ sum(seq_len(seq_idx));
data(:,:,1) = sum(tsre_data(:,:,seq_idx,1) .* wt, 3) * 100;
% data(:,:,2) = mean(tsre_data(:,:,seq_idx,2), 3);
data(:,:,2) = sum(tsre_data(:,:,seq_idx,2), 3) / sum(seq_len(seq_idx)) * 1000;

[sorted, idx] = sort(data(thr_idx,:,1), 'descend');  % threshold=0.5

% figure;
clf
% axes('Position', [0.05, 0.07, 0.94, 0.89]);
axes('Position', [0.06, 0.1, 0.92, 0.83]);
%--------------------------------------------------------------------------
%- In 'Print Preview', set Paper width and height to be 560 x 420 'points'.
%- 'Lines/Text' tab, set both line width and font weight to be 150%.
%- Then 'export' in 'exprt setup'.
%--------------------------------------------------------------------------

% plot(tsre_data(:,idx,2), tsre_data(:,idx,1), '.-', ...
%   tsre_data(6,idx,2),tsre_data(6,idx,1), 'ko', 'MarkerSize', 10);
% legend(tracker_names(idx),'Location','NorthEastOutside');
% axis([0, ceil(max(max(tsre_data(:,:,2)))*10+0.5)/10, ...
%   0, ceil(10*max(max(tsre_data(:,:,1)))+0.5)/10])

top_k = 10;
hold on;
top_names = cell(numel(idx), 1);
for i = 1:top_k
  plot(data(:,idx(i),2), data(:,idx(i),1), '.-', ...
    'Color', plot_style{i}.Color);
%     'LineStyle', plot_style{i}.LineStyle, 'LineWidth', 1);
end

% axis_val = axis();
% line([0.5, 0.5], [0, axis_val(4)], 'Color', 'k', 'LineStyle', ':');  % thr=0.5
for i = numel(idx):-1:top_k
  plot(data(:,idx(i),2), data(:,idx(i),1), ...
    'Color', plot_style{end}.Color, 'LineStyle', plot_style{end}.LineStyle);
end
for i = top_k:-1:1
  plot(data(:,idx(i),2), data(:,idx(i),1), '.-', ...
    'Color', plot_style{i}.Color);
%     'LineStyle', plot_style{end}.LineStyle, 'LineWidth', 2);
  top_names{i} = sprintf(' %s  [%.02f]', tracker_names{idx(i)}, sorted(i));
end
plot(data(thr_idx,idx(1:top_k),2),data(6,idx(1:top_k),1), 'ko', 'MarkerSize', 10);

hold off;
legend(top_names(1:top_k), 'Interpreter', 'none', 'Location', 'SouthEast');
if isempty(attr)
  title(title_str);
else
  title([title_str ' - ' attr ' (' num2str(numel(seq_idx)) ')']);
end

x_max = ceil(max(max(data(:,:,2)))*100+0.5)/100;
% y_max = ceil(max(max(data(:,:,1)))*10+0.5)/10;
axis([0, x_max, 20, 65])
xlabel('# failures / 1000 frames');
grid on

tsre_stat(:, attr_idx+1, :) = data(thr_idx,:,:);
pause;
end

%%

col_idx = zeros(num_trackers, num_attributes+1);
for i = 0:num_attributes
  [~, col_idx(:,i+1)] = sort(tsre_stat(:,i+1,1), 'descend');
end
colors = {'red', 'green', 'blue', 'cyan', 'magenta'};

[sorted, idx] = sort(tsre_stat(:,1,1), 'descend');

fprintf('\n');
for i = 1:num_trackers
  fprintf('%s', tracker_names{idx(i)});
  for j = 0:num_attributes
    ci = find(col_idx(:,j+1) == idx(i));
    if ci <= numel(colors)
      fprintf(' & \\bf\\color{%s} %.01f / %.01f', colors{ci}, tsre_stat(idx(i),j+1,1), tsre_stat(idx(i),j+1,2));
    else
      fprintf(' & %.01f / %.01f', tsre_stat(idx(i),j+1,1), tsre_stat(idx(i),j+1,2));
    end
  end;
  fprintf(' \\\\\n');
end
fprintf('\n');

