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
%       A figure showing the first f of the provided example sequence will open 
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

function results=run_LOT(seq, res_path, bSaveImage)

close all
rng('default')
param=paraConfig_LOT(seq.name);

% Get f list
s_frames = seq.s_frames;

% files = getFrameList(param);

% Load first f
[I] = loadFrame(s_frames{1},param.DS);
Ihsv = rgb2hsv(I);

% Get image support
[maxY,maxX,dummy] = size(I);

% Check if traget position is defined o/w get from user
% [target,T0] = setInitialTargetPosition(I,param);
target=seq.init_rect;

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

% Record results
if bSaveImage    
    % Display results
    displayTrackingReuslts(I,target,seq.startFrame);

%     aviName = strcat(res_path,seq.name,'_LOT.avi');
%     mov = avifile(aviName,'fps',15,'compression','iyuv');
%     mov  = addframe(mov,figure(10));
    imwrite(frame2im(getframe(gcf)),[res_path num2str(1) '.jpg']); 
end

targetRec(1,:) = target;  

duration = 0;
% Main Loop (Tracking)
for f = 2:seq.len
%     fprintf('#%d \r',f); 
    % Load new f and partition to super pixels
    [I] = loadFrame(s_frames{f},param.DS);
    
    tic
    
    Ihsv = rgb2hsv(I);  
    idxImg = buildSuperPixelsIndexImage(I,param.nSP,ROI);
        
    % Sample each particle from new f and calc match score using EMD
    for p = 1:size(particles,1)
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
    sum_w=sum(w);
    w = w./sum_w;
    if sum_w < eps
        disp('eps')
    end
%     i=0;
%     while max(w)<0.6% by yi wu, 10/5/2012
%         param.beta = param.beta/10;
%         w = exp(-scr(1:size(particles,1))*param.beta);
% %         i=i+1;
%         
% %         disp(num2str(i))
%     end
%     disp(num2str(max(w)))
%     w = w./(sum(w)+eps);% by yi wu
        
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
%         warndlg(sprintf('EMD for final target has failed\n at f # %d\n',f));    
        sprintf('EMD for final target has failed at # %d\n',f)
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
        
    % Update particles for next f
    [particles,ROI] = updateParticles(particles,w,maxX,maxY,param);
    
    duration = duration+toc;
    % Record results
    if bSaveImage
        % Display results    
        displayTrackingReuslts(I,target,seq.startFrame+f-1);
    
%         mov  = addframe(mov,figure(10));
        imwrite(frame2im(getframe(gcf)),[res_path num2str(f) '.jpg']); 
        
%         f = f + 1;        
    end
    targetRec(f,:) = target;    
    
    
end % Main Loop

% Finish recording
% if bSaveImage
% %     mov  = close(mov);    
% end

results.type='rect';
results.res=targetRec;%each row is a rectangle

results.fps=(seq.len-1)/duration;

% save([res_path seq.name '_LOT' '.mat'], 'results');

disp(['fps: ' num2str(results.fps)])
