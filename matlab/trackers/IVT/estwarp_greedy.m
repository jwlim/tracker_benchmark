function param = estwarp_greedy(frm, tmpl, param, opt)
% function param = estwarp_greedy(frm, tmpl, param, opt)
%

%% Copyright (C) Jongwoo Lim and David Ross.
%% All rights reserved.


n = opt.numsample;
sz = size(tmpl.mean);
N = sz(1)*sz(2);

if ~isfield(param,'param')
  param.param = repmat(affparam2geom(param.est(:)), [1,n]);
% else
%   cumconf = cumsum(param.conf);
%   idx = floor(sum(repmat(rand(1,n),[n,1]) > repmat(cumconf,[1,n])))+1;
%   param.param = param.param(:,idx);
end
param.param = param.param + randn(6,n).*repmat(opt.affsig(:),[1,n]);
wimgs = warpimg(frm, affparam2mat(param.param), sz);
diff = repmat(tmpl.mean(:),[1,n]) - reshape(wimgs,[N,n]);
if (size(tmpl.basis,2) > 0)
  diff = diff - tmpl.basis*(tmpl.basis'*diff);
end
if (isfield(opt,'errfunc') && strcmp(opt.errfunc,'robust'))
  param.conf = exp(-sum(diff.^2./(diff.^2+opt.rsig.^2))./opt.condenssig)';
else
  param.conf = exp(-sum(diff.^2)./opt.condenssig)';
end
param.conf = param.conf ./ sum(param.conf);
[maxprob,maxidx] = max(param.conf);
param.est = affparam2mat(param.param(:,maxidx));
param.param = repmat(param.param(:,maxidx),[1,n]);
param.wimg = wimgs(:,:,maxidx);
param.err = reshape(diff(:,maxidx), sz);
param.recon = param.wimg + param.err;
