%IM2COLSTEP Rearrange matrix blocks into columns.
%  B = IM2COLSTEP(A,[N1 N2]) converts each sliding N1-by-N2 block of the
%  2-D matrix A into a column of B, with no zero padding. B has N1*N2 rows
%  and will contain as many columns as there are N1-by-N2 neighborhoods in
%  A. Each column of B contains a neighborhood of A reshaped as NHOOD(:),
%  where NHOOD is a matrix containing an N1-by-N2 neighborhood of A.
%
%  B = IM2COLSTEP(A,[N1 N2],[S1 S2]) extracts neighborhoods of A with a
%  step size of (S1,S2) between them. The first extracted neighborhood is
%  A(1:N1,1:N2), and the rest are of the form A((1:N1)+i*S1,(1:N2)+j*S2).
%  Note that to ensure coverage of all A by neighborhoods,
%  (size(A,i)-Ni)/Si must be whole for i=1,2. The default function behavior
%  corresponds to [S1 S2] = [1 1]. Setting S1>=N1 and S2>=N2 results in no
%  overlap between the neighborhoods.
%
%  B = IM2COLSTEP(A,[N1 N2 N3],[S1 S2 S3]) operates on a 3-D matrix A. The
%  step size [S1 S2 S3] may be ommitted, and defaults to [1 1 1].
%
%  Note: the call IM2COLSTEP(A,[N1 N2]) produces the same output as
%  Matlab's IM2COL(A,[N1 N2],'sliding'). However, it is significantly
%  faster.
%
%  See also COL2IMSTEP, IM2COL, COUNTCOVER.


%  Ron Rubinstein
%  Computer Science Department
%  Technion, Haifa 32000 Israel
%  ronrubin@cs
%
%  August 2009
