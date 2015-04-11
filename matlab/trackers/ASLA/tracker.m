clear;
vl_setup;
%% parameter setting
setTrackParam;
SC_param.mode = 2;
SC_param.lambda = 0.01;
% SC_param.lambda2 = 0.001; 
SC_param.pos = 'ture';
patch_size = 16;
step_size = 8;
[patch_idx, patch_num] = img2patch(psize, patch_size, step_size); 

duration = 0; tic; % timing

%% initial tracking
result = [];
initial_tracking; 
TemplateDict = normalizeMat(exemplars_stack); 
patch_dict = reshape(TemplateDict(patch_idx,:), patch_size*patch_size, patch_num*EXEMPLAR_NUM); % patch dictionary
patch_dict = normalizeMat(patch_dict);
align_patch_longfeature = reshape(eye(patch_num),patch_num*patch_num,1); 
% sklm variables
tmpl.mean = mean(TemplateDict,2);     
tmpl.basis = [];                                        
tmpl.eigval = [];                                      
tmpl.numsample = 0;                                     
tmpl.warpimg = [];
[tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = sklm(TemplateDict, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample);

%% tracking using proposed method
for f = begin+EXEMPLAR_NUM:frameNum
    if exist([dataPath int2str(begin) '.jpg'],'file')
        imgName = sprintf('%s%d.jpg',dataPath,f);
    elseif exist([dataPath int2str(begin) '.bmp'],'file')
        imgName = sprintf('%s%d.bmp',dataPath,f);
    else 
        imgName = sprintf('%s%05d.jpg',dataPath,f); 
    end
    frame = imread(imgName);
    if size(frame,3)==3
        grayframe = rgb2gray(frame);
    else
        grayframe = frame;
        frame = double(frame)/255; 
    end  
    frame_img = double(grayframe)/255; % 
    % sampling    
    particles_geo = sampling(result(end,:), opt.numsample, opt.affsig);     
    candidates = warpimg(frame_img, affparam2mat(particles_geo), psize); 
    candidates = candidates.*(candidates>0); 
    [candidates,candidates_norm] = normalizeMat(reshape(candidates,psize(1)*psize(2), opt.numsample));
    % cropping patches
    particles_patches = candidates(patch_idx, :);
    particles_patches = reshape(particles_patches,patch_size*patch_size, patch_num*opt.numsample);
    candi_patch_data= normalizeMat(particles_patches); % l2-norm normalization    
    % sparse coding
    patch_coef = mexLasso(candi_patch_data, patch_dict, SC_param); 
    merge_coef = zeros(patch_num, patch_num*opt.numsample);       
    for i=1:EXEMPLAR_NUM
        merge_coef = merge_coef + abs(patch_coef((i-1)*patch_num+1:i*patch_num,:));
    end
    normalized_coef = merge_coef./(repmat(sum(merge_coef,1), patch_num, 1)+eps);
    % alignment-pooling
    patch_longfeatures = reshape(normalized_coef,patch_num*patch_num, opt.numsample);         
    % MAP inference
    sim_measure = sum(align_patch_longfeature'*patch_longfeatures,1) ;  
    conf = sim_measure;
    [sort_conf, sort_idx] = sort(conf,'descend');    
    best_idx = sort_idx(1);
    best_particle_geo = particles_geo(:, best_idx);       
    best_patch_coef = normalized_coef(:,(best_idx-1)*patch_num+1:best_idx*patch_num);
    
%     %% for drawing demo figure
%     observation(f).patch_coef = best_patch_coef(:);
%     observation(f).patch_dict = patch_dict;

    %% template update
    tmpl.warpimg = [tmpl.warpimg,candidates(:,best_idx)];
    if size(tmpl.warpimg,2)==5
        [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = sklm(tmpl.warpimg, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, 1);
        if  (size(tmpl.basis,2) > 10)          
            tmpl.basis  = tmpl.basis(:,1:10);   
            tmpl.eigval = tmpl.eigval(1:10);    
        end
        tmpl.warpimg = [];
        recon_coef = mexLasso((candidates(:,best_idx)-tmpl.mean), [tmpl.basis, eye(size(tmpl.basis,1)) ], SC_param); 
        recon = tmpl.basis*recon_coef(1:size(tmpl.basis,2))+tmpl.mean;
        % replace the template probabilistic
        random_weight = [0,(2).^(1:EXEMPLAR_NUM-1)];
        random_weight = cumsum(random_weight/sum(random_weight));
        random_num = rand(1,1);
        for i=2:EXEMPLAR_NUM-1
            if random_num>=random_weight(i-1)&random_num<random_weight(i)
                break;
            end
        end
        if random_num>=random_weight(EXEMPLAR_NUM-1)
            i = EXEMPLAR_NUM;
        end
        TemplateDict(:,i)=[];
        TemplateDict(:,EXEMPLAR_NUM) = normalizeMat(recon);
        patch_dict = reshape(TemplateDict(patch_idx,:), patch_size*patch_size, patch_num*EXEMPLAR_NUM); % patch dictionary
        patch_dict = normalizeMat(patch_dict);
    end
    
%     %% for displaying patch dictionary
%     aa = figure(5);imshow(uint8(reshape(TemplateDict,psize(2),psize(1)*(EXEMPLAR_NUM))*10*255)); 
%     fileName = sprintf('result/%s/Dict/%s_Dict_%04d.png',title,title,f);
%     imwrite(uint8(reshape(TemplateDict,psize(2),psize(1)*(EXEMPLAR_NUM))*10*255), fileName); 
   
    %% draw result
    result = [result; affparam2mat(best_particle_geo)']; 
    drawopt = drawtrackresult(drawopt, f, frame, psize, result(end,:)'); % 
    imwrite(frame2im(getframe(gcf)),sprintf('result/%s/Result/%04d.png',title,f));   
end

duration = duration + toc;      
fprintf('%d frames took %.3f seconds : %.3fps\n',f,duration,f/duration);
fps = f/duration;

fileName = sprintf('result/%s/Result/result.mat',title);
save(fileName,'result','observation');