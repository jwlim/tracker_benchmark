clc;
clear all;
close all;

% addpath
addpath RASL_toolbox ;

title = 'rubic3';

[para, paraSeq]=paraConfig(title);

% dispaly flag
para.bSaveImage = 1;

if ~exist(paraSeq.destDir,'dir')
    mkdir(paraSeq.destDir) ;
end

% initRect=dlmread(initFile);

nz = strcat('%0',num2str(paraSeq.numZ),'d'); %number of zeros in the name of image
id = sprintf(nz, paraSeq.beginFrame);
beginImgFile = [paraSeq.filepath, id, '.', paraSeq.ext];

%% Get training images

img = double(imread(beginImgFile));

if size(img,3) > 1,   
    img = img(:,:,2);            
end

numBasis=para.numBasis;

[A init_T]= init(img, paraSeq.objRect, numBasis, para.canonicalImageSize, para.canonicalPts, para.preprocessType);

init_xi = projective_matrix_to_parameters( para.transformType, init_T);

% d_all=[];
% Do_all=[];
% a_all=[];
% e_all=[];
numFrame = paraSeq.endFrame - paraSeq.beginFrame+1;
xi_all=zeros(size(init_xi,1),numFrame);
xi_all(:,1) = init_xi;

timeTotal = 0;

index=1;

for inum = paraSeq.beginFrame+1 : paraSeq.endFrame
    
    index=index+1;
    
    id = sprintf(nz, inum);
    imgfile = [paraSeq.filepath, id, '.', paraSeq.ext];
    currentImage = double(imread(imgfile));
    
    if size(currentImage,3) > 1,   
        currentImage = currentImage(:,:,2);            
    end
    
    tic
    
    [d, Do, a, e, xi, numIterOuter, numIterInner ] = oria(currentImage,A,init_xi, para);
    
    A=updateTemplates(A, Do, index);
    
    timeTotal=timeTotal+toc;
%     d_all=[d_all,d];
%     Do_all=[Do_all,Do];
%     a_all=[a_all,a];
%     e_all=[e_all,e];
    xi_all(:,index) = xi;
    
    disp(['#' num2str(inum) ' ||E||_0 ' num2str(length(find(abs(e)>0))) ' ||E||_1 ' num2str(norm(e,1))]);
    %     [d, Do, a, e, xi, numIterOuter, numIterInner ] = rasl_scale_online(currentImage,A,init_xi, para, destDir);
    
    init_xi = xi;
%     tracking_res=[tracking_res xi];
%     save('tracking_res.mat','tracking_res')   
    
    if para.bSaveImage
        imshow(uint8(currentImage));

        imgSize = para.canonicalImageSize;
        fr = [1 1          imgSize(2) imgSize(2) 1; ...
            1 imgSize(1) imgSize(1) 1          1; ...
            1 1          1          1          1 ];
        T_in = parameters_to_projective_matrix(para.transformType,xi);
        Tfm = fliptform(maketform('projective',inv(T_in')));
        curFrame = tformfwd(fr(1:2,:)', Tfm )';
        plot( curFrame(1,:), curFrame(2,:), 'r-', 'LineWidth', 2 );

        saveas(gcf,[paraSeq.destDir num2str(inum) '.jpg'])
    end
end
% save([paraSeq.destDir 'results.mat'], 'd_all','Do_all','a_all', 'e_all','xi_all','A','para');
disp(['fps: ', num2str((numFrame-1)/timeTotal)]);

xi=xi_all;
transformType=para.transformType;
sz_T=para.canonicalImageSize;
save([paraSeq.destDir title '_align'],'xi','sz_T','transformType')

