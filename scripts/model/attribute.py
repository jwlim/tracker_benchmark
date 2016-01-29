from collections import OrderedDict
from config import *

##########################################################
class Attribute:
    # name
    # desc
    # ovelapScores
    # errorNum
    # overlap
    # error
    # successRateList

    def __init__(self, name, desc, overlapScores, errorNum, 
        overlap, error, successRateList):
        self.name = name
        self.desc = desc
        self.overlapScores = overlapScores
        self.errorNum = errorNum
        self.overlap = overlap
        self.error = error
        self.successRateList = successRateList

        self.__dict__ = OrderedDict([
            ('name', self.name),
            ('desc', self.desc),
            ('overlap', self.overlap),
            ('error', self.error),
            ('overlapScores', self.overlapScores),
            ('errorNum', self.errorNum),
            ('successRateList', self.successRateList)])

    def __lt__(self, other):
        return self.name < other.name

    @staticmethod
    def getAttrFromLine(line):
        # Input Example : "DEF  Deformation - non-rigid object deformation."
        attr = line.strip().split('\t')
        name = attr[0]
        desc = attr[1]
        overlapScores = []
        errorNum = []
        overlap = 0
        error = 0
        successRateList = []
        return Attribute(name, desc, overlapScores, errorNum, 
            overlap, error, successRateList)

##########################################################

def getAttrList():
    srcAttrFile = open(SEQ_SRC + ATTR_DESC_FILE)
    attrLines = srcAttrFile.readlines()
    attrList = []
    for line in attrLines:
        attr = Attribute.getAttrFromLine(line)
        attrList.append(attr)
    return attrList