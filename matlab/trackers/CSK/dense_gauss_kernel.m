function k = dense_gauss_kernel(sigma, x, y)
%DENSE_GAUSS_KERNEL Gaussian Kernel with dense sampling.
%   Evaluates a gaussian kernel with bandwidth SIGMA for all displacements
%   between input images X and Y, which must both be MxN. They must also
%   be periodic (ie., pre-processed with a cosine window). The result is
%   an MxN map of responses.
%
%   If X and Y are the same, ommit the third parameter to re-use some
%   values, which is faster.
%
%   João F. Henriques, 2012
%   http://www.isr.uc.pt/~henriques/
	
	xf = fft2(x);  %x in Fourier domain
	xx = x(:)' * x(:);  %squared norm of x
		
	if nargin >= 3,  %general case, x and y are different
		yf = fft2(y);
		yy = y(:)' * y(:);
	else
		%auto-correlation of x, avoid repeating a few operations
		yf = xf;
		yy = xx;
	end

	%cross-correlation term in Fourier domain
	xyf = xf .* conj(yf);
	xy = real(circshift(ifft2(xyf), floor(size(x)/2)));  %to spatial domain
	
	%calculate gaussian response for all positions
	k = exp(-1 / sigma^2 * max(0, (xx + yy - 2 * xy) / numel(x)));

end

