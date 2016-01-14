from config import *
from model.attribute import *
from model.result import Result
import butil 

def calc_result(tracker, seqs, results, evalType):
    # if not len(results) == len(seqs):
    #     print "length of results({0}) & sequences({1}) are not equal."
    #         .format(len(results), len(seqs))
    #     return

    seqResultList = dict((s.name,list()) for s in seqs)
    for i in range(len(results)):
        subResults = results[i]
        try:
            seq = next(seq for seq in seqs if seq.name.lower() == subResults[0]['seq_name'].lower())
            seq.aveCoverage = []
            seq.aveErrCenter = []
            seq.errCoverage = []
            seq.errCenter = []
        except:
            print "Cannot find sequence '{0}'".format(subResults[0]['seq_name'])

        if evalType == 'SRE':
            idxNum = len(subResults)
            anno = seq.subAnno[0]
        elif evalType == 'TRE':
            idxNum = len(subResults)
        elif evalType == 'OPE':
            idxNum = 1
            anno = seq.subAnno[0]

        for j in range(idxNum):
            result = subResults[j]
            if evalType == 'TRE':
                anno = seq.subAnno[j]
            try:
                aveCoverage, aveErrCenter, errCoverage, errCenter = \
                    butil.calc_seq_err_robust(result, anno)
                seq.aveCoverage.append(aveCoverage)
                seq.aveErrCenter.append(aveErrCenter)
                seq.errCoverage += errCoverage
                seq.errCenter += errCenter
            except:
                print "calcSeqErrRobust failed for '{0}', {1}/{2}".format(
                    seq.name, len(anno), len(result['res']))
            
            seqName = seq.name
            startFrame = int(result['startFrame'])
            endFrame = startFrame + int(result['len']) - 1
            resType = result['type']
            res = butil.matlab_double_to_py_float(result['res'])

            if evalType == 'SRE':
                mResult = Result(tracker, seqName, startFrame, endFrame, 
                    resType, evalType, res, result['shiftType'])
            else:
                mResult = Result(tracker, seqName, startFrame, endFrame, 
                    resType, evalType, res, 'None')
            seqResultList[seqName].append(mResult)
        #end for j
    # end for i

    attrList = getAttrList()
    allAttr = Attribute.getAttrFromLine("ALL\tall")
    allSuccessRateList = []
    for attr in attrList:
        successRateList = []
        for seq in seqs:
            if attr.name in seq.attributes:
                seqSuccessList = []
                length = len(seq.errCoverage)
                for threshold in thresholdSetOverlap:
                	seqSuccess = [score for score in seq.errCoverage 
                        if score > threshold]
                	seqSuccessList.append(len(seqSuccess)/float(length))
                successRateList.append(seqSuccessList)
                allSuccessRateList.append(seqSuccessList)

                overlapList = [score for score in seq.errCoverage 
                    if score > 0]
                overlapScore = sum(overlapList) / len(overlapList)
                attr.overlapScores.append(overlapScore)	
                allAttr.overlapScores.append(overlapScore)

                THRESHOLD = 0.5
                errorNum = len([score for score in seq.errCoverage 
                    if score < THRESHOLD]) / float(length) * 10
                attr.errorNum.append(errorNum)
                allAttr.errorNum.append(errorNum)

        if len(attr.overlapScores) > 0 :
            attr.overlap = sum(attr.overlapScores) / len(attr.overlapScores) * 100

        if len(attr.errorNum) > 0 :
            attr.error = sum(attr.errorNum) / len(attr.errorNum)

        if len(successRateList) > 0:
            for i in range(len(thresholdSetOverlap)):
                attr.successRateList.append(
                    sum([rates[i] for rates in successRateList]) / float(len(successRateList)))

    if len(allAttr.overlapScores) > 0 :
        allAttr.overlap = sum(allAttr.overlapScores) / len(allAttr.overlapScores) * 100

    if len(allAttr.errorNum) > 0 :
        allAttr.error = sum(allAttr.errorNum) / len(allAttr.errorNum)

    if len(allSuccessRateList) > 0:
        for i in range(len(thresholdSetOverlap)):
           allAttr.successRateList.append(
                sum([rates[i] for rates in allSuccessRateList]) /float(len(allSuccessRateList)))

    attrList.append(allAttr)
    attrList.sort()
    return seqResultList, attrList
