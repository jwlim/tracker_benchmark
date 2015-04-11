% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing



% Take a single image and create a cell array of progressively downsampled images.
function [I_pyr_cell] = gauss_pyramid( I, numScales, sigma0, sigmaS )

%%% Downsampling possible only in factors of 2.

% VERBOSE = 0;
DISPLAY = 0; % 0 -- no display
             % 1 -- visualize the pyramid
         
if nargin < 2, numScales = 3; end;
if nargin < 3, sigma0 = 2/5;  end;
if nargin < 4, sigmaS = 1;    end;

if DISPLAY > 0
    figure(1); clf;
    figure(2); clf;
end

% first form a Gaussian pyramid for the input image
I_pyr_cell = cell(numScales,1);

w = max(ceil(4*sigma0),7);
I_pyr_cell{1} = imfilter( I, fspecial('gaussian',[w w],sigma0) );

if DISPLAY > 0, 
    figure(1);
    subplot(numScales,1,1);
    imagesc(I_pyr_cell{1});
    colormap('gray'); axis off; axis equal;
end

for i = 2:numScales,
    w = max(ceil(3*sigmaS),7);    
    I_filter = imfilter(I_pyr_cell{i-1}, fspecial('gaussian',[w w],sigmaS));
    I_pyr_cell{i} = I_filter(1:2:end,1:2:end);
    
    if DISPLAY > 0,
        figure(1);
        subplot(numScales,1,i);
        imagesc(I_pyr_cell{i});
        colormap('gray'); axis off; axis equal;        
    end
end

% % transformation for downsampling
% T_ds = [ 0.5,   0, -0.5; ...
%          0,   0.5, -0.5   ];
