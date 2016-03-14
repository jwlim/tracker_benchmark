import subprocess
import time
import numpy as np
from config import *

def run_OAB(seq, rp, bSaveImage):
    x = seq.init_rect[0] - 1
    y = seq.init_rect[1] - 1
    w = seq.init_rect[2]
    h = seq.init_rect[3]

    path = './results/'

    cfgfile = open('config.txt', 'w')
    cfgstr = \
        '% tracking with on-line boosting\n' + \
        'version 0.3\n\n' + \
        '% source options: USB, AVI, IMAGES\n' + \
        'source = IMAGES\n' + \
        '% only if source is AVI OR IMAGES\n' + \
        'directory = %s\n\n' % (seq.path) + \
        '% write debug information\n' + \
        'debug = false\n' + \
        'saveDir = %s\n\n' % (path) + \
        '% classifier (boosting)\n' + \
        'numSelectors = 100\n\n' + \
        '% search region (size and resolution)\n' + \
        'overlap = 0.99\n' + \
        'searchFactor = 2\n\n' + \
        '%initialization bounding box: MOUSE or COORDINATES\n' + \
        'initBB = COORDINATES\n\n' + \
        '%if COORDINATES bb = x y width height\n' + \
        'bb = %d %d %d %d\n' % (x, y, w, h)

    cfgfile.write(cfgstr)
    cfgfile.close()

    if not os.path.exists(path):
        os.makedirs(path)

    # command = map(str,['BoostingTracker.exe', '100', '0.99', '2', 
    #     '0', '0', '0', seq.name, seq.path, seq.startFrame, seq.endFrame, 
    #     seq.nz, seq.ext, x, y, w, h])

    command = ['BoostingTracker.exe']

    tic = time.clock()
    subprocess.call(command)
    duration = time.clock() - tic

    result = dict()
    res = np.loadtxt(path + '{0}_BT.txt'.format(seq.name), dtype=int)
    result['res'] = res.tolist()
    result['type'] = 'rect'
    result['fps'] = round(seq.len / duration, 3)

    return result