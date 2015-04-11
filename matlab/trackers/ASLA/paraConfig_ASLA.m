function para=paraConfig_ASLA(title)

para.opt = struct('numsample', 600, 'affsig', [4,4,0.01,0.0,0.005,0]);
para.SC_param.mode = 2;
para.SC_param.lambda = 0.01;
% SC_param.lambda2 = 0.001; 
para.SC_param.pos = 'ture'; 

para.patch_size = 16;
para.step_size = 8;

para.psize = [32, 32];


% switch (title)    
%     case '';        
%         ;
% end




