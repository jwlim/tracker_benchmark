import butil
import math

def calc_seq_err_robust(results, rect_anno):
    seq_length = int(results['len'])
    res = results['res']
    centerGT = [[r[0]+(r[2]-1)/2.0, r[1]+(r[3]-1)/2.0] for r in rect_anno]
    
    rectMat = [[0, 0, 0, 0]] * seq_length

    resultType = results['type']
    if resultType == 'rect':
        rectMat = res
    elif resultType == 'ivtAff':
        for i in range(seq_length):
            # rect, c, corn = butil.calc_rect_center(results['tmplsize'], res[i])
            rect = butil.rect_affine_IVT(results['tmplsize'][0], res[i])
            rectMat[i] = rect
    elif resultType == 'L1Aff':
        for i in range(seq_length):
            # rect, c = butil.calc_center_L1(res[i], results['tmplsize'])
            rect = butil.rect_affine_L1(results['tmplsize'][0], res[i])
            rectMat[i] = rect
    elif resultType == 'LK_Aff':
        for i in range(seq_length):
            rect = butil.rect_affine_LK(results['tmplsize'][0], 
                res[2*i:2*(i+1)])
            rectMat[i] = rect
    elif resultType == '4corner':
        for i in range(seq_length):
            # corner = res[2*i:2*(i+1)]
            # rectMat[i] = butil.d_to_f(m.corenr2rect(corner, nargout=1)[0])
            rect = butil.rect_4corners(res[2*i:2*(i+1)])
            rectMat[i] = rect
    elif resultType == 'affine':
        for i in range(seq_length):
            rect = butil.rect_4corners(res[2*i:2*(i+1)])
            rectMat[i] = rect
    elif resultType == 'SIMILARITY':
        for i in range(seq_length):
            rect = butil.rect_similarity(results['tmplsize'][0], res[i])
            rectMat[i] = rect
            # wapr_p = m.parameters_to_projective_matrix(resultType, res[i],
            #     nargout=1)
            # corenr, c = m.getLKcorner(wapr_p, results['tmplsize'], nargout=2)
            # rectMat[i] = butil.do_to_f(m.corner2rect(corner, nargout=1)[0])

    rectMat[0] = rect_anno[0]
    center = [[r[0]+(r[2]-1)/2.0, r[1]+(r[3]-1)/2.0] for r in rectMat]
    errCenter = [round(butil.ssd(center[i], centerGT[i]),4)
        for i in range(seq_length)]

    idx = [sum([x>0 for x in r])==4 for r in rect_anno]
    tmp = calc_rect_int(rectMat, rect_anno)

    errCoverage = [-1] * seq_length
    totalerrCoverage = 0
    totalerrCenter = 0

    for i in range(seq_length):
        if idx[i]:
            errCoverage[i] = tmp[i]
            totalerrCoverage += errCoverage[i]
            totalerrCenter += errCenter[i]
        else:
            errCenter[i] = -1

    aveErrCoverage = totalerrCoverage / float(sum(idx))
    aveErrCenter = totalerrCenter / float(sum(idx))

    return aveErrCoverage, aveErrCenter, errCoverage, errCenter

def calc_rect_int(A, B):
    leftA = [a[0] for a in A]
    bottomA = [a[1] for a in A]
    rightA = [leftA[i] + A[i][2] - 1 for i in range(len(A))]
    topA = [bottomA[i] + A[i][3] - 1 for i in range(len(A))]

    leftB = [b[0] for b in B]
    bottomB = [b[1] for b in B]
    rightB = [leftB[i] + B[i][2] - 1 for i in range(len(B))]
    topB = [bottomB[i] + B[i][3] - 1 for i in range(len(B))]

    overlap = []
    for i in range(len(leftA)):
        tmp = (max(0, min(rightA[i], rightB[i]) - max(leftA[i], leftB[i])+1)
            * max(0, min(topA[i], topB[i]) - max(bottomA[i], bottomB[i])+1))
        areaA = A[i][2] * A[i][3]
        areaB = B[i][2] * B[i][3]
        overlap.append(tmp/float(areaA+areaB-tmp))

    return overlap
