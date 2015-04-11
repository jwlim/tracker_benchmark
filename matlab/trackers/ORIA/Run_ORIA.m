
function results = Run_ORIA(imgfilepath_fmt, img_range_str, init_rect, opt)

%- Platform check.
if nargin < 1
  switch computer('arch')
    case {'win32', 'win64', 'glnx86', 'glnx64', 'maci64'}
      results = {};  %- Supported platforms. Do nothing.
    case {}
      error(['Unsupported planform - ' computer('arch') '.']);
    otherwise
      error(['Unknown planform - ' computer('arch') '.']);
  end
  return;
end

if nargin < 4, opt = struct('dumppath_fmt','-', 'tracker_path','./'); end;

img_range = eval(img_range_str);
num_frames = numel(img_range);
% function results=run_ORIA(seq, res_path, bSaveImage)
show_result = ~isempty(opt.dumppath_fmt);

% addpath
addpath([opt.tracker_dir 'RASL_toolbox']);

para = paraConfig('');

r = init_rect;
imgSize = [r(4) r(3)];
while imgSize(1) * imgSize(2) > 6000
    imgSize = round(imgSize/2);
end
para.canonicalImageSize = imgSize;
para.canonicalPts = [1, imgSize(2); ...
                     1, 1];

imgSize = para.canonicalImageSize;
fr = [1, 1, imgSize(2), imgSize(2), 1; ...
      1, imgSize(1), imgSize(1), 1, 1; ...
      1, 1, 1, 1, 1];

% if ~exist(paraSeq.destDir,'dir')
%     mkdir(paraSeq.destDir) ;
% end

% initRect=dlmread(initFile);

% nz = strcat('%0',num2str(paraSeq.numZ),'d'); %number of zeros in the name of image
% id = sprintf(nz, paraSeq.beginFrame);
% beginImgFile = [paraSeq.filepath, id, '.', paraSeq.ext];

% Get training images

img = double(imread(sprintf(imgfilepath_fmt, img_range(1))));
if size(img,3) > 1,   
    img = img(:,:,2);            
end

numBasis=para.numBasis;

[A init_T]= init(img, init_rect', numBasis, para.canonicalImageSize, para.canonicalPts, para.transformType, para.preprocessType);

% basis=genBasis(I0,xi{1},num_basis,imgSize,raslpara.transformType,raslpara.preprocessType);

Tfm = fliptform(maketform('projective',inv([init_T;0 0 1]')));
curFrame = tformfwd(fr(1:2,:)', Tfm )';

init_xi = projective_matrix_to_parameters( para.transformType, init_T);

res_struct = struct('type', lower(para.transformType), 'tmplsize', imgSize, ...
  'res', init_xi);

if ~isempty(opt.dumppath_fmt)
  PlotResultRect(img, img_range(1), res_struct, opt.dumppath_fmt);
end

% if show_result
%     figure(gcf);
%     imshow(uint8(img));
%     hold on
%     plot(curFrame(1,:), curFrame(2,:), 'r-', 'LineWidth', 2 );
%     hold off;
%     if opt.dumppath_fmt ~= '-'
%         imwrite(frame2im(getframe(gcf)), ...
%             sprintf(opt.dumppath_fmt, img_range(t)));
%     end
% end
        
xi_all=zeros(size(init_xi,1), num_frames);
xi_all(:,1) = init_xi;

init_xi_begin = init_xi;

timeTotal = 0;

index=1;

indexUpdate = 1;

for inum = 2 : num_frames
    
%     disp(num2str(inum));
%     
%     if inum == 172
%         inum = 172;
%     end
    
    index=index+1;

    currentImage = double(imread(sprintf(imgfilepath_fmt, img_range(inum))));
    
    if size(currentImage,3) > 1,   
        currentImage = currentImage(:,:,2);            
    end
    
    tic
    
    [d, Do, a, e, xi, numIterOuter, numIterInner ] = oria(currentImage,A,init_xi, para);
    
    if isempty(xi)
        xi=init_xi_begin;
    else
%         if ~mod(inum,3)
%             indexUpdate = indexUpdate + 1;
%             A=updateTemplates(A, Do, indexUpdate);            
%         end

        A=updateTemplates(A, Do, e, index);
    end
    
    
    timeTotal = timeTotal+toc;
%     d_all=[d_all,d];
%     Do_all=[Do_all,Do];
%     a_all=[a_all,a];
%     e_all=[e_all,e];
    xi_all(:,index) = xi;
    
%     disp(['#' num2str(inum) ' ||E||_0 ' num2str(length(find(abs(e)>0))) ' ||E||_1 ' num2str(norm(e,1))]);
    %     [d, Do, a, e, xi, numIterOuter, numIterInner ] = rasl_scale_online(currentImage,A,init_xi, para, destDir);
    
    init_xi = xi;
%     tracking_res=[tracking_res xi];
%     save('tracking_res.mat','tracking_res')   
    
    if ~isempty(opt.dumppath_fmt)
        res_struct.res = xi;
        PlotResultRect(currentImage, img_range(inum), res_struct, opt.dumppath_fmt);
    end
%     if show_result
%         figure(gcf);
%         imshow(uint8(currentImage));
%         hold on;
%         T_in = parameters_to_projective_matrix(para.transformType,xi);
%         Tfm = fliptform(maketform('projective',inv(T_in')));
%         curFrame = tformfwd(fr(1:2,:)', Tfm )';
%         plot( curFrame(1,:), curFrame(2,:), 'r-', 'LineWidth', 2 );
%         text(10, 15, ['#' num2str(inum)], 'Color','y', 'FontWeight','bold', 'FontSize',24);
%         hold off;
%         drawnow;
%         if opt.dumppath_fmt ~= '-'
%             imwrite(frame2im(getframe(gcf)), ...
%                 sprintf(opt.dumppath_fmt, img_range(t)));
%         end
%     end
end

rmpath([opt.tracker_dir 'RASL_toolbox']);

results.res = xi_all';
results.type = lower(para.transformType);
results.tmplsize = para.canonicalImageSize;
results.fps = (num_frames - 1) / timeTotal;

fprintf('%d frames in %.3f seconds : %.3ffps\n', num_frames, timeTotal, results.fps);

end
