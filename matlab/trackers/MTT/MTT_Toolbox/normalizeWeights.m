function W = normalizeWeights(W, s)
% W = W/sum(W)*s;
% big = find(W>0.3);
% small = setdiff(1:length(W),big);
% W(big) = 0.3;
% m = 1-sum(W(big));
% W(small) = W(small)/sum(W(small))*m*s;

W = W/sum(W);
while (max(W)>0.3)
    big = find(W>0.3);
    W(big) = 0.3;
    W = W/sum(W);
end
W = W*s;
