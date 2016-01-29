function param=paraConfig_LOT(title)

%             param.inputDir = fullfile(pwd,'example');
%             param.outputDir = fullfile(pwd,'example','output');
%             param.initFrame = 1;
%             param.finFrame = -1;
%             param.target0 = [];

param.DS = 1; % ratio for downsampling
param.recRes = 1;
%             param.aviPrefix  = 'exampleOut_';

% Clustering params
param.minSP = 300;              % Minimal number of superpixels requested from Turbopixels
param.maxSP = 1000;            % Maximal number of superpixels requested from Turbopixels
param.targetSP = 20;         % Required  number of superpixels in target region
param.dxySP = 100;              % SP ROI enlargement in pixels 

% Particle Filter params
param.xyStd = 7;                             % Position noise STD  
param.whStd = 0.07;                        % Scale noise STD 
param.numOfParticles = 250;  % Number of particles to use 
param.beta = 10;                             % Particle weighting coeficient

% Ground Distance  & Parameter estimation params
param.emdDist = 'gaussgauss';  % can also be 'gaussuniform'
param.updateParams = 1;               % If 1 on-line parameter update enabled
param.MAalpha = 0.3;                         % Moving average parameter
% Gaussian
param.priorVarA = 0.05^2;              % Apperance variance prior
param.priorVarAW = 0.25;               % Apperance variance prior weight
param.priorVarL = 0.1^2;                % Localization variance prior
param.priorVarLW = 0.25;               % Localization variance prior weight
% Uniform Mix
param.priorAlphaL = 0.9;              % Localization uniform-mix mixture parameter prior
param.priorAlphaLW = 0.25;         % Localization uniform-mix mixture parameter prior weight
param.priorRL = 0.2;                       % Localization uniform-mix inner uniform region prior 
param.priorRLW = 0.25;                   % Localization uniform-mix inner uniform region prior weight 


switch (title)    
    case 'matrix';        
        param.beta = 0.1;                             % Particle weighting coeficient
end




