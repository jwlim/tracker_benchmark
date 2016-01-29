
% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function df = img2df(im, numBins)

% im should be double to avoid integer division
im = double(im);

%prepare data structure 
df = zeros(size(im, 1), size(im, 2), numBins);
[X, Y] = meshgrid(1:size(im, 2), 1:size(im, 1));

% build frequency matrix 
df(sub2ind(size(df), Y(:), X(:), ceil((im(:)+1)./(256/numBins)))) = 1;


