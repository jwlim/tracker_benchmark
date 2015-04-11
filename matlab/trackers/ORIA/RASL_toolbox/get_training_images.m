function [fileNames, transformations, numImages] = get_training_images( rootPath, ...
    pointrootPath, trainingDatabaseName, ...
    baseCoords, transformationInit)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   get_training_filenames
%
%   Inputs:
%       rootPath             --
%       trainingDatabaseName --
%       userNameList         --
%       transformationInit   --  initialization transformation type,
%                                depending on how much information on the batch images 
%
%   Outputs:
%       fileNames            --
%       transformations      --
%       labels               --
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yigang Peng, Arvind Ganesh, November 2009. 
% Questions? abalasu2@illinois.edu
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing



transformations = {};
fileNames = {};

imageIndex = 0;

userDirectoryContents = list_image_files(fullfile(rootPath, trainingDatabaseName));

if isempty(userDirectoryContents)
    error(['No image files were found! Check your paths; there should be images in ' fullfile(rootPath, trainingDatabaseName)]);
end

if strcmp(transformationInit,'IDENTITY')
    for fileIndex = 1:length(userDirectoryContents),
        imageName = userDirectoryContents{fileIndex};
        disp(['Using image file ' imageName '...']);

        imageIndex = imageIndex+1;

        imageFileName = fullfile(rootPath, trainingDatabaseName, imageName);
        fileNames{imageIndex} = imageFileName;

        transformations{imageIndex} = [1, 0, 0; 0 1 0; 0 0 1] ;
    end
elseif strcmp(transformationInit,'SIMILARITY')
    for fileIndex = 1:length(userDirectoryContents),
        imageName = userDirectoryContents{fileIndex};
        disp(['Using image file ' imageName '...']);

        imageIndex = imageIndex+1;

        imageFileName = fullfile(rootPath, trainingDatabaseName, imageName);
        fileNames{imageIndex} = imageFileName;

        pointFileName = fullfile(pointrootPath, trainingDatabaseName, imageName);
        % Load the initial control point data.
        CornerFileName = [pointFileName(1:end-4) '-points.mat'];
        if exist(CornerFileName, 'file'),
            load(CornerFileName); 
        else
            error(['No corner data found for image ' imageFileName '!']);
        end

        S = TwoPointSimilarity( baseCoords, points(:,1:2) );
        transformations{imageIndex} = S ;
    end
elseif strcmp(transformationInit,'AFFINE')
    for fileIndex = 1:length(userDirectoryContents),
        imageName = userDirectoryContents{fileIndex};
        disp(['Using image file ' imageName '...']);

        imageIndex = imageIndex+1;

        imageFileName = fullfile(rootPath, trainingDatabaseName, imageName);
        fileNames{imageIndex} = imageFileName;

        pointFileName = fullfile(pointrootPath, trainingDatabaseName, imageName);
        % Load the initial control point data.
        CornerFileName = [pointFileName(1:end-4) '-points.mat'];
        if exist(CornerFileName, 'file'),
            load(CornerFileName); 
        else
            error(['No corner data found for image ' imageFileName '!']);
        end

        S = ThreePointAffine( baseCoords, points(:,1:3) );
        transformations{imageIndex} = S ;
    end
else
    error(['unable to initialize the transformations!']);
end

numImages = length(userDirectoryContents) ;
return;
