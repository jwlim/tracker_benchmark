function show_precision(positions, ground_truth, title)
%SHOW_PRECISION
%   Calculates precision for a series of distance thresholds (percentage of
%   frames where the distance to the ground truth is within the threshold).
%   The results are shown in a new figure.
%
%   Accepts positions and ground truth as Nx2 matrices (for N frames), and
%   a title string.
%
%   João F. Henriques, 2012
%   http://www.isr.uc.pt/~henriques/

	
	max_threshold = 50;  %used for graphs in the paper
	
	
	if size(positions,1) ~= size(ground_truth,1),
		disp('Could not plot precisions, because the number of ground')
		disp('truth frames does not match the number of tracked frames.')
		return
	end
	
	%calculate distances to ground truth over all frames
	distances = sqrt((positions(:,1) - ground_truth(:,1)).^2 + ...
				 	 (positions(:,2) - ground_truth(:,2)).^2);
	distances(isnan(distances)) = [];

	%compute precisions
	precisions = zeros(max_threshold, 1);
	for p = 1:max_threshold,
		precisions(p) = nnz(distances < p) / numel(distances);
	end
	
	%plot the precisions
	figure('Number','off', 'Name',['Precisions - ' title])
	plot(precisions, 'k-', 'LineWidth',2)
	xlabel('Threshold'), ylabel('Precision')

end

