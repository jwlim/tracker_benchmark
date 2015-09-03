function drawResultRect(seqs, trks, pathAnno, pathRes, pathDraw)

pathDraw = [pathDraw 'imgsRect/'];

LineWidth = 2;
LineStyle = '-';%':';%':' '.-'

lenTotalSeq = 0;
rectMat=[];
rectMatAll=[];
for index_seq=1:length(seqs)
    seq = seqs{index_seq};
    seq_name = seq.name
    
%     fileName = [pathAnno seq_name '.txt'];
%     rect_anno = dlmread(fileName);
    seq_length = seq.endFrame-seq.startFrame+1; %size(rect_anno,1);
    lenTotalSeq = lenTotalSeq + seq_length;
    
    for index_algrm=1:length(trks)
        algrm = trks{index_algrm};
        name=algrm.name;
        
%         res_path = [pathRes seq_name '_' name '/'];
        
        fileName = [pathRes seq_name '_' name '.mat'];
    
        load(fileName);
        rectMat = zeros(seq_length, 4);
        
        switch results.type
            case 'rect'                
                rectMat = results.res;
            case 'ivtAff'
                for i = 1:seq_length
                    [rect c] = calcRectCenter(results.tmplsize, results.res(i,:), 'Color', [1 1 1], 'LineWidth', LineWidth,'LineStyle',LineStyle);
                    rectMat(i,:) = rect;
                    %                     center(i,:) = c;
                end
            case 'L1Aff'
                for i = 1:seq_length
                    [rect c] = calcCenter_L1(results.res(i,:), results.tmplsize);
                    rectMat(i,:) = rect;
                end
            case 'LK_Aff'
                for i = 1:seq_length
                    [corner c] = getLKcorner(results.res(2*i-1:2*i,:), results.tmplsize);
                    rectMat(i,:) = corner2rect(corner);
                end
            case '4corner'
                for i = 1:seq_length
                     rectMat(i,:) = corner2rect(results.res(2*i-1:2*i,:));
                end
            otherwise
                continue;
        end 
        rectMatAll(:,:,index_algrm) = rectMat;
    end
        
    nz	= strcat('%0',num2str(seq.nz),'d'); %number of zeros in the name of image
    
    pathSave = [pathDraw seq_name '/'];
    if ~exist(pathSave,'dir')
        mkdir(pathSave);
    end
    
    for i=1:seq_length
        image_no = seq.startFrame + (i-1);
        id = sprintf(nz,image_no);
        fileName = strcat(seq.path,id,'.',seq.ext);
        
        img = imread(fileName);
        
        imshow(img);
        
        for j=1:length(trks)
            r = rectMatAll(i, :, j);
            color = trks{j}.color;
            
            rectangle('Position', r, 'EdgeColor', color, 'LineWidth', 4);
            
            imwrite(frame2im(getframe(gcf)), [pathSave  num2str(i) '.png']);   
        end
    end
end
