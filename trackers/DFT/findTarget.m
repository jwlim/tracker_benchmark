% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************


function pt = findTarget(df1, df2, pt, wsize)
% Compute the flow of a patch

% Use a map of the distances to avoid repeated calculations 
map = -1*ones(size(df2, 1), size(df2, 2));

% compute starting distance 
start_dist = distanceDF(df1, df2(pt(1):pt(1)+wsize(1)-1, pt(2):pt(2)+wsize(2)-1, :));
map(pt(1), pt(2)) = start_dist;
min_dist = start_dist;
min_dist_idx = 0;

stop = 0;
shifts = [-1, 0; 0, 1; 1 0; 0 -1];

while ~stop
    
    % check the 4 neighbors
    for i=1:size(shifts, 1)
        
        dx = pt(1)+shifts(i, 1);
        dy = pt(2)+shifts(i, 2);
        
        try  
            % Compute distance if it hasn't been computed yet
            if map(dx, dy) == -1
                cur_dist = distanceDF(df1, df2(dx:dx+wsize(1)-1, dy:dy+wsize(2)-1, :));
                map(dx, dy) = min_dist;
            else
                cur_dist = map(dx, dy);
            end;

            % Update best displacement if necessary
            if cur_dist < min_dist
                min_dist = cur_dist; 
                min_dist_idx = i;
            end;
            
        catch    
        end;      
            
    end;
    
    % move if it's better than the current position and doesn't exceed dimensions
    if min_dist_idx ~= 0 && min_dist < start_dist && ~isBorderPixel(size(df2), pt+shifts(min_dist_idx, :), wsize) 
        pt = pt + shifts(min_dist_idx, :);
        start_dist = min_dist;
    else
        stop = 1;
    end;

end;

        
        
