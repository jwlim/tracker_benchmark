function [aveErrCoverage, aveErrCenter,errCoverage, errCenter] = calcSeqErr(results, rect_anno)

% LineWidth = 2;
% LineStyle = '-';%':';%':' '.-'

% lostCount = zeros(length(seqs), length(trks));
% thred = 0.33;
% 
% errCenterAll=[];
% errCoverageAll=[];

seq_length = results.len;

if strcmp(results.type,'rect')
    for i = 2:seq_length
        r = results.res(i,:);
        
        if isnan(r) | r(3)<=0 | r(4)<=0
            results.res(i,:)=results.res(i-1,:);
        end
    end
end

% lenTotalSeq = lenTotalSeq + seq_length;

centerGT = [rect_anno(:,1)+(rect_anno(:,3)-1)/2 rect_anno(:,2)+(rect_anno(:,4)-1)/2];

rectMat = zeros(seq_length, 4);
switch results.type
    case 'rect'
        rectMat = results.res;
    case 'ivtAff'
        for i = 1:seq_length
            [rect c] = calcRectCenter(results.tmplsize, results.res(i,:));
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
end

center = [rectMat(:,1)+(rectMat(:,3)-1)/2 rectMat(:,2)+(rectMat(:,4)-1)/2];

errCenter = sqrt(sum(((center(1:seq_length,:) - centerGT(1:seq_length,:)).^2),2));

errCoverage = calcRectInt(rectMat(1:seq_length,:),rect_anno(1:seq_length,:));

aveErrCoverage = sum(errCoverage)/seq_length;

aveErrCenter = sum(errCenter)/seq_length;


