function a = images_angle(I1, I2)

if (sum(I1-I2)<eps)%by yi wu 09/26/2012
    a=1;
else
    I1v = double(I1(:));
    I2v = double(I2(:));
    I1vn = I1v./sqrt(sum(I1v.^2)+eps);%by yi wu 09/26/2012
    I2vn = I2v./sqrt(sum(I2v.^2)+eps);%by yi wu 09/26/2012
    a = acosd(I1vn'*I2vn);
end