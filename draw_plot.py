import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from PIL import Image
from config import *
from model.result import Result
import butil


def main():
    m = matlab.engine.start_matlab()
    init_path(m)
    evalTypes = ['OPE', 'SRE', 'TRE']
    for i in range(len(evalTypes)):
        evalType = evalTypes[i]
        print "\t{0:2d}. {1}".format(i+1, evalType)

    while True:
        n = int(raw_input("\nInput evalType number (-1 to exit) : "))
        if n == -1:
            sys.exit()
        try:
            evalType = evalTypes[n-1]
            break
        except:
            print "invalid number"

    src = RESULT_SRC.format(evalType)
    trackers = os.listdir(src)
    for i in range(len(trackers)):
        t = trackers[i]
        print "\t{0:2d}. {1}".format(i+1, t)

    while True:
        n = int(raw_input("\nInput tracker number (-1 to exit) : "))
        if n == -1:
            sys.exit()
        try:
            tracker = trackers[n-1]
            break
        except:
            print "invalid number"

    src = src + '/' + tracker + '/'
    seqs = os.listdir(src)
    seqs.remove('attributes')
  
    while True:
        for i in range(len(seqs)):
            s = seqs[i]
            print "\t{0:2d}. {1}".format(i+1, s)
        results = []
        n = int(raw_input("\nInput sequence number (-1 to exit) : "))
        if n == -1:
            sys.exit()
        try:
            resultFile = open(os.path.join(src, seqs[n-1]))
        except:
            print "invalid number"

        string = resultFile.read()
        jsonList = json.loads(string)
        for j in jsonList:
            result = Result(**j)
            results.append(result)

        for i in range(len(results)):
            result = results[i]
            print "\t{0:2d}. startFrame : {1},\tshiftType : {2}".format(i+1, result.startFrame, result.shiftType)

        n = int(raw_input("\nInput result number (-1 to exit) : "))
        if n == -1:
            sys.exit()
        try:
            result = results[n-1]
        except:
            print "invalid number"
            continue

        seq = butil.load_seq_config(result.seqName)
        res = []
        result.len = result.endFrame - result.startFrame + 1
        
        if result.resType == 'rect':
            res = result.res
        elif result.resType == 'ivtAff':
            for r in result.res:
                x = m.calcRectCenter(matlab.double([32,32]), matlab.double(r), nargout=1)
                res.append(map(int, x[0]))
        elif result.resType =='L1Aff':
            for r in result.res:
                x = m.calcCenter_L1(matlab.double(r), matlab.double([32,32]), nargout=1)
                res.append(map(int, x[0]))
        else:
            print "cannot draw '{0}' type".format(result.resType) 

        startFrame = result.startFrame
        view_result(seq, res, startFrame)
    

def view_result(seq, res, startIndex):
    fig = plt.figure()

    src = os.path.join(SEQ_SRC, seq.name)
    image = Image.open(src + '/img/{0:04d}.jpg'.format(startIndex)).convert('RGB')
    im = plt.imshow(image, zorder=0)

    x, y, w, h = get_coordinate(res[0])
    gx, gy, gw, gh = get_coordinate(seq.gtRect[startIndex-1])

    rect = plt.Rectangle((x, y), w, h, 
      linewidth=5, edgecolor="#ff0000", zorder=1, fill=False)
    gtRect = plt.Rectangle((gx, gy), gw, gh, 
      linewidth=5, edgecolor="#00ff00", zorder=1, fill=False)
    plt.gca().add_patch(rect)
    plt.gca().add_patch(gtRect)

    def update_fig(num, startIndex, res, gt, src):    
        r = res[num]
        g = gt[num + startIndex - 1]
        x, y, w, h = get_coordinate(r)
        gx, gy, gw, gh = get_coordinate(g)
        i = startIndex + num
        image = Image.open(src + '/img/{0:04d}.jpg'.format(i)).convert('RGB')
        im.set_data(image)
        rect.set_xy((x,y))
        rect.set_width(w)
        rect.set_height(h)
        gtRect.set_xy((gx,gy))
        gtRect.set_width(gw)
        gtRect.set_height(gh)
        return im, rect, gtRect

    ani = animation.FuncAnimation(fig, update_fig, 
        frames=len(res), fargs=(startIndex, res, seq.gtRect, src), interval=10, blit=True)
    plt.axis("off")
    plt.show()

def get_coordinate(res):
    return int(res[0]), int(res[1]), int(res[2]), int(res[3])
  

if __name__ == '__main__':
    main()
