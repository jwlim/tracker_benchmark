function results=run_L1APG(seq, res_path, bSaveImage)

close all 

s_frames = seq.s_frames;

para=paraConfig_L1_APG(seq.name);

nframes		= seq.endFrame-seq.startFrame+1;	% number of frames to be tracked
init_rect=seq.init_rect;
init_pos= [init_rect(2),init_rect(2)+init_rect(4)-1,init_rect(2);
           init_rect(1),init_rect(1),init_rect(1)+init_rect(3)-1];

para.s_debug_path = res_path;
para.init_pos = init_pos;

% bShowSaveImage=0;       %indicator for result image show and save after tracking finished
para.bDebug=bSaveImage;
%% main function for tracking
[tracking_res,output]  = L1TrackingBPR_APGup(s_frames, para);

fps = (nframes-1)/sum(output.time);

disp(['fps: ' num2str(fps)])
%% Output tracking results

results.type = 'L1Aff';
results.res=tracking_res';
results.tmplsize=para.sz_T;%[height, width]
results.fps=fps;

% save([res_path seq.name '_L1_APG.mat'], 'results');

% save([res_path title '_L1_APG_' num2str(times) '.mat'], 'tracking_res','sz_T','output');
