from collections import OrderedDict
from config import *

class Result:
    # tracker : trakcer name
    # seqName : Sequence name
    # startFrame : start frame number
    # endFrame : end frame number
    # res : results 
    # resType : result type

    def __init__(self, tracker, seqName, startFrame, endFrame, 
        resType, evalType, res, shiftType=None):
        self.tracker = tracker
        self.seqName = seqName
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.evalType = evalType
        self.shiftType = shiftType
        self.res = res
        self.resType = resType
        

        self.__dict__ = OrderedDict([
            ('tracker', self.tracker),
            ('seqName', self.seqName),
            ('startFrame', self.startFrame),
            ('endFrame', self.endFrame),
            ('evalType', self.evalType),
            ('shiftType', self.shiftType),
            ('resType', self.resType),
            ('res', self.res)])
        
        
