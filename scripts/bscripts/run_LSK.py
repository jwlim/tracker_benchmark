import subprocess
import time
import math
import numpy as np
from config import *

def run_LSK(seq, rp, bSaveImage):
    x = seq.init_rect[0] - 1
    y = seq.init_rect[1] - 1
    w = seq.init_rect[2]
    h = seq.init_rect[3]

    path = './results/'
    config = './config/'

    if not os.path.exists(path):
        os.makedirs(path)
    if not os.path.exists(config):
        os.makedirs(config)

    name_sub_gt = config + seq.name + '_gt.txt'
    gtfile = open(name_sub_gt, 'w')
    gtfile.write(', '.join(map(str, seq.init_rect)))
    gtfile.close()

    name_xml = config + seq.name + '.xml'
    xmlfile = open(name_xml, 'w')

    sizeC = [30.0, 30.0]
    ratio = (sizeC[0]*sizeC[1])/(seq.init_rect[2]*seq.init_rect[3])
    if ratio >= 1:
        ratio = 1
    else:
        ratio = math.ceil(ratio*10)/10.0

    xmlstr = \
        '<xml>\n' + \
        '\t<properties>\n' + \
        '\t\t<!-- resize the image to specified scale for tracking -->\n' + \
        '\t\t<imgScale>{0:.2f}</imgScale>\n'.format(ratio) + \
        '\t\t<!-- the patch size -->\n' + \
        '\t\t<patchSize>5</patchSize>\n' + \
        '\t\t<!-- dictionary size (percentage) -->\n' + \
        '\t\t<dictionarySize>0.15</dictionarySize>\n' + \
        '\t\t<!-- the sparsity parameter K -->\n' + \
        '\t\t<sparistyK>3</sparistyK>\n' + \
        '\t</properties>\n' + \
        \
        '\t<sequence>\n' + \
        '\t\t<name>{0}</name>\n'.format(seq.name) + \
        '\t\t<gtFile>{0}</gtFile>\n'.format(name_sub_gt) + \
        '\t\t<imgFolder>{0}</imgFolder>\n'.format(seq.path) + \
        '\t\t<imgIdFormat>%{0:02d}d</imgIdFormat>\n'.format(seq.nz) + \
        '\t\t<imgExt>{0}</imgExt>\n'.format(seq.ext) + \
        '\t\t<startFrame>{0}</startFrame>\n'.format(seq.startFrame) + \
        '\t\t<endFrame>{0}</endFrame>\n'.format(seq.endFrame) + \
        '\t\t<writeImage>{0}</writeImage>\n'.format(0) + \
        '\t\t<showResult>{0}</showResult>\n'.format(0) + \
        '\t\t<outputFolder>{0}</outputFolder>\n'.format(path) + \
        '\t</sequence>\n' + \
        '</xml>\n'

    xmlfile.write(xmlstr)
    xmlfile.close()


    command = ['spt64.exe', name_xml]

    tic = time.clock()
    subprocess.call(command)
    duration = time.clock() - tic

    result = dict()
    res = np.loadtxt(path + '{0}.txt'.format(seq.name), dtype=int)
    result['res'] = res.tolist()
    result['type'] = 'rect'
    result['fps'] = round(seq.len / duration, 3)

    return result