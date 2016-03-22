from config import *
import time
import scripts.butil

def run_MUSTer(seq, rp, bSaveImage):
    global m
    source = dict()
    source['n_frames'] = seq.len
    source['video_path'] = seq.path
    img_files = sorted([x for x in os.listdir(seq.path) if x.endswith(seq.ext)])
    source['img_files'] = img_files[seq.startFrame-1:seq.endFrame]
    if m == None:
        print 'Starting matlab engine...'
        m = matlab.engine.start_matlab()
    m.addpath(m.genpath('.', nargout=1), nargout=0)
    seq.init_rect = matlab.double(seq.init_rect)
    tic = time.clock()
    bboxes = m.MUSTer_tracking(source, seq.init_rect, nargout=1)
    duration = time.clock() - tic
    res = dict()
    res['res'] = scripts.butil.matlab_double_to_py_float(bboxes)
    res['type'] = 'rect'
    res['fps'] = round(seq.len / duration, 3)
    return res
