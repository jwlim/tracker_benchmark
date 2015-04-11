% Load a frame from file
% 
% [I] = loadFrame(fileName,DS)
% 
% Input :
%                 fileName - frame full file name (including path)
%                 DS - down sampling factor [0,1]
% 
% Output:
%                 I - loaded frame
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [I] = loadFrame(fileName,DS)

if nargin == 1
    DS = 1;
end

% Load image
[pathstr,name,ext] = fileparts(fileName);
fullName = dir(strcat(fileName,'*'));
I = imread(fullfile(pathstr,fullName.name));

% Down sample image (if needed)
if DS < 1
    I = imresize(I,DS);
end

% If gray scale image replicate to 3 channels
if size(I,3)==1
    I = repmat(I,[1,1,3]);
end