from config import *
from scripts import *

def save_results(tracker, resultList, attrList, seqNames, evalType):
    tSrc = RESULT_SRC.format(evalType) + tracker
    if not os.path.exists(tSrc):
        os.makedirs(tSrc)

    for seq in seqNames:
        result = resultList[seq]
        string = json.dumps(result, default=lambda o : o.__dict__)
        fileName = tSrc + '/{0}.json'.format(seq)
        resFile = open(fileName, 'wb')
        resFile.write(string)
        resFile.close()

    for attr in attrList:
        src = tSrc + '/attributes'
        if not os.path.exists(src):
            os.makedirs(src)
        string = json.dumps(attr, default=lambda o : o.__dict__)
        fileName = src + '/{0}.json'.format(attr.name)
        attrFile = open(fileName, 'wb')
        attrFile.write(string)
        attrFile.close()

def load_results(evalType):
    resultSRC = RESULT_SRC.format(evalType)
    trackers = os.listdir(resultSRC)
    resultList = []
    for tracker in trackers:
        print 'Loading \'{0}\'...'.format(tracker),
        src = os.path.join(resultSRC, tracker)
        resultNames = os.listdir(src)
        attrs = []
        results = []
        for name in resultNames:
            if name == 'attributes':
                attrSrc = os.path.join(src, name)
                attrNames = os.listdir(attrSrc)
                for attrName in attrNames:
                    attrFile = open(os.path.join(attrSrc, attrName))
                    string = attrFile.read()
                    j = json.loads(string)
                    attr = Attribute(**j)
                    attr.successRateList = map(lambda o:o*100, attr.successRateList)
                    attrs.append(attr)
                    attrs.sort()
            elif name.endswith('.json'):
                resultFile = open(os.path.join(src, name))
                string = resultFile.read()
                jsonList = json.loads(string)
                for j in jsonList:
                    result = Result(**j)
                    results.append(result)
        print '({0} seqs)'.format(len(resultNames) - 1)
        resultList.append((tracker, results, attrs))

    return resultList

def load_attrs(evalType):
    resultSRC = RESULT_SRC.format(evalType)
    trackers = os.listdir(resultSRC)
    attrList = []
    for tracker in trackers:
        print 'Loading \'{0}\'...'.format(tracker)
        src = os.path.join(resultSRC, tracker+'/attributes')
        attrNames = os.listdir(src)
        attrs = []
        for attrName in attrNames:
            attrFile = open(os.path.join(src, attrName))
            string = attrFile.read()
            j = json.loads(string)
            attr = Attribute(**j)
            attr.successRateList = map(lambda o:o*100, attr.successRateList)
            attrs.append(attr)
            attrs.sort()
        attrList.append((tracker, attrs))

    return attrList