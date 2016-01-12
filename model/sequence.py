from collections import OrderedDict
from config import *

##########################################################

class Sequence:

    def __init__(self, name, path, startFrame, endFrame, attributes, 
        nz, ext, imgFormat, gtRect, init_rect):
        self.name = name
        self.path = path
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.attributes = attributes
        self.nz = nz
        self.ext = ext
        self.imgFormat = imgFormat
        self.gtRect = gtRect
        self.init_rect = init_rect
        self.__dict__ = OrderedDict([
            ('name', self.name),
            ('path', self.path),
            ('startFrame', self.startFrame),
            ('endFrame', self.endFrame),
            ('attributes', self.attributes),
            ('nz', self.nz),
            ('ext', self.ext),
            ('imgFormat', self.imgFormat),
            ('init_rect', self.init_rect),
            ('gtRect', self.gtRect)])



##########################################################