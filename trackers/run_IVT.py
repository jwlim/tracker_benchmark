from config import *

def run_IVT(seq, rp, bSaveImage):
    m = matlab.engine.start_matlab()
    seq.init_rect = matlab.double(seq.init_rect)
    m.workspace['subS'] = seq.__dict__
    m.workspace['rp'] = os.path.abspath(rp)
    m.workspace['bSaveImage'] = bSaveImage
    func = 'run_IVT(subS, rp, bSaveImage);'
    res = m.eval(func, nargout=1)
    print len(res['res'])
    m.quit()
    return res
