from config import *
from scripts import *
import scripts.butil

def calc_result(tracker, seqs, results, evalType):

    seqResultList = dict((s.name,list()) for s in seqs)
    for i in range(len(results)):
        subResults = results[i]

        seq = next(seq for seq in seqs if seq.name.lower() == subResults[0].seqName.lower())
        seq.aveCoverage = []
        seq.aveErrCenter = []
        seq.errCoverage = []
        seq.errCenter = []

        if evalType == 'SRE':
            idxNum = len(subResults)
            anno = seq.gtRect
        elif evalType == 'TRE':
            idxNum = len(subResults)
        elif evalType == 'OPE':
            idxNum = 1
            anno = seq.gtRect

        for j in range(idxNum):
            result = subResults[j]
            if evalType == 'TRE':
                if len(seq.gtRect) < result.endFrame:
                    anno = seq.gtRect[result.startFrame-seq.startFrame:
                        result.endFrame-seq.startFrame+1]
                else:
                    anno = seq.gtRect[result.startFrame-1:
                        result.endFrame]

            print '{0} : eval {1}'.format(tracker, seq.name)
            aveCoverage, aveErrCenter, errCoverage, errCenter = \
                scripts.butil.calc_seq_err_robust(result, anno)
            seq.aveCoverage.append(aveCoverage)
            seq.aveErrCenter.append(aveErrCenter)
            seq.errCoverage += errCoverage
            seq.errCenter += errCenter

            
            seqName = seq.name
            seqResultList[seqName].append(result)
        #end for j
    # end for i

    attrList = getScoreList()
    allAttr = Score('ALL', 'All attributes', tracker, evalType)
    allSuccessRateList = []
    attrList.append(allAttr)
    for attr in attrList:
        successRateList = []
        attr.tracker = tracker
        attr.evalType = evalType
        attr.seqs = []
        attr.successRateList = []
        attr.precisionList = []
        attr.overlapScores = []
        attr.errorNum = []
        for seq in seqs:
            if attr.name in seq.attributes or attr.name.lower() == 'all':
                attr.seqs.append(seq.name)
                seqSuccessList = []
                length = len(seq.errCoverage)
                for threshold in thresholdSetOverlap:
                    seqSuccess = [score for score in seq.errCoverage \
                        if score > threshold]
                    seqSuccessList.append(len(seqSuccess)/float(length))
                successRateList.append(seqSuccessList)

                overlapList = [score for score in seq.errCoverage 
                    if score > 0]
                overlapScore = sum(overlapList) / len(overlapList)
                attr.overlapScores.append(overlapScore)	

                seqSuccessList = []
                for threshold in thresholdSetError:
                    seqSuccess = [err for err in seq.errCenter \
                        if err <= threshold]
                    seqSuccessList.append(len(seqSuccess)/float(length))
                precisionList.append(seqSuccessList)

                THRESHOLD = 0.5
                errorNum = len([score for score in seq.errCoverage \
                    if score < THRESHOLD]) / float(length) * 10
                attr.errorNum.append(errorNum)
            # end if
        # end for seqs
        if len(attr.overlapScores) > 0 :
            attr.overlap = sum(attr.overlapScores) / len(attr.overlapScores) * 100

        if len(attr.errorNum) > 0 :
            attr.error = sum(attr.errorNum) / len(attr.errorNum)

        if len(successRateList) > 0:
            for i in range(len(thresholdSetOverlap)):
                attr.successRateList.append(
                    sum([rates[i] for rates in successRateList]) / float(len(successRateList)))
        if len(precisionList) > 0:
            for i in range(len(thresholdSetError)):
                pre = [p[i] for p in precisionList]
                precision = sum(pre) / float(len(pre))
                attr.precisionList.append(precision)
        attr.refresh_dict()
    # end for scores

    attrList.sort()
    return seqResultList, attrList
