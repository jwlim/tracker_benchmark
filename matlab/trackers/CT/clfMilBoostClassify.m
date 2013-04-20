function prob = clfMilBoostClassify(r,selector)

prob = sum(r(selector,:),1);
% prob = prob/sum(prob);% the result is the same as prob.