% Copyright 2011 Zdenek Kalal
%
% This file is part of TLD.
% 
% TLD is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.

function results = run_TLD(seq, res_path, bSaveImage)

close all
clear tld;
clear global;
warning off all;
rand('state',0);
randn('state',0);

para=paraConfig_TLD(seq.name);

if min(seq.init_rect(3), seq.init_rect(4))<para.model.min_win
    para.model.min_win = min(seq.init_rect(3), seq.init_rect(4));
end

% opt.source          = struct('camera',0,'input','F:\data\VIVID\rgb\','bb0',[]); 
para.output = res_path; 
para.s_frames = seq.s_frames;   
para.init_rect = seq.init_rect;
para.bSaveImage = bSaveImage;
% Run TLD -----------------------------------------------------------------
%profile on;
[bb,conf,fps] = tldExample(para);
%profile off;
%profile viewer;

% Save results ------------------------------------------------------------
% dlmwrite([opt.output '/tld.txt'],[bb; conf]');
% disp('Results saved to ./_output.');

results.type='rect';
res = bb';%each row is a rectangle

res(:,3) = res(:,3) - res(:,1) + 1;
res(:,4) = res(:,4) - res(:,2) + 1;

results.res = round(res);
results.res(1,:)=seq.init_rect;
results.fps = fps;

% save([res_path seq.name '_TLD' '.mat'], 'results');