function [ center corners ] = drawbox(varargin)
% function drawbox(width,height, param, properties)
%                 ([width,height], param, properties)
%
%   param, properties are optional
%

%% Copyright (C) Jongwoo Lim and David Ross.
%% All rights reserved.
%% Thanks to Jongwoo Lim and David Ross for this code.  -- Wei Zhong.


%----------------------------------------------------------
% Process the input.
%----------------------------------------------------------

if (length(varargin{1}) == 2)
  w = varargin{1}(1);
  h = varargin{1}(2);
  varargin(1) = [];
else
  [w,h] = deal(varargin{1:2});
  varargin(1:2) = [];
end

if (length(varargin) < 1 || any(length(varargin{1}) ~= 6))
  M = [0,1,0; 0,0,1];
else
  p = varargin{1};
  if (length(varargin) > 1 && strcmp(varargin{2},'geom'))
    p = affparam2mat(p);
    varargin(1:2) = [];
  else
    varargin(1) = [];
  end
  M = [p(1) p(3) p(4); p(2) p(5) p(6)];     %%affine parameters
end

%----------------------------------------------------------
% Draw the box.
%----------------------------------------------------------

corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
corners = M * corners;

line(corners(1,:), corners(2,:), varargin{:});

center = mean(corners(:,1:4),2);
hold_was_on = ishold; hold on;
plot(center(1),center(2),varargin{:});
if (~hold_was_on) hold off; end
