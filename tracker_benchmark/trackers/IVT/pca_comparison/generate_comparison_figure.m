% Generate the figure comparing the different algorithms
% This script assumes that run_comparison has already been run on the
% sylvester_windows.mat dataset.
%
% Author: David Ross, rewritten May 2007.
% $Id: generate_comparison_figure.m,v 1.2 2008-05-05 03:40:45 dross Exp $

to_plot = [23, 72, 97, 103, 143, 169, 189, 205, 220, 236, 264, 276, 355, 388, 399, 522, 524, 561, 581, 597];
o = ones(1,NUM_DATA);
recon_pca =  reshape(pca_basis*(pca_basis'*(data-mean(data,2)*o))+mean(data,2)*o, [sqrt(D) sqrt(D) NUM_DATA]);
recon_hall =  reshape(U_hall*(U_hall'*(data-mu_hall*o))+mu_hall*o, [sqrt(D) sqrt(D) NUM_DATA]);
recon_ivt =  reshape(U*(U'*(data-mu*o))+mu*o, [sqrt(D) sqrt(D) NUM_DATA]);
original = reshape(data, [sqrt(D) sqrt(D) NUM_DATA]);

whole_image = cat(1, original(:,:,to_plot), ...
    recon_pca(:,:,to_plot), original(:,:,to_plot) - recon_pca(:,:,to_plot), ...
    recon_ivt(:,:,to_plot), original(:,:,to_plot) - recon_ivt(:,:,to_plot));
whole_image = whole_image(:,:);

axes('position', [0 0 1 1]);
imagesc(whole_image,[0 1]);
colormap gray
axis equal tight off

num_rows = size(whole_image,1);
for ii = 1:numel(to_plot)
    text((ii-1)*size(original,2)+2,num_rows-6,num2str(to_plot(ii)), 'Color', 'y', ...
        'FontSize', 18, 'FontWeight', 'bold');
end
    


