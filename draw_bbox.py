import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from PIL import Image
from config import *
from scripts import *


def main():
    evalTypes = ['OPE', 'SRE', 'TRE']
    print "Eval types"
    for i in range(len(evalTypes)):
        evalType = evalTypes[i]
        print "{0:2d}. {1}".format(i+1, evalType)

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
    print "\nTrackers"
    for i in range(len(trackers)):
        t = trackers[i]
        print "{0:2d}. {1}".format(i+1, t)

    while True:
        n = int(raw_input("\nInput tracker number (-1 to exit) : "))
        if n == -1:
            sys.exit()
        try:
            tracker = trackers[n-1]
            break
        except:
            print "invalid number"

    src = os.path.join(src, tracker)
    seqs = [x for x in os.listdir(src) if x.endswith('.json')]    
  
    while True:
        print "\nSequences"
        for i in range(len(seqs)):
            s = seqs[i]
            print "{0:2d}. {1}".format(i+1, s)
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
            print "{0:2d}. startFrame : {1},\tshiftType : {2}".format(i+1, result.startFrame, result.shiftType)

        n = int(raw_input("\nInput result number (-1 to exit) : "))
        if n == -1:
            sys.exit()
        try:
            result = results[n-1]
        except:
            print "invalid number"
            continue

        seq = butil.load_seq_config(result.seqName)
        startFrame = result.startFrame
        view_result(seq, result.res, startFrame)
    

def view_result(seq, res, startIndex):
    fig = plt.figure()

    src = os.path.join(SEQ_SRC, seq.name)
    image = Image.open(src + '/img/{0:04d}.jpg'.format(startIndex)).convert('RGB')
    im = plt.imshow(image, zorder=0)

    x, y, w, h = get_coordinate(res[0])
    gx, gy, gw, gh = get_coordinate(seq.gtRect[startIndex-seq.startFrame])

    rect = plt.Rectangle((x, y), w, h, 
      linewidth=5, edgecolor="#ff0000", zorder=1, fill=False)
    gtRect = plt.Rectangle((gx, gy), gw, gh, 
      linewidth=5, edgecolor="#00ff00", zorder=1, fill=False)
    plt.gca().add_patch(rect)
    plt.gca().add_patch(gtRect)

    def update_fig(num, startIndex, res, gt, src, startFrame):    
        r = res[num]
        g = gt[num+startIndex-startFrame]
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
        frames=len(res), fargs=(startIndex, res, seq.gtRect, src, seq.startFrame), interval=10, blit=True)
    plt.axis("off")
    plt.show()

def get_coordinate(res):
    return int(res[0]), int(res[1]), int(res[2]), int(res[3])
  

if __name__ == '__main__':
    main()
