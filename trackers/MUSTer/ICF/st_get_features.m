function x = st_get_features(im, features, cell_size, cos_window)
%GET_FEATURES
%   Extracts dense features from image.
%
%   X = GET_FEATURES(IM, FEATURES, CELL_SIZE)
%   Extracts features specified in struct FEATURES, from image IM. The
%   features should be densely sampled, in cells or intervals of CELL_SIZE.
%   The output has size [height in cells, width in cells, features].
%
%   To specify HOG features, set field 'hog' to true, and
%   'hog_orientations' to the number of bins.
%
%   To experiment with other features simply add them to this function
%   and include any needed parameters in the FEATURES struct. To allow
%   combinations of features, stack them with x = cat(3, x, new_feat).
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/
global w2c;

	if features.hog,
		%HOG features, from Piotr's Toolbox
		x = double(fhog(single(im) / 255, cell_size, features.hog_orientations));
		x(:,:,end) = [];  %remove all-zeros channel ("truncation feature")
        
        [w, h, z] = size(im);
         x = imresize(x,[w, h], 'bilinear') ;
        
        if z == 3
           if isempty(w2c)
                % load the RGB to color name matrix if not in input
                temp = load('w2crs');
                w2c = temp.w2crs;
            end

            x(:,:,end+(1:10)) = im2c(single(im), w2c, -2);
        else
            x(:,:,end+1) = single(im)/255 - 0.5;
        end
%         
%         x(:,:,1) = single(im)/255 - 0.5;
%         temp = fhog(single(im), cell_size);
%         x(:,:,1:27) = temp(:,:,1:27);
	end
	
	if features.gray,
		%gray-level (scalar feature)
		x = double(im) / 255;
		
		x = x - mean(x(:));
	end
	
	%process with cosine window if needed
	if ~isempty(cos_window),
		x = bsxfun(@times, x, cos_window);
	end
	
end

function x1 = myresize(x, outsize, method_used)
x1 = zeros([outsize(end:-1:1), size(x, 3)]);
for i = 1:size(x, 3)
        x1(:, :, i) = cv.resize(x(:, :, i), outsize, 'Interpolation', method_used);
end
end