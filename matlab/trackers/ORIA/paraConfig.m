function [para, paraSeq]=paraConfig(title)

% parametric tranformation model
para.transformType = 'SIMILARITY';
% one of 'TRANSLATION', 'SIMILARITY', 'AFFINE','HOMOGRAPHY'

para.numScales = 2; % if numScales > 1, we use multiscales

% main loop
para.stoppingDelta = 0.1;%.01; % stopping condition of main loop
para.maxIter = 25; % maximum iteration number of main loops

% inner loop
para.inner_tol = 1e-5;
para.inner_maxIter = 100 ;
para.continuationFlag = 1 ;
para.mu = 1e-3 ;
para.lambdac = 1 ; % lambda = lambdac/sqrt(m)

para.lambda = para.lambdac/100;

%% define parameters

% dispaly flag
para.bSaveImage = 0;

% save flag
para.saveStart = 1;
para.saveEnd = 1;
para.saveIntermedia = 0;

%%
para.numBasis=10;

para.canonicalImageSize = [ 35 35  ];
para.canonicalPts = [ 1  35 ; ...
                      1  1  ];
para.preprocessType = 'norm';%'gauss','contrast','norm'
                          
paraSeq = [];

switch (title)    
    case 'rubic3';        
        paraSeq.filepath =  '.\data\rubik3\';%folder storing the images
        
        paraSeq.numZ	= 1;	%number of digits for the frame index
        paraSeq.ext	= 'jpg'; %image format
        paraSeq.beginFrame	= 66; %start frame number
        paraSeq.endFrame = 100;%2061; % end frame number
        paraSeq.objRect = [292;162;70;70];
        
        paraSeq.destDir = 'results/rubik3/';        
        
        para.canonicalImageSize = [ 35 35  ];
        para.canonicalPts = [ 1  35 ; ...
                              1  1  ];
        
        para.preprocessType = 'norm';%'gauss','contrast','norm'
        
        % parametric tranformation model
        para.transformType = 'AFFINE';
        % one of 'TRANSLATION', 'SIMILARITY', 'AFFINE','HOMOGRAPHY'
        
        para.numScales = 2; % if numScales > 1, we use multiscales
        
        % main loop
        para.stoppingDelta = 0.01;%.01; % stopping condition of main loop
        para.maxIter = 25; % maximum iteration number of main loops
        
        % inner loop
        para.inner_tol = 1e-6;
        para.inner_maxIter = 1000 ;
        para.continuationFlag = 1 ;
        para.mu = 1e-3;
        para.lambdac = 1; % lambda = lambdac/sqrt(m)
        para.lambda = para.lambdac/1000;             
end