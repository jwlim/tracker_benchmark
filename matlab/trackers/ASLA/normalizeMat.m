function [A, A_norm] = normalizeMat(A)
A_norm = sqrt(sum(A.*A));
A = A./(ones(size(A,1),1)*A_norm+eps);