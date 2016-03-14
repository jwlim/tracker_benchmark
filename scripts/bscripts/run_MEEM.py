from config import *
import time
import scripts.butil

def run_MEEM(seq, rp, bSaveImage):
    global m

    if m == None:
        print 'Starting matlab engine...'
        m = matlab.engine.start_matlab()
    
    m.addpath(m.genpath('.', nargout=1), nargout=0)
    seq.init_rect = matlab.double(seq.init_rect)
    res = m.MEEMTrack(seq.path, seq.nz, seq.ext, bSaveImage, seq.init_rect, seq.startFrame,
        seq.endFrame)
    res['res'] = scripts.butil.matlab_double_to_py_float(res['res'])
    return res
