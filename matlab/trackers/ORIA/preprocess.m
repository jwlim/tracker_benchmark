function data=preprocess(data,type)

[dim num] = size(data);

switch type
    case 'norm',
        for i =1:num
            data(:,i)=data(:,i)/(norm(data(:,i))+eps);
        end
    case 'gauss'
        for n =1:num
            a = mean(data(:,n));
            b = std(data(:,n));
            data(:,n) = (data(:,n) - ones(dim,1)*a) ./ (ones(dim,1)*b);
            data(:,n) = data(:,n)/norm(data(:,n));
        end
    case 'contrast'
        minval = min(data);
        maxval = max(data);
        data = (data - ones(dim,1)*minval)./ (ones(dim,1)*maxval);        
        for i =1:num
            data(:,i)=data(:,i)/norm(data(:,i));
        end      
end