import copy
import numpy as np
from config import *

def split_seq_TRE(seq, segNum, rect_anno):
    minNum = 20;

    fileName = SEQ_SRC + seq.name + '/' + INIT_OMIT_FILE
    idxExclude = []
    if USE_INIT_OMIT and os.path.exists(fileName):
        idxExclude = np.loadtxt(fileName, dtype=int) - seq.startFrame + 1
        if not isinstance(idxExclude[0], np.ndarray):
            idxExclude = [idxExclude]

    idx = range(1, seq.len + 1)

    for j in range(len(idxExclude)):
        begin = idxExclude[j][0] - 1
        end = idxExclude[j][1]
        idx[begin:end] = [0] * (end-begin)
    idx = [x for x in idx if x > 0]

    for i in range(len(idx)):
        r = rect_anno[idx[i] - 1]
        if r[0]<=0 or r[1]<=0 or r[2]<=0 or r[3]<=0:
            idx[i] = 0
    idx = [x for x in idx if x > 0]
    for i in reversed(range(len(idx))):
        if seq.len - idx[i] + 1 >= minNum:
            endSeg = idx[i]
            endSegIdx = i + 1
            break

    startFrIdxOne = np.floor(np.arange(1, endSegIdx, endSegIdx/(segNum-1)))
    startFrIdxOne = np.append(startFrIdxOne, endSegIdx)
    startFrIdxOne = [int(x) for x in startFrIdxOne]

    subAnno = []
    subSeqs = []

    for i in range(len(startFrIdxOne)):
        index = idx[startFrIdxOne[i] - 1] - 1
        subS = copy.deepcopy(seq)
        subS.startFrame = index + seq.startFrame
        subS.len = subS.endFrame - subS.startFrame + 1
        subS.annoBegin = seq.startFrame
        subS.init_rect = rect_anno[index]
        anno = rect_anno[index:]
        subS.s_frames = seq.s_frames[index:]
        subSeqs.append(subS)
        subAnno.append(anno)

    return subSeqs, subAnno




