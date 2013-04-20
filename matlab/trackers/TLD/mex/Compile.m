% Copyright 2011 Zdenek Kalal
%
% This file is part of TLD.
%
% TLD is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.

% Compiles mex files
% clc; clear all;
% cd mex;
% addpath('./mex');

opencv_include = '';
opencv_lib = '';
if ispc
    disp('PC');
    opencv_dir = 'c:\OpenCV2.2\';
    opencv_include = [' -I' opencv_dir 'include\opencv\ -I' opencv_dir 'include\'];
    libpath = [opencv_dir 'lib\'];
    files = dir([libpath '*.lib']);
    for i = 1:length(files),
        opencv_lib = [opencv_lib ' ' libpath files(i).name];
    end
elseif ismac
    disp('Mac');
%     opencv_dir = '/opt/local/';
    opencv_dir = '/usr/local/';
    opencv_include = [' -I' opencv_dir 'include/opencv/ -I' opencv_dir '/include/'];
    libpath = [opencv_dir 'lib/']; 
    files = dir([libpath 'libopencv*.dylib']);
    for i = 1:length(files),
        opencv_lib = [opencv_lib ' ' libpath files(i).name];
    end
elseif isunix
    disp('Unix');
    opencv_include = ' -I/usr/local/include/opencv/ -I/usr/local/include/';
    libpath = '/usr/local/lib/';
    files = dir([libpath 'libopencv*.so.2.2']);
    for i = 1:length(files),
        opencv_lib = [opencv_lib ' ' libpath files(i).name];
    end
end
    
eval(['mex lk.cpp -O' opencv_include opencv_lib]);
mex -O fern.cpp tld.cpp
mex -O linkagemex.cpp
mex -O bb_overlap.cpp
mex -O warp.cpp
mex -O distance.cpp

% cd ..
disp('Compilation finished.');

