% Set default parameter configuration for LOT
% 
% [param] = loadDefaultParams
%
% Input:
%
% Output:
%   param - Parameter struct
%           .inputDir                  - Location of video frames ( png/jpg format)
%           .outputDir                - Location for saving results
%           .initFrame                - Initial frame number
%           .finFrame                  - Final frame number (if -1 then all frames are processed)
%           .target0                     - Initial target position and size [x,y,w,h]
%           .recRes                       - Flag indicating whether (1) or not (0) to save the results
%           .aviPrefix                - Prefix for avi results file  
%           .DS                                 - Down sampling factor for input frames (for acceleration)
%           .minSP/maxSP            - Minimal and maximal number of Superpixels requested from 
%                                                    the Turbopixels algorithm 
%           .targetSP                  - Required number of superpixels in target region
%                                                     This determines the overall number of superpixles requested
%           .dxySP                          - Number of pixels in which we increase the region where 
%                                                     superpixels are generated           
%           .xyStd                         - Particle Filter state position noise STD
%           .whStd                         - Particle Filter state scale noise STD
%           .numOfParticles  - Number of particles to use
%           .beta                           - Particle weighting coefient ( w(p) = exp{-beta*EMDscr(p)} )
%           .MAalpha                    - Moving average "forgetness factor for parameter update
%           .emdDist                    - Type of ground distance for EMD 
%                                                  ('L2','L1','GaussGauss','GaussUniform')
%           .updateParams       - Flag indicating parameter update is enabled
%           .prior{X},prior{X}W - Priors and prior weights for appearance/location params
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [param] = loadDefaultParams

% I/O params


% param.inputDir = fullfile(pwd,'example');
param.inputDir = 'D:\data_seq\lemming';

param.outputDir = fullfile(pwd,'example','output');
param.initFrame = 1;
param.finFrame = -1;
param.target0 = [];

param.DS = 1;
param.recRes = 0;
param.aviPrefix  = 'exampleOut_';

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