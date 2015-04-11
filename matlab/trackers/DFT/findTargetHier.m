% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function pts = findTargetHier(target_models, f2, init_pos, wsize, sp_width, sp_sig, feat_width, feat_sig, nbins)

% it returns multiple pts for analysis purpose

% from coarse to fine kernel
cur_pt = init_pos;
pts = cur_pt;
df2 = img2df(double(f2), nbins);

for i=length(sp_width):-1:1
    % explode and convolve 
    df2_s = smoothDF(df2, [sp_width(i), feat_width], [sp_sig(i), feat_sig]);
    % find target
    cur_pt = findTarget(target_models{i}, df2_s, cur_pt, wsize); 
    pts = [pts; cur_pt];
end;



