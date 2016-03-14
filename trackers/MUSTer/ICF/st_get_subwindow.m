function out = st_get_subwindow(im, pos, model_sz, currentScaleFactor)
%GET_SUBWINDOW Obtain sub-window from image, with replication-padding.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

	if isscalar(model_sz),  %square sub-window
		model_sz = [model_sz, model_sz];
	end
	patch_sz = floor(model_sz * currentScaleFactor);
	xs = floor(pos(2)) + (1:patch_sz(2)) - floor(patch_sz(2)/2);
	ys = floor(pos(1)) + (1:patch_sz(1)) - floor(patch_sz(1)/2);
	
	%check for out-of-bounds coordinates, and set them to the values at
	%the borders
	xs(xs < 1) = 1;
	ys(ys < 1) = 1;
	xs(xs > size(im,2)) = size(im,2);
	ys(ys > size(im,1)) = size(im,1);
	
	%extract image
	out = im(ys, xs, :);
    out = imresize(out, model_sz);
end

