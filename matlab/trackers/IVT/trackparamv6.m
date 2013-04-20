% script: trackparamv6.m
%     loads data and initializes variables
%

% Copyright (C) Jongwoo Lim and David Ross.
% All rights reserved.

% DESCRIPTION OF OPTIONS:
%
% Following is a description of the options you can adjust for
% tracking, each proceeded by its default value.  For a new sequence
% you will certainly have to change p.  To set the other options,
% first try using the values given for one of the demonstration
% sequences, and change parameters as necessary.
%
% p = [px, py, sx, sy, theta]; The location of the target in the first
% frame.
% px and py are th coordinates of the centre of the box
% sx and sy are the size of the box in the x (width) and y (height)
%   dimensions, before rotation
% theta is the rotation angle of the box
%
% 'numsample',400,   The number of samples used in the condensation
% algorithm/particle filter.  Increasing this will likely improve the
% results, but make the tracker slower.
%
% 'condenssig',0.01,  The standard deviation of the observation likelihood.
%
% 'ff',1, The forgetting factor, as described in the paper.  When
% doing the incremental update, 1 means remember all past data, and 0
% means remeber none of it.
%
% 'batchsize',5, How often to update the eigenbasis.  We've used this
% value (update every 5th frame) fairly consistently, so it most
% likely won't need to be changed.  A smaller batchsize means more
% frequent updates, making it quicker to model changes in appearance,
% but also a little more prone to drift, and require more computation.
%
% 'affsig',[4,4,.02,.02,.005,.001]  These are the standard deviations of
% the dynamics distribution, that is how much we expect the target
% object might move from one frame to the next.  The meaning of each
% number is as follows:
%
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = rotation angle (radians, mean is 0)
%    affsig(4) = x scaling (pixels, mean is 1)
%    affsig(5) = y scaling (pixels, mean is 1)
%    affsig(6) = scaling angle (radians, mean is 0)
%
% OTHER OPTIONS THAT COULD BE SET HERE:
%
% 'tmplsize', [32,32] The resolution at which the tracking window is
% sampled, in this case 32 pixels by 32 pixels.  If your initial
% window (given by p) is very large you may need to increase this.
%
% 'maxbasis', 16 The number of basis vectors to keep in the learned
% apperance model.

% Change 'title' to choose the sequence you wish to run.  If you set
% title to 'dudek', for example, then it expects to find a file called 
% dudek.mat in the current directory.
%
% Setting dump_frames to true will cause all of the tracking results
% to be written out as .png images in the subdirectory ./dump/.  Make
% sure this directory has already been created.
title = 'dudek';
dump_frames = 0;

switch (title)
case 'dudek';  p = [188,192,110,130,-0.08];
    opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
                 'batchsize',5, 'affsig',[9,9,.05,.05,.005,.001]);
% Use the following set of parameters for the ground truth experiment.
% It's much slower, but more accuracte.
%case 'dudek';  p = [188,192,110,130,-0.08];
%     opt = struct('numsample',4000, 'condenssig',0.25, 'ff',0.99, ...
%                 'batchsize',5, 'affsig',[11,9,.05,.05,0,0], ...
%                 'errfunc','');
case 'davidin300';  p = [160 106 62 78 -0.02];
    opt = struct('numsample',600, 'condenssig',0.75, 'ff',.99, ...
                 'batchsize',5, 'affsig',[5,5,.01,.02,.002,.001]);
case 'sylv';  p = [145 81 53 53 -0.2];
    opt = struct('numsample',600, 'condenssig',0.75, 'ff',.95, ...
                 'batchsize',5, 'affsig',[7,7,.01,.02,.002,.001]);
case 'trellis70';  p = [200 100 45 49 0];
    opt = struct('numsample',600, 'condenssig',0.2, 'ff',.95, ...
                 'batchsize',5, 'affsig',[4,4,.01,.01,.002,.001]);
case 'fish';  p = [165 102 62 80 0];
    opt = struct('numsample',600, 'condenssig',0.2, 'ff',1, ...
                 'batchsize',5, 'affsig',[7,7,.01,.01,.002,.001]);
case 'toycan';  p = [137 113 30 62 0];
    opt = struct('numsample',600, 'condenssig',0.2, 'ff',1, ...
                 'batchsize',5, 'affsig',[7,7,.01,.01,.002,.001]);
case 'car4';  p = [245 180 200 150 0];
    opt = struct('numsample',600, 'condenssig',0.2, 'ff',1, ...
                 'batchsize',5, 'affsig',[5,5,.025,.01,.002,.001]);
case 'car11';  p = [89 140 30 25 0];
    opt = struct('numsample',600, 'condenssig',0.2, 'ff',1, ...
                 'batchsize',5, 'affsig',[5,5,.01,.01,.001,.001]);
case 'mushiake'; p = [172 145 60 60 0];
    opt = struct('numsample',600, 'condenssig',0.2, 'ff',1, ...
                 'batchsize',5, 'affsig',[10, 10, .01, .01, .002, .001]);
%case 'dudekgt';  p = [188,192,110,130,-0.08]; 
%   opt = struct('numsample',4000, 'condenssig',1, 'ff',1, ...
%                 'batchsize',5, 'affsig',[6,5,.05,.05,0,0], ...
%                'errfunc','');
otherwise;  error(['unknown title ' title]);
end

if (~exist('datatitle') | ~strcmp(title,datatitle))
  if (exist('datatitle') & ~strcmp(title,datatitle))
    disp(['title does not match.. ' title ' : ' datatitle ', continue?']);
    pause;
  end
  disp(['loading ' title '...']);
  clear truepts;
  load([title 'v6.mat'],'data','datatitle','truepts');
end

param0 = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];
param0 = affparam2mat(param0);

opt.dump = dump_frames;
if (opt.dump & exist('dump') ~= 7)
  error('dump directory does not exist.. turning dump option off..');
  opt.dump = 0;
end
