function para=paraConfig_ivt(title)

para.opt = struct('numsample',600, 'condenssig',0.75, 'ff',.95, ...
                    'batchsize',5,'affsig', [4,4,0.01,0.0,0.005,0]);
% 'affsig',[5,5,.01,.02,.02,.01]

% switch (title)    
%     case '';        
%         ;
% end




