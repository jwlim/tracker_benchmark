import matplotlib.pyplot as plt
import numpy as np
import butil
from config import *

def main():
    evalTypes = ['SRE', 'TRE']
    for i in range(len(evalTypes)):
        evalType = evalTypes[i]
        attrList = butil.load_attrs(evalType)
        plt = get_graph(attrList, i, evalType)
    plt.show()


def get_graph(attrList, num, evalType):
    fig = plt.figure(num=num, figsize=(9,6), dpi=70)
    rankList = sorted(attrList, 
        key=lambda o: sum(o[1][0].successRateList), reverse=True)
    for i in range(len(rankList)):
        result = rankList[i]
        tracker = result[0]
        attr = result[1][0]
        if len(attr.successRateList) == len(thresholdSetOverlap):
            if i < MAXIMUM_LINES:
                ls = '-'
                if i % 2 == 1:
                    ls = '--'
                ave = sum(attr.successRateList) / float(len(attr.successRateList))
                plt.plot(thresholdSetOverlap, attr.successRateList, 
                    c = LINE_COLORS[i], label='{0} [{1:.2f}]'.format(tracker, ave), lw=2.0, ls = ls)
            else:
                plt.plot(thresholdSetOverlap, attr.successRateList, 
                    label='', alpha=0.5, c='#202020', ls='--')
    plt.title('{0}50 (sequence average)'.format(evalType))
    plt.rcParams.update({'axes.titlesize': 'medium'})
    plt.xlabel('thresholds')
    plt.xticks(np.arange(thresholdSetOverlap[0], thresholdSetOverlap[len(thresholdSetOverlap)-1]+0.1, 0.1))
    plt.grid(color='#101010', alpha=0.5, ls=':')
    plt.legend(fontsize='medium')
    plt.savefig(BENCHMARK_SRC + 'graph/{0}_50sq.png'.format(evalType), dpi=74, bbox_inches='tight')
    # plt.show()  
    return plt

if __name__ == '__main__':
    main()