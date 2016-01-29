function results=run_CSK(seq, res_path, bSaveImage)

%  Exploiting the Circulant Structure of Tracking-by-detection with Kernels
%
%  Main script for tracking, with a gaussian kernel.
%
%  João F. Henriques, 2012
%  http://www.isr.uc.pt/~henriques/

%Reference: 
%
%   F. Henriques, R. Caseiro, P. Martins, and J. Batista, “Exploiting the Circulant Structure of Tracking-by-Detection with Kernels,” in ECCV, 2012.
%
%modified by Yi Wu @ UC Merced, 10/17/2012
%

%choose the path to the videos (you'll be able to choose one with the GUI)
% base_path = 'E:\data\data_tracking\benchmark\MIL_data\';

close all

s_frames = seq.s_frames;

%parameters according to the paper
padding = 1;					%extra area surrounding the target
output_sigma_factor = 1/16;		%spatial bandwidth (proportional to target)
sigma = 0.2;					%gaussian kernel bandwidth
lambda = 1e-2;					%regularization
interp_factor = 0.075;			%linear interpolation factor for adaptation



%notation: variables ending with f are in the frequency domain.

%ask the user for the video
% video_path = choose_video(base_path);
% if isempty(video_path), return, end  %user cancelled
% [img_files, pos, target_sz, resize_image, ground_truth, video_path] = ...
% 	load_video_info(video_path);

    target_sz = [seq.init_rect(1,4), seq.init_rect(1,3)];
	pos = [seq.init_rect(1,2), seq.init_rect(1,1)] + floor(target_sz/2);
    
    	%if the target is too large, use a lower resolution - no need for so
	%much detail
	if sqrt(prod(target_sz)) >= 100,
		pos = floor(pos / 2);
		target_sz = floor(target_sz / 2);
		resize_image = true;
	else
		resize_image = false;
    end
    

%window size, taking padding into account
sz = floor(target_sz * (1 + padding));

%desired output (gaussian shaped), bandwidth proportional to target size
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor;
[rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
yf = fft2(y);

%store pre-computed cosine window
cos_window = hann(sz(1)) * hann(sz(2))';


time = 0;  %to calculate FPS
positions = zeros(numel(s_frames), 2);  %to calculate precision
rect_position = zeros(numel(s_frames), 4);

for frame = 1:numel(s_frames),
	%load image
	im = imread(s_frames{frame});
	if size(im,3) > 1,
		im = rgb2gray(im);
	end
	if resize_image,
		im = imresize(im, 0.5);
	end
	
	tic()
	
	%extract and pre-process subwindow
	x = get_subwindow(im, pos, sz, cos_window);
	
	if frame > 1,
		%calculate response of the classifier at all locations
		k = dense_gauss_kernel(sigma, x, z);
		response = real(ifft2(alphaf .* fft2(k)));   %(Eq. 9)
		
		%target location is at the maximum response
		[row, col] = find(response == max(response(:)), 1);
		pos = pos - floor(sz/2) + [row, col];
	end
	
	%get subwindow at current estimated target position, to train classifer
	x = get_subwindow(im, pos, sz, cos_window);
	
	%Kernel Regularized Least-Squares, calculate alphas (in Fourier domain)
	k = dense_gauss_kernel(sigma, x);
	new_alphaf = yf ./ (fft2(k) + lambda);   %(Eq. 7)
	new_z = x;
	
	if frame == 1,  %first frame, train with a single image
		alphaf = new_alphaf;
		z = x;
	else
		%subsequent frames, interpolate model
		alphaf = (1 - interp_factor) * alphaf + interp_factor * new_alphaf;
		z = (1 - interp_factor) * z + interp_factor * new_z;
	end
	
	%save position and calculate FPS
	positions(frame,:) = pos;
	time = time + toc();
	
	%visualization
	rect_position(frame,:) = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    
    if bSaveImage
        if frame == 1,  %first frame, create GUI
%             figure('Number','off', 'Name',['Tracker - ' video_path])
            im_handle = imshow(im, 'Border','tight', 'InitialMag',200);
            rect_handle = rectangle('Position',rect_position(frame,:), 'EdgeColor','g');
        else
            try  %subsequent frames, update GUI
                set(im_handle, 'CData', im)
                set(rect_handle, 'Position', rect_position(frame,:))
            catch  %#ok, user has closed the window
                return
            end
        end
        imwrite(frame2im(getframe(gcf)),[res_path num2str(frame) '.jpg']); 
    end
	
	drawnow
% 	pause(0.05)  %uncomment to run slower
end

if resize_image, rect_position = rect_position * 2; end

fps = numel(s_frames) / time;

disp(['fps: ' num2str(fps)])

results.type = 'rect';
results.res = rect_position;%each row is a rectangle
results.fps = fps;

%show the precisions plot
% show_precision(positions, ground_truth, video_path)

