clear;
close all
clc

times  = 1; %operate times; to avoid overwriting previous saved tracking result in the .mat format
title = 'david';
res_path='results\';

para.rel_std_afnv = [0.003,0.0005,0.0005,0.003,1,1];%diviation of the sampling of particle filter

%% parameter setting for each sequence
switch title
    case 'car4'
        fprefix ='E:\tracking\nmf_tracking\2012_PR_NMF\submit\data\car4\';
        fext ='bmp';    %Image format of the sequence
        numzeros= 1;	%number of digits for the frame index
        start_frame = 12;   % first frame index to be tracked
        nframes		= 630;	% number of frames to be tracked
        %Initialization for the first frame. 
        %Each column is a point indicating a corner of the target in the first image. 
        %The 1st row is the y coordinate and the 2nd row is for x.
        %Let [p1 p2 p3] be the three points, they are used to determine the affine parameters of the target, as following
        %    p1(65,55)-----------p3(170,53)
        %         | 				|		 
        %         |     target      |
        %         | 				|	        
        %   p2(64,140)--------------
        init_pos= [56,141,56;
                   69,69,174];
        sz_T =[12,15];      % size of template    
        para.rel_std_afnv = [0.03,0.0005,0.0005,0.03,1,1];%diviation of the sampling of particle filter
    case 'car'
        fprefix ='E:\tracking\nmf_tracking\2012_PR_NMF\submit\data\car\';
        fext ='jpg';    %Image format of the sequence
        numzeros= 1;	%number of digits for the frame index
        start_frame = 13;   % first frame index to be tracked
        nframes		= 252;	% number of frames to be tracked

        init_pos= [167,192,167;
                   8,8,51];
        sz_T =[12,15];      % size of template
        para.rel_std_afnv = [0.02,0.0005,0.0005,0.02,2,2];%diviation of the sampling of particle filter
    case 'david'
        fprefix ='E:\tracking\nmf_tracking\2012_PR_NMF\submit\data\david\imgs\img';
        fext ='png';    %Image format of the sequence
        numzeros= 5;	%number of digits for the frame index
        start_frame = 1;   % first frame index to be tracked
        nframes		= 462;	% number of frames to be tracked

        init_pos= [80,158,80;
                   130,130,188];
        sz_T =[18,14];      % size of template
        para.rel_std_afnv = [0.01,0.005,0.0005,0.01,2,2];%diviation of the sampling of particle filter
        
    case 'me'
        fprefix ='E:\tracking\nmf_tracking\2012_PR_NMF\submit\data\me\';
        fext ='jpg';    %Image format of the sequence
        numzeros= 1;	%number of digits for the frame index
        start_frame = 7;   % first frame index to be tracked
        nframes		= 550;	% number of frames to be tracked

        init_pos= [139,182,139;
                   299,299,332];
        sz_T =[18,15];      % size of template
        para.rel_std_afnv = [0.003,0.0005,0.0005,0.003,3,3];%diviation of the sampling of particle filter
        
    case 'PETS01D1Human1'
        fprefix ='E:\tracking\nmf_tracking\2012_PR_NMF\submit\data\PETS01D1Human1\';
        fext ='jpg';    %Image format of the sequence
        numzeros= 1;	%number of digits for the frame index
        start_frame = 1412;   % first frame index to be tracked
        nframes		= 412;	% number of frames to be tracked

        init_pos= [441,524,441;
                   693,693,718];
        sz_T =[18,12];      % size of template       
        para.rel_std_afnv = [0.01,0.0005,0.0005,0.01,1,1];%diviation of the sampling of particle filter
        
    case 'seq_mb'
        fprefix ='E:\tracking\nmf_tracking\2012_PR_NMF\submit\data\seq_mb\img';
        fext ='bmp';    %Image format of the sequence
        numzeros= 3;	%number of digits for the frame index
        start_frame = 1;   % first frame index to be tracked
        nframes		= 500;	% number of frames to be tracked

        init_pos= [21,67,21;
                   57,57,93];
        sz_T =[18,14];      % size of template       
        para.rel_std_afnv = [0.01,0.0005,0.0005,0.01,1,1];%diviation of the sampling of particle filter
end

%prepare the file name for each image
s_frames = cell(nframes,1);
nz	= strcat('%0',num2str(numzeros),'d'); %number of zeros in the name of image
for t=1:nframes
    image_no	= start_frame + (t-1);
    id=sprintf(nz,image_no);
    s_frames{t} = strcat(fprefix,id,'.',fext);
end

%prepare the path for saving tracking results
res_path=[res_path title '\'];
if ~exist(res_path,'dir')
    mkdir(res_path);
end
%% parameters setting for tracking
para.lambda = [0.2,0.001,10]; % lambda 1, lambda 2 for a_T and a_I respectively, lambda 3 for the L2 norm parameter
% set para.lambda = [a,a,0]; then this the old model
para.angle_threshold = 40;
para.Lip = 8;
para.Maxit = 5;
para.nT = 10;%number of templates for the sparse representation

para.n_sample = 600;		%number of particles
para.s_debug_path = res_path;
para.sz_T=sz_T;
para.init_pos = init_pos;
para.bDebug = 1;		%debugging indicator
bShowSaveImage=0;       %indicator for result image show and save after tracking finished

%% main function for tracking
[tracking_res,output]  = L1TrackingBPR_APGup(s_frames, para);

disp(['fps: ' num2str(nframes/sum(output.time))])
%% Output tracking results

save([res_path title '_L1_APG_' num2str(times) '.mat'], 'tracking_res','sz_T','output');

if ~para.bDebug&bShowSaveImage
    for t = 1:nframes
        img_color	= imread(s_frames{t});
        img_color	= double(img_color);
        imshow(uint8(img_color));
        text(5,10,num2str(t+start_frame),'FontSize',18,'Color','r');
        color = [1 0 0];
        map_afnv	= tracking_res(:,t)';
        drawAffine(map_afnv, sz_T, color, 2);%draw tracking result on the figure
        drawnow
        %save tracking result image
        s_res	= s_frames{t}(1:end-4);
        s_res	= fliplr(strtok(fliplr(s_res),'/'));
        s_res	= fliplr(strtok(fliplr(s_res),'\'));
        s_res	= [res_path s_res '_L1_APG.jpg'];
        saveas(gcf,s_res)
    end
end
