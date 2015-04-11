function [result, exemplars_stack, drawopt]=initial_tracking(seq, param0,psize,EXEMPLAR_NUM,opt, res_path, bSaveImage)
% simple tracking and collecting tracking results as templates
exemplars_stack = [];
result = [];
drawopt=[];
% begin = seq.startFrame;
%% read first frame

frame = imread(seq.s_frames{1});

if size(frame,3)==3
    grayframe = rgb2gray(frame);
else
    grayframe = frame;
    frame = double(frame)/255; 
end
frame_img = double(grayframe)/255; 
result = [result; param0']; % each estimation is a row vector
exemplar = warpimg(frame_img, param0, psize);  
exemplar = exemplar.*(exemplar>0); 
exemplars_stack = [exemplars_stack, exemplar(:)]; % collect exemplars£» notice that these are not normalized using L2 norm
% draw result
if bSaveImage
    drawopt = drawtrackresult([], 1, frame, psize, result(end,:)'); 
    imwrite(frame2im(getframe(gcf)),sprintf('%s%04d.jpg',res_path, 1));
end

% imwrite(frame2im(getframe(gcf)),sprintf('result/%s/Result/%04d.fig',title,begin));
% imwrite(frame2im(getframe(gcf)),sprintf('result/%s/Result/%04d.png',title,begin));


%% simple tracking
for f = 2 : EXEMPLAR_NUM

    frame = imread(seq.s_frames{f});
    
    if size(frame,3)==3
        grayframe = rgb2gray(frame);
    else
        grayframe = frame;
        frame = double(frame)/255; 
    end  
    frame_img = double(grayframe)/255; 
    
    particles_geo = sampling(result(end,:), opt.numsample, opt.affsig); 
    candidates = warpimg(frame_img, affparam2mat(particles_geo), psize);
    candi_data = reshape(candidates, psize(1)*psize(2), opt.numsample); 
    candi_data = candi_data.*(candi_data>0);  
    
    % use knn function of the vlfeat open source library
    candidate_kdTree = vl_kdtreebuild(candi_data);   
    [idx, distances] = vl_kdtreequery( candidate_kdTree, candi_data, exemplars_stack(:,end), 'NumNeighbors', 1) ;        
    
    result = [result; affparam2mat(particles_geo(:,idx))']; 
    exemplars_stack = [exemplars_stack, candi_data(:,idx)]; 
    if bSaveImage    
        % draw result
        drawopt = drawtrackresult(drawopt, f, frame, psize, result(end,:)'); % 
        imwrite(frame2im(getframe(gcf)),sprintf('%s%04d.jpg',res_path,f));
    end
end

