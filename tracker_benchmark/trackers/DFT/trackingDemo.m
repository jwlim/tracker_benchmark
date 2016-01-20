
% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************


% default input parameters 
params.file_path = './data/img';
params.file_format = 'png';
params.output_name = 'track_cokecan';
params.start_fr = 1;
params.end_fr = 100; 
params.init_pos = [80, 149];
params.wsize = [40, 24];

params.nbins = 16; 
params.feat_width = 5; 
params.feat_sig = 0.625; 
params.sp_width = [9, 15];
params.sp_sig = [1, 2];
params.max_shift = 30;

% track target along sequence 
positions = trackDF(params); 

% render video of the track (and show the images if you choose to)
show_track = 1; 
track2video(positions, params.output_name, params.file_path, params.file_format, params.start_fr, params.wsize, show_track);



