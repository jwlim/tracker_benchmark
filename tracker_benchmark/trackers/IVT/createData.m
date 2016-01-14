
fprefix		= 'F:\data\blur\face_kang\';%folder storing the images
fext		= 'jpg';				%image format
start_frame	= 0;					%starting frame number
nframes		= 493;					%number of frames to be tracked

objRect = [246;226;94;114];
g_para.szTemplate = [17 15];

numzeros	= 4;	%number of digits for the frame index

s_frames	= cell(nframes,1);
nz = strcat('%0',num2str(numzeros),'d'); %number of zeros in the name of image

fid = sprintf(nz, start_frame);
img_color = imread([fprefix,fid,'.',fext]);
[r,c,ch] = size(img_color);
data = zeros(r,c,nframes);

for t=1:nframes
    
    fprintf('%d \n',t);
    
    image_no	= start_frame + (t-1);
    fid			= sprintf(nz, image_no);
	s_frames{t}	= strcat(fprefix,fid,'.',fext);
    
    img_color	= imread(s_frames{t});
    data(:,:,t)  = double(rgb2gray(img_color));
end

datatitle = 'faceKang';
%truepts = zeros(2,7,nframes);
disp(['saving ' datatitle '...']);
save([datatitle '.mat'],'data','datatitle');
