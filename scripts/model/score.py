from collections import OrderedDict
from config import *

##########################################################
class Score:
    # name
    # desc
    # ovelapScores
    # errorNum
    # overlap
    # error
    # successRateList

    def __init__(self, name, desc, tracker=None, evalType=None, seqs=[],
        overlapScores=[], errorNum=[], overlap=0, error=0, successRateList=[],
        precisionList=[]):
        self.name = name
        self.desc = desc
        self.tracker = tracker
        self.evalType = evalType
        self.seqs = seqs
        self.overlapScores = overlapScores
        self.errorNum = errorNum
        self.overlap = overlap
        self.error = error
        self.successRateList = successRateList
        self.precisionList = precisionList

        self.__dict__ = OrderedDict([
            ('name', self.name),
            ('desc', self.desc),
            ('tracker', self.tracker),
            ('evalType', self.evalType),
            ('seqs', self.seqs),
            ('overlap', self.overlap),
            ('error', self.error),
            ('overlapScores', self.overlapScores),
            ('errorNum', self.errorNum),
            ('successRateList', self.successRateList),
            ('precisionList', self.precisionList)])

    def refresh_dict(self):
        self.__dict__ = OrderedDict([
            ('name', self.name),
            ('desc', self.desc),
            ('tracker', self.tracker),
            ('evalType', self.evalType),
            ('seqs', self.seqs),
            ('overlap', self.overlap),
            ('error', self.error),
            ('overlapScores', self.overlapScores),
            ('errorNum', self.errorNum),
            ('successRateList', self.successRateList),
            ('precisionList', self.precisionList)])

    def __lt__(self, other):
        return self.name < other.name

    @staticmethod
    def getScoreFromLine(line):
        # Input Example : "DEF  Deformation - non-rigid object deformation."
        attr = line.strip().split('\t')
        name = attr[0]
        desc = attr[1]
        return Score(name, desc)

##########################################################

def getScoreList():
    srcAttrFile = open(SEQ_SRC + ATTR_DESC_FILE)
    attrLines = srcAttrFile.readlines()
    attrList = []
    for line in attrLines:
        attr = Score.getScoreFromLine(line)
        attrList.append(attr)
    return attrList