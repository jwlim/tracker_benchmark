% function trackparam
% loads data and initializes variables

%*************************************************************
% 'title';
% choose the sequence you wish to run.

% 'p = [px, py, sx, sy, theta]';
% the location of the target in the first frame.
%
% px and py are the coordinates of the center of the box;
%
% sx and sy are the size of the box in the x (width) and y (height)
% dimensions, before rotation;
%
% theta is the rotation angle of the box;
%
% 'numsample';
% the number of samples used in the condensation algorithm/particle filter.
% Increasing this will likely improve the results, but make the tracker slower.
%
% 'affsig';
% these are the standard deviations of the dynamics distribution, and it controls the scale, size and area to
% sample the candidates.
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = x & y scaling
%    affsig(4) = rotation angle
%    affsig(5) = aspect ratio
%    affsig(6) = skew angle
%
% 'forMat';
% the format of the input images in one video, for example '.jpg' '.bmp'.

%*************************************************************
%% Copyright (C) Wei Zhong.
%% All rights reserved.
%% Date: 05/2012

%*************************************************************
% title = 'animal';
% title = 'board';
% title = 'car11';
% title = 'caviar';
title = 'faceocc2';
% title = 'girl';
% title = 'jumping';
% title = 'panda';
% title = 'shaking';
% title = 'singer1';
% title = 'stone';

%*************************************************************
switch (title)
    case 'animal'; p = [350, 40, 100, 70, 0];
        opt = struct('numsample',400, 'affsig',[16,16,.000,.000,.000,.000]);
        forMat = '.jpg';
        
    case 'board'; p = [154,243,195,153,0];
        opt = struct('numsample',100, 'affsig',[10, 10, .03, .00, .001, .00]);
        forMat = '.jpg';
        
    case 'car11';  p = [89 140 30 25 0];
        opt = struct('numsample',200, 'affsig',[5,5,.01,.01,.001,.001]);
        forMat = '.jpg';
        
    case 'caviar'; p = [162 216 50 140 0.0];
        opt = struct('numsample',120, 'affsig',[6,5,.01,.00,.001,.0000]);
        forMat = '.jpg';
        
    case 'faceocc2'; p = [156,107,74,100,0.00];
        opt = struct('numsample',100, 'affsig',[4, 4, .02, .03, .001,.000]);
        forMat = '.jpg';
        
    case 'girl'; p =   [180,109,104,127,0];
        opt = struct('numsample',120, 'affsig',[10,10,.08,.00,.000,.000]);
        forMat = '.jpg';
        
    case 'jumping'; p = [163,126,33,32,0];
        opt = struct('numsample',400, 'affsig',[8,18,.000,.000,.000,.00]);
        forMat = '.jpg';
        
    case 'panda'; p = [286 171 25 25 0.01];
        opt = struct('numsample',500, 'affsig',[9,9,.01,.000,.000,.0000]);
        forMat = '.jpg';
        
    case 'shaking'; p = [255, 170, 60, 70, 0 ];
        opt = struct('numsample',100, 'affsig',[4,4,.03,.00,.00,.00]);
        forMat = '.jpg';
        
    case 'singer1'; p = [100, 200, 100, 300, 0];
        opt = struct('numsample',100, 'affsig',[4,4,.05,.0005,.0005,.001]);
        forMat = '.jpg';
        
    case 'stone'; p = [115 150 43 20 0.0];
        opt = struct('numsample',300, 'affsig',[6,6,.01,.00,.000,.0000]);
        forMat = '.jpg';
        
    otherwise;  error(['unknown title ' title]);
end

%%*****************************************************************%%
dataPath = [ 'Datasets\' title '\'];
