function [err,afferr,recon,diff] = esterrfunc(p, frm, tmpl, opt)
% function [err,afferr,recon,diff] = esterrfunc(p, frm, tmpl, opt)
%

%% Copyright (C) Jongwoo Lim and David Ross.
%% All rights reserved.

recon = [];
if isstruct(tmpl)
  diff = tmpl.mean - warpimg(frm, p, size(tmpl.mean));
  if (size(tmpl.basis,2) > 0)
    recon = tmpl.basis*(tmpl.basis'*diff(:));
    diff(:) = diff(:) + recon;
    recon = reshape(recon,size(tmpl.mean)) + tmpl.mean;
  else
    recon = tmpl.mean;
  end
else
  diff = tmpl - warpimg(frm, p, size(tmpl));
end
if (nargin < 4)
  opt = [];
end

if (isfield(opt,'errfunc') && isfield(opt,'rsig') && strcmp(opt.errfunc,'robust'))
  sqdiff = diff.^2;
%% need to estimate coef corectly
  err = sum(sqdiff(:) ./ (sqdiff(:) + opt.rsig.^2));
else
  err = sum(diff(:).^2);
end
if (isfield(opt,'affsig') && isfield(opt,'param0'))
  afferr = sum(((affparam2geom(p)-opt.param0)./opt.affsig).^2);
  if (isfield(opt,'affsigcoef'))
    afferr = afferr * opt.affsigcoef;
  end
  err = err + afferr;
end
