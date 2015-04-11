function [R_out, in_range] = IMGaffine_r(R_in, AFNV, OSIZE)
% IMGaffine: affine transform the input image and crop the output image
% with the desired size 
%   OUT = IMGaffine_r_color(IN, AFNV, OUTSIZE)
%   OUT:      output image, M x N 
%   IN:       input image, M_in x N_in
%   AFNV_OBJ.afnv:     affine parameter [a11, a12, a21, a22, tr, tc]
%              or transformation matrix [a11 a12 tr; a21 a22 tc; 0, 0, 1];
%   AFNV_OBJ.size:  output image size
%
% The affine parameter a11 is defined as the relative ratio of IN to OUT 

R = [AFNV(1), AFNV(2), AFNV(5); AFNV(3), AFNV(4), AFNV(6); 0, 0, 1];

[M_in, N_in] = size(R_in);

M = OSIZE(1);
N = OSIZE(2);

P(1,:) = reshape( (1:M)'*ones(1,N), M*N, 1)';
P(2,:) = reshape( ones(M,1)*(1:N), M*N, 1)';
P(3,:) = ones(1, M*N);

Q = round(R*P);
R_out1 = zeros(M*N, 1);

j = find(Q(1,:)>=1 & Q(1,:)<=M_in & Q(2,:)>=1 & Q(2,:)<N_in);
 
if length(j)>0  
  in_range = 1;
  R_out1(j) = R_in((Q(2,j)-1)*M_in+Q(1,j));
  a = mean(R_out1(j));
  R_out1(setdiff(1:M*N, j)) = a;
  R_out = reshape(R_out1, M, N);

else
  in_range = 0;
  R_out = R_out1;
end