from config import *

def run_TLD(seq, rp, bSaveImage):
    global m
    if m == None:
        print 'Starting matlab engine...'
        m = matlab.engine.start_matlab()
    m.addpath(m.genpath('.', nargout=1), nargout=0)
    seq.init_rect = matlab.double(seq.init_rect)
    m.workspace['subS'] = seq.__dict__
    m.workspace['rp'] = os.path.abspath(rp)
    m.workspace['bSaveImage'] = bSaveImage
    func = 'run_TLD(subS, rp, bSaveImage);'
    res = m.eval(func, nargout=1)
    # m.quit()
    return res
