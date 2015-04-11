% Get a list of all PNG or JPG frames in input directory
% 
% [files] = getFrameList(param)
% 
% Input :
%             param - Run parameter structure
% 
% Output:
%             files - List of frames
% 
% Writen by: Shaul Oron
% Last Updated: 19/04/2012
% shauloron@gmail.com
% Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel

function [files] = getFrameList(param)

files = dir(fullfile(param.inputDir,'*.png'));
if isempty(files)
        files = dir(fullfile(param.inputDir,'*.jpg'));
end
if isempty(files)
        files = dir(fullfile(param.inputDir,'*.bmp'));
end
if isempty(files)
        error('No PNG, BMP or JPG files found at specified directory!')
end