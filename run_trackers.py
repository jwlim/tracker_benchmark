import getopt
import numpy as np
from PIL import Image
from config import *
from model.result import Result
from model.sequence import Sequence
from model.attribute import Attribute
import butil
from trackers import *

def main(argv):
    
    try:
        opts, args = getopt.getopt(argv, "ht:e:",["tracker=","evaltype="])
    except getopt.GetoptError:
        print 'usage : run_trackers.py -t <tracker> -e <evaltype>'
        sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            print 'usage : run_trackers.py -t <tracker> -e <evaltype>'
            sys.exit(0)
        elif opt in ("-t", "--tracker"):
            # trackers = [x.strip() for x in arg.split(',')]
            trackers = [arg]
        elif opt in ("-e", "--evaltype"):
            # evalTypes = [x.strip() for x in arg.split(',')]
            evalTypes = [arg]

    if SETUP_SEQ:
        print 'Setup sequences ...'
        butil.setup_seqs()

    shiftTypeSet = ['left','right','up','down','topLeft','topRight',
        'bottomLeft', 'bottomRight','scale_8','scale_9','scale_11','scale_12']

    for evalType in evalTypes:
        seqs = butil.load_all_seq_configs()
        trackerResults = run_trackers(
            trackers, seqs, evalType, shiftTypeSet)
        seqNames = [s.name for s in seqs]
        for tracker in trackers:
            results = trackerResults[tracker]
            if len(results) > 0:
                evalResults, attrList = butil.calc_result(tracker,
                    seqs, results, evalType)
                print "Result of Sequences\t -- '{0}'".format(tracker)
                for seq in seqs:
                    try:
                        print '\t\'{0}\'{1}'.format(
                            seq.name, " "*(12 - len(seq.name))),
                        print "\taveCoverage : {0:.3f}%".format(
                            sum(seq.aveCoverage)/len(seq.aveCoverage) * 100),
                        print "\taveErrCenter : {0:.3f}".format(
                            sum(seq.aveErrCenter)/len(seq.aveErrCenter))
                    except:
                        print '\t\'{0}\'  ERROR!!'.format(seq.name)

                print "Result of attributes\t -- '{0}'".format(tracker)
                for attr in attrList:
                    print "\t\'{0}\'".format(attr.name),
                    print "\toverlap : {0:02.1f}%".format(attr.overlap),
                    print "\tfailures : {0:.1f}".format(attr.error)

                if SAVE_RESULT : 
                    butil.save_results(tracker, evalResults, attrList, 
                        seqNames, evalType)

def run_trackers(trackers, seqs, evalType, shiftTypeSet):
    tmpRes_path = BENCHMARK_SRC + 'tmp/{0}/'.format(evalType)
    if not os.path.exists(tmpRes_path):
        os.makedirs(tmpRes_path)

    numSeq = len(seqs)
    numTrk = len(trackers)

    trackerResults = dict((t,list()) for t in trackers)
    for idxSeq in range(numSeq):
        s = seqs[idxSeq]
        s.len = s.endFrame - s.startFrame + 1
        s.s_frames = [None] * s.len

        for i in range(s.len):
            image_no = s.startFrame + i
            _id = s.imgFormat.format(image_no)
            s.s_frames[i] = s.path + _id
        
        rect_anno = s.gtRect
        numSeg = 20.0
        subSeqs, subAnno = butil.split_seq_TRE(s, numSeg, rect_anno)
        s.subAnno = subAnno
        img = Image.open(s.s_frames[0])
        (imgWidth, imgHeight) = img.size

        if evalType == 'OPE':
            subS = subSeqs[0]
            subSeqs = []
            subSeqs.append(subS)

            subA = subAnno[0]
            subAnno = []
            subAnno.append(subA)

        elif evalType == 'SRE':
            subS = subSeqs[0]
            subA = subAnno[0]
            subSeqs = []
            subAnno = []
            r = subS.init_rect
            for i in range(len(shiftTypeSet)):
                subSeqs.append(subS)
                shiftType = shiftTypeSet[i]
                subSeqs[i].init_rect = butil.shift_init_BB(r, shiftType, 
                    imgWidth, imgHeight)
                subSeqs[i].shiftType = shiftType
                subAnno.append(subA)

        for idxTrk in range(len(trackers)):         
            t = trackers[idxTrk]
            if not os.path.exists(TRACKER_SRC + t):
                print '{0} does not exists'.format(t)
                sys.exit(1)
            seqResults = []
            seqLen = len(subSeqs)
            for idx in range(seqLen):
                print '{0}_{1}, {2}_{3}:{4}/{5} - {6}'.format(
                    idxTrk + 1, t, idxSeq + 1, s.name, idx + 1, seqLen, \
                    evalType)
                rp = tmpRes_path + '_' + t + '_' + str(idx+1) + '/'
                if SAVE_IMAGE and not os.path.exists(rp):
                    os.makedirs(rp)
                subS = subSeqs[idx]
                subS.name = s.name + '_' + str(idx)

                os.chdir(TRACKER_SRC + t)
                funcName = 'run_{0}(subS, rp, SAVE_IMAGE)'.format(t)
                try:
                    res = eval(funcName)
                except:
                    print 'failed to execute {0} : {1}'.format(
                        t, sys.exc_info()[1])
                    sys.exit(1)
                os.chdir(WORKDIR)
                res['seq_name'] = s.name
                res['len'] = subS.len
                res['annoBegin'] = subS.annoBegin
                res['startFrame'] = subS.startFrame

                if evalType == 'SRE':
                    res['shiftType'] = shiftTypeSet[idx]
                seqResults.append(res)
            #end for subseqs

            trackerResults[t].append(seqResults)
        #end for tracker
    #end for allseqs
    return trackerResults

if __name__ == "__main__":
    main(sys.argv[1:])