% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function df = smoothDF(df, size_kernel, sig_kernel)

%fill in borders with uniform distributions
df_full = ones(size(df,1)+size_kernel(1)-1, size(df,2)+size_kernel(1)-1, size(df,3)).*(1/size(df,3));
st_idx = ceil(size_kernel/2);

df_full(st_idx:st_idx+size(df,1)-1, st_idx:st_idx+size(df,2)-1, :) = df;

h = fspecial('gaussian', size_kernel(1), sig_kernel(1));

% convolve in space 
for i=1:size(df, 3)
    df_full(:,:,i) = conv2(df_full(:,:,i), h, 'same');  
end;

% remove borders
df = df_full(st_idx:st_idx+size(df,1)-1, st_idx:st_idx+size(df,2)-1, :);


% put zeros around the df
df_tmp = zeros(size(df, 1), size(df, 2), size(df, 3)+size_kernel(2)-1);
df_tmp(:, :, ceil(size_kernel(2)/2):ceil(size_kernel(2)/2)+size(df, 3)-1) = df;
df = df_tmp;

%reshape so we can convolve in 1D
init_size = size(df);
df = reshape(df, init_size(1)*init_size(2), size(df, 3))';
df = df(:);

% convolve in 1D
h = fspecial('gaussian', [size_kernel(2) 1], sig_kernel(2));
df = conv(df, h);
df = df(ceil(size_kernel(2)/2):length(df)-floor(size_kernel(2)/2));

%undo the reshaping
df = reshape(df, init_size(3), init_size(1)*init_size(2));
df = df';
df = reshape(df, init_size(1), init_size(2), init_size(3));

% cut the borders without removing weight

new_df = df(:, :, ceil(size_kernel(2)/2):size(df, 3)-floor(size_kernel(2)/2));
sum_new_df = sum(new_df, 3);
sum_df = sum(df, 3);
border_sum = (sum_df - sum_new_df)./size(new_df, 3);
border_sum = repmat(border_sum, [1, 1, size(new_df, 3)]);
new_df = new_df + border_sum;  

df = new_df; 







