% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function dist = distanceDF(dfc1, dfc2)

diff_df = dfc1(:) - dfc2(:); 
dist = sum(sum(sum(abs(diff_df))))./(100*size(dfc1, 1)*size(dfc1, 2));



    
    
    
    
    
    
