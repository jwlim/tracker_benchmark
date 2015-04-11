% Locally Orderless Tracking main function
%
% Based on (this is the original implementation):
% [1] Locally Orderless Tracking. 
%     Shaul Oron, Aharon Bar-Hillel, Dan Levi and Shai Avidan
%	  Computer Vision and Pattern Recognition 2012
%
% The code provided here also uses and incluedes a re-distribution of the following code:
% - EMD mex downloaded from: http://www.mathworks.com/matlabcentral/fileexchange/12936-emd-earth-movers-distance-mex-interface
% Which is based on:
% [2] A Metric for Distributions with Applications to Image Databases. 
%     Y. Rubner, C. Tomasi, and L. J. Guibas.  ICCV 1998
% See also: http://ai.stanford.edu/~rubner/emd/default.htm
% - Turbopixels downloaded from: http://www.cs.toronto.edu/~babalex/research.html
% which is based on is based on:
% [3] TurboPixels: Fast Superpixels Using Geometric Flows. 
%     Alex Levinshtein, Adrian Stere, Kiriakos N. Kutulakos, David J. Fleet, Sven J. Dickinson, and Kaleem Siddiqi. TPAMI 2009
%
%
% [] = LocallyOrderlessTracking(param)
%
% Input:
%             param - Either a parameter file name of parameter structure
%                     if empty or not provided default parameters are
%                     loaded see 'loadDefaultParams.m' for more info.
%
% Getting started:
%       To get started you can simply run this function (i.e. LocallyOrderlessTracking)
%       A figure showing the first frame of the provided example sequence will open 
%       Mark the target with a rectangle and double-click to start tracking
%       Tracking results will be displayed in a new figure window
%       (*)  We suggest initially to use our parameter configuration
%       (**) If you have matlab parallel toolbox run matlabpool before starting for better performance
%
% This code is distributed under the GNU-GPL license.
%
% When using this code for academic purposes please cite [1]
%
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [] = LocallyOrderlessTracking(param)

clc;
addpath(genpath(pwd));

% Check for param input or load default params
if nargin == 0 || isempty(param)
    param = loadDefaultParams;
elseif ischar(param)
    load(param);
elseif ~isstruct(param)
    error('Param input is invalid should be file name or parameter structure');
end

% Get frame list
files = getFrameList(param);

% Load first frame
[I] = loadFrame(fullfile(param.inputDir,files(param.initFrame).name),param.DS);
Ihsv = rgb2hsv(I);

% Get image support
[maxY,maxX,dummy] = size(I);

% Check if traget position is defined o/w get from user
% [target,T0] = setInitialTargetPosition(I,param);
target=[54,29,35,37];

% Initialize particles
w = ones(param.numOfParticles,1)/param.numOfParticles;
[particles,w] = predictParticles(ones(param.numOfParticles,1)*target,w,param,maxX,maxY);
ROI = getParticleROI(particles,[maxX maxY],param.dxySP);

% Calculate number of super pixels
param.nSP = round(prod(ROI(3:4))/prod(target(3:4))*param.targetSP);
param.nSP = max(min(param.nSP,param.maxSP),param.minSP);

% Perform oversegmentation i.e. superpixelization
idxImg = buildSuperPixelsIndexImage(I,param.nSP,ROI);

% Build template signature
[S0,W0,VL] = getSignatureFromSuperPixelImage(Ihsv,idxImg,target);


% Initialize required distance parameters
switch lower(param.emdDist)
    case 'gaussgauss'
        distParams.sigA = sqrt(param.priorVarA);
        distParams.sigL = sqrt(param.priorVarL);
    case 'gaussuniform'
        distParams.sigA = sqrt(param.priorVarA);
        distParams.RL = param.priorRL;
        distParams.alphaL = param.priorAlphaL;
        distParams.SL = VL;
    otherwise
        distParams = [];
end

% Allocate score array
scr = zeros(param.numOfParticles,1);

% Display results
displayTrackingReuslts(I,target,param.initFrame);

% Record results
if param.recRes
    aviName = strcat(param.outputDir,'\',param.aviPrefix,datestr(clock,30),'.avi');
    mov = avifile(aviName,'fps',15,'compression','iyuv');
    mov  = addframe(mov,figure(10));
    targetRec(1,:) = target;    
    f = 2;    
end

if param.finFrame == -1
    param.finFrame = length(files);
end

% Main Loop (Tracking)
k = 1;
for frame = param.initFrame+1:param.finFrame
    fprintf('----------------------- Frame #%d ----------------------\n',frame);
    % Load new frame and partition to super pixels
    [I] = loadFrame(fullfile(param.inputDir,files(frame).name),param.DS);
    Ihsv = rgb2hsv(I);  
    idxImg = buildSuperPixelsIndexImage(I,param.nSP,ROI);
        
    % Sample each particle from new frame and calc match score using EMD
    parfor p = 1:size(particles,1)
        % Get particle signature
        [S,W] = getSignatureFromSuperPixelImage(Ihsv,idxImg,particles(p,:));
        % Build cost matrix for EMD
        [C] = buildCostMatrix(S0,S,param.emdDist,distParams);
        % Calculate match score using EMD
        try
            [scr(p),flow] = emd_mex(W0',W',C);
        catch
            fprintf('EMD error at particle %d\n',p);
            scr(p) = inf;
        end  
    end    
    
    % Update particle weights
    w = exp(-scr(1:size(particles,1))*param.beta);
    w = w./sum(w);
        
    % Update target state integrating over all particles
    target = updateTargetState(target,particles,w,param,maxX,maxY);
    
    % Get final target signature
    [S,W,VL] = getSignatureFromSuperPixelImage(Ihsv,idxImg,target);
    distParams.SL = VL;
    
    % Build cost matrix for EMD
    [C] = buildCostMatrix(S0,S,param.emdDist,distParams);
    
    % Calculate match score using EMD
    try
        [Tscr,flow] = emd_mex(W0',W',C);
        emdPass = 1;
    catch
        warndlg(sprintf('EMD for final target has failed\n at frame # %d\n',frame));        
        flow = [];
        emdPass = 0;        
    end    
    
    % Update distance parameters
    if param.updateParams && emdPass
        switch lower(param.emdDist)
            case 'gaussgauss'
                [distParams] = estimateGaussGaussParams(S0,S,flow,param,distParams);
            case 'gaussuniform'
                [distParams] = estimateGaussUniformParams(S0,S,flow,param,distParams);            
        end
    end 
    
    % Display results    
    displayTrackingReuslts(I,target,frame);
    
    % Update particles for next frame
    [particles,ROI] = updateParticles(particles,w,maxX,maxY,param);
        
    % Record results
    if param.recRes
        mov  = addframe(mov,figure(10));
        targetRec(f,:) = target;        
        f = f + 1;        
    end
    k = k+1;
end % Main Loop

% Finish recording
if param.recRes
    mov  = close(mov);    
    csvwrite([aviName(1:end-4) '.csv'],targetRec);
end
close all;