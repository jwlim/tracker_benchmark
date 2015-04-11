function [gly_crop, gly_inrange] = Seg_gly_crop(img_frame, curr_samples, template_size);
%create gly_crop, gly_inrange

nsamples = size(curr_samples,1);
for n = 1:nsamples
   %if mod(n,50)==0 fprintf('-'); end
   curr_afnv = curr_samples(n, :);
   [img_cut, gly_inrange(n)] = IMGaffine_r(img_frame, curr_afnv, template_size);
   gly_crop(:,n) = reshape(img_cut, prod(template_size), 1);
end