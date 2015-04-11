function opt=paraConfig_MTT(title)

sz_T = [32 32];

%% MTT tracking Parameters
opt.n_sample = 600;		% number of particles   400
opt.sz_T= sz_T;         % object size
opt.tracker_type = 'L21';  opt.lambda = 0.01; % three different trackers: L21, L11, L01(denote L\infinity 1);
% opt.tracker_type = 'L11';  opt.lambda = 0.005;
% opt.tracker_type = 'L01';  opt.lambda = 0.2;
opt.eta  = 0.01;
opt.obj_fun_th = 1e-3;
opt.iter_maxi = 100; % lambda, eta,obj_fun_th, and iter_maxi are parameters for Accelerated Proximal Gradient (APG) Optimization. Please refer to our paper for details.
opt.rel_std_afnv =  [0.005,0.0005,0.0005,0.005,4,4]; % affine parameters for particle sampling
 %[0.01,0.0005,0.0005,0.01,1,1];%L1_APG
opt.m_theta = 0.6;  % [0 1] decide object template update
opt.show_optimization = false; % show optimization results to help tue eta and lambda for APG optimization.
opt.show_time = true; % show optimization speed




