function [img_files, pos, target_sz, resize_image, ground_truth, ...
	video_path] = load_video_info(video_path)
%LOAD_VIDEO_INFO
%   Loads all the relevant information for the video in the given path:
%   the list of image files (cell array of strings), initial position
%   (1x2), target size (1x2), whether to resize the video to half
%   (boolean), and the ground truth information for precision calculations
%   (Nx2, for N frames). The ordering of coordinates is always [y, x].
%
%   The path to the video is returned, since it may change if the images
%   are located in a sub-folder (as is the default for MILTrack's videos).
%
%   João F. Henriques, 2012
%   http://www.isr.uc.pt/~henriques/

	%load ground truth from text file (MILTrack's format)
	text_files = dir([video_path '*_gt.txt']);
	assert(~isempty(text_files), 'No initial position and ground truth (*_gt.txt) to load.')

	f = fopen([video_path text_files(1).name]);
	ground_truth = textscan(f, '%f,%f,%f,%f');  %[x, y, width, height]
	ground_truth = cat(2, ground_truth{:});
	fclose(f);
	
	%set initial position and size
	target_sz = [ground_truth(1,4), ground_truth(1,3)];
	pos = [ground_truth(1,2), ground_truth(1,1)] + floor(target_sz/2);
	
	%interpolate missing annotations, and store positions instead of boxes
	try
		ground_truth = interp1(1 : 5 : size(ground_truth,1), ...
			ground_truth(1:5:end,:), 1:size(ground_truth,1));
		ground_truth = ground_truth(:,[2,1]) + ground_truth(:,[4,3]) / 2;
	catch  %#ok, wrong format or we just don't have ground truth data.
		ground_truth = [];
	end
	
	%list all frames. first, try MILTrack's format, where the initial and
	%final frame numbers are stored in a text file. if it doesn't work,
	%try to load all png/jpg files in the folder.
	
	text_files = dir([video_path '*_frames.txt']);
	if ~isempty(text_files),
		f = fopen([video_path text_files(1).name]);
		frames = textscan(f, '%f,%f');
		fclose(f);
		
		%see if they are in the 'imgs' subfolder or not
		if exist([video_path num2str(frames{1}, 'imgs/img%05i.png')], 'file'),
			video_path = [video_path 'imgs/'];
		elseif ~exist([video_path num2str(frames{1}, 'img%05i.png')], 'file'),
			error('No image files to load.')
		end
		
		%list the files
		img_files = num2str((frames{1} : frames{2})', 'img%05i.png');
		img_files = cellstr(img_files);
	else
		%no text file, just list all images
		img_files = dir([video_path '*.png']);
		if isempty(img_files),
			img_files = dir([video_path '*.jpg']);
			assert(~isempty(img_files), 'No image files to load.')
		end
		img_files = sort({img_files.name});
	end
	
	
	%if the target is too large, use a lower resolution - no need for so
	%much detail
	if sqrt(prod(target_sz)) >= 100,
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
		resize_image = true;
	else
		resize_image = false;
	end
end

