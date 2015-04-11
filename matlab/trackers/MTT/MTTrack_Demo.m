function MTTrack_Demo()
% This is an example code for the Multi-Task Tracking published in the following paper:
% Tianzhu Zhang, Bernard Ghanem, Si Liu, Narendra Ahuja."Robust Visual Tracking via Multi-Task Sparse Learning", 
% IEEE International Conference on Computer Vision and Pattern Recognition (CVPR Oral), 2012.
% Tianzhu Zhang, Bernard Ghanem, Si Liu, Narendra Ahuja."Robust Visual Tracking via Structured Multi-Task Sparse Learning," 
% International Journal of Computer Vision (IJCV), 2012.
% If you use the code and compare with our MTT trackers, please cite the above two papers.

clc;clear all;close all;
addpath('MTT_Toolbox');

%% video frames
video_name = 'car11';
video_path = fullfile('.\data\',video_name);
m_start_frame = 1;  %starting frame number
nframes		= 393; %393;	 %number of frames to be tracked
Imgext		= 'png';				%image format
numzeros	= 4;	%number of digits for the frame index
all_images	= cell(nframes,1);
nz			= strcat('%0',num2str(numzeros),'d'); %number of zeros in the name of image
for t=1:nframes
    image_no	= m_start_frame + (t-1);
    fid			= sprintf(nz, image_no);
    all_images{t}	= strcat(video_path,'\',fid,'.',Imgext);
end

%% initialize bounding box
m_boundingbox = [75,129,25,19];  % [left-top-x, left-top-y, width, height];

% init_pos	= SelectTarget(all_images{1});  % automatically get bounding box
% init_pos =  [p1 p2 p3];
% 			  p1-------------------p3
% 				\					\
% 				 \       target      \
% 				  \                   \
% 				  p2-------------------\  
init_pos = [m_boundingbox(2)   m_boundingbox(2)+m_boundingbox(4)  m_boundingbox(2) ;
            m_boundingbox(1)   m_boundingbox(1)                   m_boundingbox(1)+m_boundingbox(3)];
opt.init_pos = double(init_pos);  %  initialization bounding box

width = m_boundingbox(3);
height = m_boundingbox(4);
%% 	set object size including height and width based on the initialization		
if min( 0.5*[height width]) < 25
    sz_T = 1.0 * [height width];
    if height > 80
        sz_T =  [ 0.5 *height width];  
    end
else
    sz_T = 0.5 * [height width];
end
sz_T = ceil(sz_T);
if min(sz_T>32)
    sz_T = [32 32];
end


%% MTT tracking Parameters
opt.n_sample = 400;		% number of particles   400
opt.sz_T= sz_T;         % object size
opt.tracker_type = 'L21';  opt.lambda = 0.01; % three different trackers: L21, L11, L01(denote L\infinity 1);
% opt.tracker_type = 'L11';  opt.lambda = 0.005;
% opt.tracker_type = 'L01';  opt.lambda = 0.2;
opt.eta  = 0.01;
opt.obj_fun_th = 1e-3;
opt.iter_maxi = 100; % lambda, eta,obj_fun_th, and iter_maxi are parameters for Accelerated Proximal Gradient (APG) Optimization. Please refer to our paper for details.
opt.rel_std_afnv =  [0.005,0.0005,0.0005,0.005,4,4]; % affine parameters for particle sampling
 
opt.m_theta = 0.6;  % [0 1] decide object template update
opt.show_optimization = false; % show optimization results to help tue eta and lambda for APG optimization.
opt.show_time = true; % show optimization speed

%% Run MTT tracking. To get better results for different videos, we can change sz_T, rel_std_afnv,  and m_theta.
% m_track: tracking result;
% m_speed: the time (second) per frame
[tracking_res,m_speed] = MTT_Tracking(all_images,opt);


%% Save tracking results
all_results_path = '.\MTT_Results\';
if ~exist([all_results_path video_name])
    mkdir([all_results_path video_name]);
end
all_rect = [];
for t = 1:nframes
    img_color	= imread(all_images{t});
    img_color	= double(img_color);
    imshow(uint8(img_color));
    text(5,10,num2str(t),'FontSize',18,'Color','r');
    color = [1 0 0];
    map_afnv	= tracking_res(:,t)';
    rect=drawAffine(map_afnv, sz_T, color, 2);
    all_rect =[all_rect; rect(2,1) rect(1,1) rect(2,3)-rect(2,1) rect(1,2)-rect(1,1)];
    
    s_res	= all_images{t}(1:end-4);
    s_res	= fliplr(strtok(fliplr(s_res),'/'));
    s_res	= fliplr(strtok(fliplr(s_res),'\'));
    s_res	= [s_res '_MTT.png'];
    f = getframe(gcf);
    imwrite(uint8(f.cdata), [all_results_path video_name '\' s_res]);
end


