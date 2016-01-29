function drawopt = drawtrackresult(drawopt, fno, frame, tmpl, param, pts)
% function drawopt = drawtrackresult(drawopt, fno, frame, tmpl, param, pts)
%
%   drawopt : misc info for drawing, intitially []
%         [.showcoef] : shows coefficient
%         [.showcondens,thcondens] : show condensation candidates
%   fno : frame number
%   frame(fh,fw) : current frame
%   tmpl.mean(th,tw) : mean image
%       .basis(tN,nb) : basis
%   param.est : current estimate
%        .wimg : warped image
%       [.err,mask] : error, mask image
%       [.param,conf] : condensation
%
% uses: util/showimgs

% Copyright (C) 2005 Jongwoo Lim and David Ross.
% All rights reserved.


if (isempty(drawopt))
  figure(1); clf;
  set(gcf,'DoubleBuffer','on','MenuBar','none');
  colormap('gray');
  drawopt.curaxis = [];
  [fh,fw] = size(frame);  [th,tw] = size(tmpl.mean);
  hb = th / (fh/fw*(5*tw) + 3*th);
%   drawopt.curaxis.frm  = axes('position', [0.00 0.00 1.00 1.00]);
%
  drawopt.curaxis.frm  = axes('position', [0.00 3*hb 1.00 1-3*hb]);
  drawopt.curaxis.window = axes('position', [0.00 2*hb 1.00 hb]);
  drawopt.curaxis.basis = axes('position', [0.00 0.00 1.00 2*hb]);
  drawopt.showcoef = 0;  drawopt.magcoef = 3;
  drawopt.showcondens = 0;  drawopt.thcondens = 0.001;
end

sz = size(tmpl.mean);  w = sz(2);  h = sz(1);  N = w*h;
nb = size(tmpl.basis,2);  nbir = 4;  %% numbasis to show, numbasis in a row
ns = 10;  nbir = 5;  nb = min(nb, ns);  %% for figures

curaxis = drawopt.curaxis;

% main frame window
axes(curaxis.frm);
imagesc(frame, [0,1]); hold on;
if (drawopt.showcondens && isfield(param,'param') && isfield(param,'conf'))
  p = affparam2mat(param.param(:,find(param.conf > drawopt.thcondens)));
  for i = 1:size(p,2)
    drawbox(sz, p(:,i), 'Color','g');
  end
end
if (exist('pts'))
  if (size(pts,3) > 1)  plot(pts(1,:,2),pts(2,:,2),'yx','MarkerSize',10);  end;
  if (size(pts,3) > 2)  plot(pts(1,:,3),pts(2,:,3),'rx','MarkerSize',10);  end;
end
text(5, 18, num2str(fno), 'Color','y', 'FontWeight','bold', 'FontSize',18);
drawbox(sz, param.est, 'Color','r', 'LineWidth',2.5);
axis equal tight off; hold off;

if (isfield(curaxis,'basis'))
  axes(curaxis.basis);
  mag = drawopt.magcoef;
  if (drawopt.showcoef && nb > 0)
    basisimg = reshape(tmpl.basis(:,1:nb), [sz,nb]);
    basisimg(:,w+1,:) = zeros(h,1,nb);
    ipos = find(coef > 0);  ineg = find(coef < 0);
    for i = 1:length(ipos)
      basisimg(h+1-(1:min(h,ceil(mag*coef(ipos(i))))),w+1,ipos(i)) = 1;
    end
    for i = 1:length(ineg)
      basisimg(h+1-(1:min(h,ceil(-mag*coef(ineg(i))))),w+1,ineg(i)) = -1;
    end
    showimgs(zscore(basisimg),[nbir, -mag,mag]);
  else
    if (nb > 0)
      basisimg = cat(2, zscore(tmpl.basis(:,1:nb)), zeros(N,ns-nb));
    else
      basisimg = zeros(N,ns);
    end
    showimgs(reshape(basisimg, [sz,ns]), [nbir,-mag,mag]);
  end
  axis equal tight off;
  %    text(5,-3, 'basis');
end

if (isfield(curaxis, 'window'))
  axes(curaxis.window);
  %    showimgs(cat(3, tmpl.mean, tmpl.window, recon, abs(diff)*2),[4,0,1]);
  imgdisp = tmpl.mean;  str = 'mean';
  if (isfield(param,'wimg'))
    imgdisp = cat(3, imgdisp, param.wimg);  str = [str ', patch'];
  end
  if (isfield(param,'err'))
    imgdisp = cat(3, imgdisp, abs(param.err)*2);  str = [str, 'err'];
  end
  if (isfield(param, 'recon'))
    imgdisp = cat(3, imgdisp, param.recon);  str = [str ', recon'];
  end
  showimgs(imgdisp ,[size(imgdisp,3),0,1]);
  if (exist('pts') & ~isempty(pts))
    hold on; plot(pts(1,:,1)+w,pts(2,:,1),'yx'); hold off;
  end
  axis equal tight off;
  %    text(5,-4, str);
end

if (isfield(curaxis, 'graph') && isfield(param,'err') && fno > 0)
  axes(curaxis.graph);
  plot(param.err);
%  drawopt.sumsqerr(fno) = mean(param.err(:).^2);
%  plot(drawopt.sumsqerr);
end
drawnow;
