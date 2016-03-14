classdef ICF_tracker < handle
   % The following properties can be set only by class methods
   properties (SetAccess = private)
        padding = 1.5;         			% extra area surrounding the target
        output_sigma_factor = 0.1; 	% standard deviation for the desired translation filter output
        scale_sigma_factor = 1/4;        % standard deviation for the desired scale filter output
        lambda = 1e-4;  %regularization				% regularization weight (denoted "lambda" in the paper)
        interp_factor = 0.02;			% tracking model learning rate (denoted "eta" in the paper)
        nScales = 23;         % number of scale levels (denoted "S" in the paper)
        scale_step = 1.02;               % Scale increment factor (denoted "a" in the paper)
        scale_model_max_area = 1024;      % the maximum size of scale examples
        init_target_sz;
        learning_rate = 0.01; % for scale filter
        % target size att scale = 1
        base_target_sz;
        cell_size = 4;
        scaleFactors;
        % desired scale filter output (gaussian shaped), bandwidth proportional to
        % number of scales
        scale_model_sz;
        scale_window;
        features;
        kernel;
        scale_sigma;
        resize_image;
        target_sz;
        window_sz;
        currentScaleFactor;
        min_scale_factor;
        max_scale_factor;
        output_sigma;
        cos_window;
        model_alphaf;
        model_xf;
        sf_den;
        sf_num;
        yf;
        ysf;
        current_img;
   end
   methods
      function tracker = ICF_tracker(im, target_sz, pos_center, params)
          
        target_sz = [target_sz(2) target_sz(1)];
        pos_center = [pos_center(2) pos_center(1)];  
        tracker.features = params.features;
        tracker.kernel = params.kernel;
        tracker.interp_factor = params.interp_factor;
        tracker.resize_image = (sqrt(prod(target_sz)) >= 100); 
        tracker.learning_rate = params.learning_rate;
        tracker.cell_size = params.cell_size;
        tracker.padding = params.padding;
        tracker.output_sigma_factor = params.output_sigma_factor;
        tracker.scale_sigma_factor = params.scale_sigma_factor;
        tracker.lambda = params.lambda;
        if tracker.resize_image,
            pos_center = floor(pos_center / 2);
            target_sz = floor(target_sz / 2);
        end
        tracker.target_sz = target_sz;
        tracker.window_sz = floor(target_sz * (1 + tracker.padding));
        tracker.init_target_sz = target_sz;

        % target size att scale = 1
        tracker.base_target_sz = target_sz;
        % desired scale filter output (gaussian shaped), bandwidth proportional to
        % number of scales
        tracker.scale_sigma = tracker.nScales/sqrt(33) * tracker.scale_sigma_factor;
        ss = (1:tracker.nScales) - ceil(tracker.nScales/2);
        ys = exp(-0.5 * (ss.^2) / tracker.scale_sigma^2);
        tracker.ysf = single(fft(ys));

        if mod(tracker.nScales,2) == 0
            tracker.scale_window = single(hann(tracker.nScales+1));
            tracker.scale_window = tracker.scale_window(2:end);
        else
            tracker.scale_window = single(hann(tracker.nScales));
        end;
        % scale factors
        ss = 1:tracker.nScales;
        tracker.scaleFactors = tracker.scale_step.^(ceil(tracker.nScales/2) - ss);
        % compute the resize dimensions used for feature extraction in the scale
        % estimation
        scale_model_factor = 1;
        if prod(tracker.init_target_sz) > tracker.scale_model_max_area
            scale_model_factor = sqrt(tracker.scale_model_max_area/prod(tracker.init_target_sz));
        end
        tracker.scale_model_sz = floor(tracker.init_target_sz * scale_model_factor);
        
        
        tracker.currentScaleFactor = 1;
        tracker.min_scale_factor = tracker.scale_step ^ ceil(log(max(5 ./ tracker.window_sz)) / log(tracker.scale_step));
        tracker.max_scale_factor = tracker.scale_step ^ floor(log(min([size(im,1) size(im,2)] ./ tracker.base_target_sz)) / log(tracker.scale_step));
        %create regression labels, gaussian shaped, with a bandwidth
        %proportional to target size
        tracker.output_sigma = sqrt(prod(tracker.target_sz)) * tracker.output_sigma_factor;
        tracker.yf = fft2(st_gaussian_shaped_labels(tracker.output_sigma, tracker.window_sz));

        %store pre-computed cosine window
        tracker.cos_window = hann(size(tracker.yf,1)) * hann(size(tracker.yf,2))';  
        if tracker.resize_image,
          im = imresize(im, 0.5);
        end
        patch = st_get_subwindow(im, pos_center, tracker.window_sz, tracker.currentScaleFactor);
        xf = fft2(st_get_features(patch, tracker.features, tracker.cell_size, tracker.cos_window));
        %calculate response of the classifier at all shifts

        switch tracker.kernel.type
          case 'gaussian',
            kf = st_gaussian_correlation(xf, xf, tracker.kernel.sigma);
          case 'polynomial',
            kf = polynomial_correlation(xf, xf, tracker.kernel.poly_a, tracker.kernel.poly_b);
          case 'linear',
            kf = linear_correlation(xf, xf);
        end
        alphaf = tracker.yf ./ (kf + tracker.lambda);   %equation for fast training
        % extract the training sample feature map for the scale filter
        xs = st_get_scale_sample(im, pos_center, tracker.base_target_sz,...
            tracker.currentScaleFactor * tracker.scaleFactors, tracker.scale_window, tracker.scale_model_sz);

        % calculate the scale filter update
        xsf = fft(xs,[],2);
        new_sf_num = bsxfun(@times, tracker.ysf, conj(xsf));
        new_sf_den = sum(xsf .* conj(xsf), 1);
        tracker.model_alphaf = alphaf;
        tracker.model_xf = xf;
        tracker.sf_den = new_sf_den;
        tracker.sf_num = new_sf_num;
                
      end
      function [box, response, pos_center] = track_frame(self, im, pos_center)
          pos_center = [pos_center(2) pos_center(1)];  
           if self.resize_image,
                im = imresize(im, 0.5);
                pos_center = pos_center * 0.5;
           end
           self.current_img = im;
           patch = st_get_subwindow(im, pos_center, self.window_sz, self.currentScaleFactor);
			zf = fft2(st_get_features(patch, self.features, self.cell_size, self.cos_window));
            switch self.kernel.type
                case 'gaussian',
                    kzf = st_gaussian_correlation(zf, self.model_xf, self.kernel.sigma);
                case 'polynomial',
                    kzf = polynomial_correlation(zf, self.model_xf, self.kernel.poly_a, self.kernel.poly_b);
                case 'linear',
                    kzf = linear_correlation(zf, self.model_xf);
            end
            response = real(ifft2(self.model_alphaf .* kzf));  %equation for fast detection

			%target location is at the maximum response. we must take into
			%account the fact that, if the target doesn't move, the peak
			%will appear at the top-left corner, not at the center (this is
			%discussed in the paper). the responses wrap around cyclically.
            
			[vert_delta, horiz_delta] = find(response == max(response(:)), 1);
			if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
				vert_delta = vert_delta - size(zf,1);
			end
			if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
				horiz_delta = horiz_delta - size(zf,2);
			end
			pos_center = pos_center + round([vert_delta - 1, horiz_delta - 1] * self.currentScaleFactor);
            xs = st_get_scale_sample(im, pos_center, self.base_target_sz,...
                self.currentScaleFactor * self.scaleFactors, self.scale_window, self.scale_model_sz);
            xsf = fft(xs,[],2);
            scale_response = real(ifft(sum(self.sf_num .* xsf, 1) ./ (self.sf_den + self.lambda)));
        
            % find the maximum scale response
            recovered_scale = find(scale_response == max(scale_response(:)), 1);
            % update the scale
            self.currentScaleFactor = self.currentScaleFactor * self.scaleFactors(recovered_scale);
            if self.currentScaleFactor < self.min_scale_factor
                self.currentScaleFactor = self.min_scale_factor;
            elseif self.currentScaleFactor > self.max_scale_factor
                self.currentScaleFactor = self.max_scale_factor;
            end
            self.target_sz = floor(self.base_target_sz * self.currentScaleFactor);
            box = [pos_center([2,1]) - self.target_sz([2,1])/2, self.target_sz([2,1])];
            if self.resize_image,
                box = box * 2;
                pos_center = pos_center * 2;
            end
            pos_center = [pos_center(2) pos_center(1)];
            
      end
      function update_tracker(self, pos_center, rate, target_sz)
           if exist('rate', 'var') 
                  cur_interp_factor = rate;
                  cur_learning_rate = rate;
                  if self.resize_image,
                        target_sz = target_sz * 0.5;
                  end 
                  self.currentScaleFactor = mean(target_sz(end:-1:1) ./ self.base_target_sz);
          else
              cur_interp_factor = self.interp_factor;
              cur_learning_rate = self.learning_rate;
          end
          pos_center = [pos_center(2) pos_center(1)];  
           if self.resize_image,
                pos_center = pos_center * 0.5;
           end
           im = self.current_img;
         %obtain a subwindow for training at newly estimated target position
            patch = st_get_subwindow(im, pos_center, self.window_sz, self.currentScaleFactor);
            xf = fft2(st_get_features(patch, self.features, self.cell_size, self.cos_window));
            switch self.kernel.type
                case 'gaussian',
                    kf = st_gaussian_correlation(xf, xf, self.kernel.sigma);
                case 'polynomial',
                    kf = polynomial_correlation(xf, xf, self.kernel.poly_a, self.kernel.poly_b);
                case 'linear',
                    kf = linear_correlation(xf, xf);
             end
                alphaf = self.yf ./ (kf + self.lambda);   %equation for fast training
                % extract the training sample feature map for the scale filter
                xs = st_get_scale_sample(im, pos_center, self.base_target_sz, ...
                self.currentScaleFactor * self.scaleFactors, self.scale_window, self.scale_model_sz);

                % calculate the scale filter update
                xsf = fft(xs,[],2);
                new_sf_num = bsxfun(@times, self.ysf, conj(xsf));
                new_sf_den = sum(xsf .* conj(xsf), 1);
                self.model_alphaf = (1 - cur_interp_factor) * self.model_alphaf + cur_interp_factor * alphaf;
                self.model_xf = (1 - cur_interp_factor) * self.model_xf + cur_interp_factor * xf;
                self.sf_den = (1 - cur_learning_rate) * self.sf_den + cur_learning_rate * new_sf_den;
                self.sf_num = (1 - cur_learning_rate) * self.sf_num + cur_learning_rate * new_sf_num;
      end
   end % methods
end % classdef