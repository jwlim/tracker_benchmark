function para=paraConfig_L1_APG(title)

para.rel_std_afnv = [0.003,0.0005,0.0005,0.003,1,1];%diviation of the sampling of particle filter

para.lambda = [0.2,0.001,10]; % lambda 1, lambda 2 for a_T and a_I respectively, lambda 3 for the L2 norm parameter
% set para.lambda = [a,a,0]; then this the old model
para.angle_threshold = 40;
para.Lip = 8;
para.Maxit = 5;
para.nT = 10;%number of templates for the sparse representation
para.bVerbose=0;

para.n_sample = 600;		%number of particles
para.sz_T =[12,15];      % size of template    

% switch (title)    
%     case '';        
%         ;
% end




para.lambda = [0.01,0.001,1]; % lambda 1, lambda 2 for a_T and a_I respectively, lambda 3 for the L2 norm parameter
% para.rel_std_afnv = [0.01,0.0005,0.0005,0.01,1,1];%original
para.rel_std_afnv =  [0.005,0.0005,0.0005,0.005,4,4]; % Same as MTT
para.angle_threshold = 30;
para.lip = 8;

para.sz_T =[32,32];      % size of template    