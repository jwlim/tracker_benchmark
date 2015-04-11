% setTrackParam 
%% *************************************************************
title = 'woman_sequence'; 
% title = 'faceocc2';
% title = 'ThreePastShop2cor';

% title = 'singer1';
% title = 'car4';
% title = 'car11'; 
% title = 'davidin300'; 

% title = 'board';
% title = 'stone';
%% *************************************************************
% image sequence foler
dataset = '';
dataPath = [dataset title '\'];

dataInfo = importdata([dataPath 'datainfo.txt']);
imgSize = [dataInfo(1) dataInfo(2)];% [width height]
frameNum = dataInfo(3);


%% *************************************************************
% 
switch (title)           %affsig = [center_x center_y width rotation aspect_ratio skew]     
        
    case 'woman_sequence'; p = [222 165 35 95 0.0]; % 
        EXEMPLAR_NUM = 10;
        opt = struct('numsample', 600, 'affsig', [4,4,0.01,0.0,0.005,0]); %                    
    
    case 'faceocc2';  p = [156,107,74,100,0.00]; % 
        EXEMPLAR_NUM = 10;
        opt = struct('numsample',600, 'affsig',[4, 4,.02,.02,.001,.000]);                     
    
     case 'singer1';  p = [100, 200, 100, 300, 0]; 
     EXEMPLAR_NUM = 10;
     opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
                  'batchsize',10, 'affsig',[4,4,.05,.000,.0005,.000]);
 
    case 'davidin300';  p = [160 112 60 92 -0.02]; 
    EXEMPLAR_NUM = 10;
    opt = struct('numsample',600, 'condenssig',0.75, 'ff',0.99, ...
                     'batchsize',5, 'affsig',[5,5,.01,.000,.002,.001]);                  
              
    case 'car4';  p = [245 180 200 150 0]; 
    EXEMPLAR_NUM = 10;
    opt = struct('numsample',600,'affsig',[5,5,.025,.00,.002,.001]);                          
             
    case 'car11';  p = [89 140 30 25 0]; 
    EXEMPLAR_NUM = 10;
    opt = struct('numsample',600, 'affsig',[5,5,.01,.0000,.001,.0000]);                    
        
    case 'ThreePastShop2cor'; p = [162 216 50 140 0.0]; 
    EXEMPLAR_NUM = 10;
    opt = struct('numsample',600, 'affsig',[5,5,.01,.00,.001,.0000]);                                            
         
    case 'board';   p = [154,243,195,153,0];
    EXEMPLAR_NUM = 10;
    opt = struct('numsample',600, 'affsig',[10, 10, .03, .00, .03, .00]);                      
         
    case 'stone'; p = [115 150 43 20 0.0];
    EXEMPLAR_NUM = 10;
    opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
        'batchsize',5, 'affsig',[6,6,.01,.00,.000,.0000]);
    
    otherwise;  
        error(['unknown title ' title]);
end

psize = [32, 32];
param0 = [p(1), p(2), p(3)/psize(1), p(5), p(4)/p(3), 0]'; %param0 = [px, py, sc, th,ratio,phi];   
param0 = affparam2mat(param0); 

if ~isdir(['result\' ,title])
    mkdir('result\',title);
end
if ~isdir(['result\' ,title,'\Dict'])
    mkdir(['result\' ,title,'\Dict']);
end
if ~isdir(['result\' ,title,'\Result'])
    mkdir(['result\' ,title,'\Result']);
end
