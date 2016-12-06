import getopt

import numpy as np
from PIL import Image
from config import *
from scripts import *

def main(argv):
    
    trackers = os.listdir(TRACKER_SRC)
    evalTypes = ['OPE', 'SRE', 'TRE']
    loadSeqs = 'TB50'
    seqs = []
    try:
        opts, args = getopt.getopt(argv, "ht:e:s:",["tracker=","evaltype="
            ,"sequence="])
    except getopt.GetoptError:
        print 'usage : run_trackers.py -t <trackers> -s <sequences>' \
            + '-e <evaltypes>'
        sys.exit(1)

    for opt, arg in opts:
        if opt == '-h':
            print 'usage : run_trackers.py -t <trackers> -s <sequences>' \
                + '-e <evaltypes>'
            sys.exit(0)
        elif opt in ("-t", "--tracker"):
            trackers = [x.strip() for x in arg.split(',')]
            # trackers = [arg]
        elif opt in ("-s", "--sequence"):
            loadSeqs = arg
            if loadSeqs != 'All' and loadSeqs != 'all' and \
                loadSeqs != 'tb50' and loadSeqs != 'tb100' and \
                loadSeqs != 'cvpr13':
                loadSeqs = [x.strip() for x in arg.split(',')]
        elif opt in ("-e", "--evaltype"):
            evalTypes = [x.strip() for x in arg.split(',')]
            # evalTypes = [arg]

    if SETUP_SEQ:
        print 'Setup sequences ...'
        butil.setup_seqs(loadSeqs)
    testname = raw_input("Input Test name : ")
    print 'Starting benchmark for {0} trackers, evalTypes : {1}'.format(
        len(trackers), evalTypes)
    for evalType in evalTypes:
        seqNames = butil.get_seq_names(loadSeqs)
        seqs = butil.load_seq_configs(seqNames)
        trackerResults = run_trackers(
            trackers, seqs, evalType, shiftTypeSet)
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
                    butil.save_scores(attrList, testname)

def run_trackers(trackers, seqs, evalType, shiftTypeSet):
    tmpRes_path = RESULT_SRC.format('tmp/{0}/'.format(evalType))
    if not os.path.exists(tmpRes_path):
        os.makedirs(tmpRes_path)

    numSeq = len(seqs)
    numTrk = len(trackers)

    trackerResults = dict((t,list()) for t in trackers)
    for idxSeq in range(numSeq):
        s = seqs[idxSeq]
        
        subSeqs, subAnno = butil.get_sub_seqs(s, 20.0, evalType)

        for idxTrk in range(len(trackers)):         
            t = trackers[idxTrk]
            if not os.path.exists(TRACKER_SRC + t):
                print '{0} does not exists'.format(t)
                sys.exit(1)
            if not OVERWRITE_RESULT:
                trk_src = os.path.join(RESULT_SRC.format(evalType), t)
                result_src = os.path.join(trk_src, s.name+'.json')
                if os.path.exists(result_src):
                    seqResults = butil.load_seq_result(evalType, t, s.name)
                    trackerResults[t].append(seqResults)
                    continue
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
                        t, sys.exc_info())
                    os.chdir(WORKDIR)         
                    break
                os.chdir(WORKDIR)

                if evalType == 'SRE':
                    r = Result(t, s.name, subS.startFrame, subS.endFrame,
                        res['type'], evalType, res['res'], res['fps'], shiftTypeSet[idx])
                else:
                    r = Result(t, s.name, subS.startFrame, subS.endFrame,
                        res['type'], evalType, res['res'], res['fps'], None)
                try: r.tmplsize = butil.d_to_f(res['tmplsize'][0])
                except: pass
                r.refresh_dict()
                seqResults.append(r)
            #end for subseqs
            if SAVE_RESULT:
                butil.save_seq_result(seqResults)

            trackerResults[t].append(seqResults)
        #end for tracker
    #end for allseqs
    return trackerResults

if __name__ == "__main__":
    main(sys.argv[1:])
