import math
import numpy as np

def corners2rect(corners):
    result_corners = np.floor(corners[:,0:4])
    x = result_corners[0,0]
    y = result_corners[1,0]
    w = result_corners[0,2] - x
    h = result_corners[1,2] - y
    rect = map(int, [x, y, w, h])
    return rect

def rect_affine_IVT(tmplsize, res):
    w = float(tmplsize[0])
    h = float(tmplsize[1])
    corners = np.matrix((
        (1,-w/2,-h/2),
        (1,w/2,-h/2),
        (1,w/2,h/2),
        (1,-w/2,h/2),
        (1,-w/2,-h/2))).T
    p = res
    M = np.matrix(((p[0], p[2], p[3]), (p[1], p[4], p[5])))
    c = M * corners
    rect = corners2rect(c)
    return rect

def rect_affine_L1(tmplsize, res):
    w = float(tmplsize[0])
    h = float(tmplsize[1])
    corners = np.matrix((
        (1,w,w,1),
        (1,1,h,h),
        (1,1,1,1)))
    p = res
    M = np.matrix(((p[2], p[3], p[5]), (p[0], p[1], p[4])))
    c = M * corners
    rect = corners2rect(c)
    return rect

def rect_affine_LK(tmplsize, res):
    h = float(tmplsize[0])
    w = float(tmplsize[1])
    corners = np.matrix((
        (1,1,1),
        (1,h,1),
        (w,h,1),
        (w,1,1))).T
    p = res
    M = np.matrix(((p[0], p[1], p[4]), (p[2], p[3], p[5])))
    c = M * corners
    rect = corners2rect(c)
    return rect

def rect_4corners(res):
    rect = corners2rect(res)
    return rect

def rect_similarity(tmplsize, res):
    h = float(tmplsize[0])
    w = float(tmplsize[1])

    corners = np.matrix((
        (1,w,w,1),
        (1,1,h,h),
        (1,1,1,1)))
    p = res
    s = np.matrix((
            (math.cos(p[1]), -math.sin(p[1])),
            (-math.sin(p[1]), math.cos(p[1]))))
    s = p[0] * s
    M = np.matrix((
            (s[0,0], s[0,1], p[2]),
            (s[1,0], s[1,1], p[3])))
    c = M * corners
    rect = corners2rect(c)
    return rect


def calc_rect_center(*params):
    if (len(params) == 2):
        tmplsize = params[0][0]
        w = float(tmplsize[0])
        h = float(tmplsize[1])
        params = [params[1:][0]]
    else:
        w = float(params[0])
        h = float(params[1])
        params = [params[2:]]

    if len(params) < 1 or len(params[0]) != 6:
        M = np.matrix(((0,1,0), (0,0,1)))
    else:
        p = params[0]
        M = np.matrix(((p[0], p[2], p[3]), (p[1], p[4], p[5])))
    corners = np.matrix(((1,-w/2,-h/2),
        (1,w/2,-h/2), (1,w/2,h/2), (1,-w/2,h/2), (1,-w/2,-h/2))).T

    corners = M * corners;
    result_corners = np.floor(corners[:,0:4])
    x = result_corners[0,0]
    y = result_corners[1,0]
    w = result_corners[0,2] - x
    h = result_corners[1,2] - y
    rect = map(int, [x, y, w, h])
    center = np.mean(corners[:,0:4],1)
    return rect, center, corners

def aff2image(aff_maps, T_sz):
    r = T_sz[0]
    c = T_sz[1]
    n = aff_maps.shape[1]
    boxes = np.zeros((8, n))
    for i in range(n):
        aff = aff_maps[:,i].A1
        R = np.matrix((
            (aff[0], aff[1], aff[4]),
            (aff[2], aff[3], aff[5])))
        P = np.matrix((
                (1, r, 1, r),
                (1, 1, c, c),
                (1, 1, 1, 1)))

        Q = R * P
        boxes[:,i] = Q.reshape(1,8)
    return boxes

def calc_center_L1(afnv, tsize):
    rect = np.round(aff2image(np.matrix(afnv).T, tsize[0]))
    inp = rect.reshape(2,4)

    topleft_r = inp[0,0]
    topleft_c = inp[1,0];
    botleft_r = inp[0,1];
    botleft_c = inp[1,1];
    topright_r = inp[0,2];
    topright_c = inp[1,2];
    botright_r = inp[0,3];
    botright_c = inp[1,3];

    center=[(topleft_c + botright_c)/2.0, (topleft_r+botright_r)/2.0]
    r = [topleft_c,topleft_r,botright_c-topleft_c+1,botright_r-topleft_r+1]

    return r, center
