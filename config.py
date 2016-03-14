# -*- coding: utf-8 -*-
import json
import sys
import os

try:
    import matlab
    import matlab.engine
except:
    pass

############### benchmark config ####################

WORKDIR = os.path.abspath('.')

SEQ_SRC = './data/'

TRACKER_SRC = './trackers/'

RESULT_SRC = './results/{0}/' # '{0} : OPE, SRE, TRE'

SETUP_SEQ = True

SAVE_RESULT = True

OVERWRITE_RESULT = False

SAVE_IMAGE = False

USE_INIT_OMIT = True

# sequence configs
DOWNLOAD_SEQS = True
DOWNLOAD_URL = "http://cvlab.hanyang.ac.kr/tracker_benchmark/seq_new/{0}.zip"
ATTR_LIST_FILE = 'attr_list.txt'
ATTR_DESC_FILE = 'attr_desc.txt'
TB_50_FILE = 'tb_50.txt'
TB_100_FILE = 'tb_100.txt'
CVPR_13_FILE = 'cvpr13.txt' 
ATTR_FILE = 'attrs.txt'
INIT_OMIT_FILE = 'init_omit.txt'
GT_FILE = 'groundtruth_rect.txt'

shiftTypeSet = ['left','right','up','down','topLeft','topRight',
        'bottomLeft', 'bottomRight','scale_8','scale_9','scale_11','scale_12']

# for evaluating results
thresholdSetOverlap = [x/float(20) for x in range(21)]
thresholdSetError = range(0, 51)

# for drawing plot
MAXIMUM_LINES = 10
LINE_COLORS = ['b','g','r','c','m','y','k', '#880015', '#FF7F27', '#00A2E8']

m = None    # matlab engine