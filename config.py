# -*- coding: utf-8 -*-
import json
import sys
import os
import matlab
import matlab.engine

############### benchmark config ####################

WORKDIR = os.path.abspath('.')

BENCHMARK_SRC = './tracker_benchmark/'

SEQ_SRC = BENCHMARK_SRC + 'data/'

ATTR_SRC = BENCHMARK_SRC + 'attribute/'

TRACKER_SRC = BENCHMARK_SRC + 'trackers/'

RESULT_SRC = BENCHMARK_SRC+ 'results/{0}/' # '{0} : OPE, SRE, TRE'

VLFEAT_SRC = os.path.abspath('./vlfeat-0.9.20/toolbox')

SETUP_SEQ = True

SAVE_RESULT = False

SAVE_IMAGE = False

# sequence configs
GT_FILE = 'groundtruth_rect.txt'

# for eval results
thresholdSetOverlap = [x/float(20) for x in range(21)]
thresholdSetError = range(0, 51)

# for drawing plot
MAXIMUM_LINES = 10
LINE_COLORS = ['b','g','r','c','m','y','k', '#880015', '#FF7F27', '#00A2E8']

m = None

def init_path(m):
    m.cd(os.path.abspath(BENCHMARK_SRC), nargout=0)
    m.addpath(m.genpath('.', nargout=1), nargout=0)
    m.addpath(VLFEAT_SRC)