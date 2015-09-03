function [aveErrCoverageAll aveErrCenterAll] = calcPlotErr(seqs, trks, pathAnno, pathRes, pathPlot, bPlot)

LineWidth = 2;
LineStyle = '-';%':';%':' '.-'
% Curvature = [0,0];

% path_anno = '.\anno\';
lostCount = zeros(length(seqs), length(trks));
thred = 0.33;
% lostRate = zeros(length(seqs), length(trks));
% lostRateEachAlg = zeros(1, length(trks));
errCenterAll=[];
errCoverageAll=[];

lenTotalSeq = 0;
rectMat=[];
for index_seq=1:length(seqs)
    seq = seqs{index_seq};
    seq_name = seq.name
    
    fileName = [pathAnno seq_name '.txt'];
    rect_anno = dlmread(fileName);
    seq_length = seq.endFrame-seq.startFrame+1; %size(rect_anno,1);
    lenTotalSeq = lenTotalSeq + seq_length;
    
    centerGT = [rect_anno(:,1)+(rect_anno(:,3)-1)/2 rect_anno(:,2)+(rect_anno(:,4)-1)/2];
    
    %     rect=[];
%     indexLost = zeros(length(trks), seq_length);
%     if bPlot
%         clf
%     end
    
    for index_algrm=1:length(trks)
        algrm = trks{index_algrm};
        name=algrm.name;
        
        trackerNames{index_algrm}=name;
        
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
 
        center = [rectMat(:,1)+(rectMat(:,3)-1)/2 rectMat(:,2)+(rectMat(:,4)-1)/2];
        
        errCenter(:,index_algrm) = sqrt(sum(((center(1:seq_length,:) - centerGT(1:seq_length,:)).^2),2));
        
        err(:,index_algrm) = calcRectInt(rectMat(1:seq_length,:),rect_anno(1:seq_length,:));
        
        if bPlot            
            h1=figure(1);
            plot(err(:,index_algrm),'color', trks{index_algrm}.color,'LineWidth',LineWidth,'LineStyle',LineStyle);
            hold on 
            
            h2=figure(2);
            plot(errCenter(:,index_algrm),'color', trks{index_algrm}.color,'LineWidth',LineWidth,'LineStyle',LineStyle);
            hold on 
        end
    end
    
    if bPlot
        figure(1);
        axis tight
        set(gca,'fontsize',20);
        
        xlabel(h1,'string', ['# ' seqs{index_seq}.name],'FontSize',20)
        ylabel(h1,'string','Coverage/quality','FontSize',20)        
%         legend(trackerNames,'Orientation','horizontal','Position', [0.20 0.004 0.59 0.05]);
%         legend(trackerNames,'Position', 'Best');
        
        print(h1, '-depsc', [pathPlot seq_name '_coverage']);
        imwrite(frame2im(getframe(h1)), [pathPlot seq_name '_coverage.png']);
               
        figure(2);
        axis tight;
        set(gca,'fontsize',20);

        xlabel(h2,'string',['# ' seqs{index_seq}.name],'FontSize',20)
        ylabel(h2,'string','Center error','FontSize',20)
%         legend(trackerNames,'Position', 'Best');
        
        print(h2, '-depsc', [pathPlot seq_name '_center']);
        imwrite(frame2im(getframe(h2)), [pathPlot seq_name '_center.png']);
        
        clf(h1);
        clf(h2);
    end
    
    aveErrCoverage(index_seq,:) = sum(err)/seq_length;
    errCoverageAll(index_seq,:) = sum(err);
    
    aveErrCenter(index_seq,:) = sum(errCenter)/seq_length;
    errCenterAll(index_seq,:) = sum(errCenter);
    
    lostCount(index_seq,:)=sum(err<thred);
    
    err = [];
end

aveErrCoverageAll=sum(errCoverageAll)/lenTotalSeq

aveErrCenterAll=sum(errCenterAll)/lenTotalSeq

save(['./errAnalysis.mat'], 'aveErrCoverage', 'aveErrCenter', 'aveErrCoverageAll', 'aveErrCenterAll', 'lostCount', 'thred');
% lostRateEachAlg=sum(lostCount)/lenTotalSeq
% lostCount
% sum(lostCount)