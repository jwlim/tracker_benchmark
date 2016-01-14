from config import *
from model.sequence import Sequence

def setup_seqs():
    seqs = make_seq_configs()
    for seq in seqs:
        print "\t" + seq.name + "\t" + seq.path
        save_seq_config(seq)

def save_seq_config(seq):
    string = json.dumps(seq.__dict__, indent=2)
    src = os.path.join(SEQ_SRC, seq.name)
    configFile = open(src+'/cfg.json', 'wb')
    configFile.write(string)
    configFile.close()

def load_seq_config(seqName):
    src = os.path.join(SEQ_SRC, seqName)
    configFile = open(src+'/cfg.json')
    string = configFile.read()
    j = json.loads(string)
    seq = Sequence(**j)
    seq.path = os.path.join(os.path.abspath(seq.path), '')
    return seq

def load_all_seq_configs():
    seqNames = os.listdir(SEQ_SRC)
    seqs = []
    for name in seqNames:
        seq = load_seq_config(name)
        seqs.append(seq)
    return seqs

def make_seq_configs():
    names =  os.listdir(SEQ_SRC)
    seqList = []
    for name in names:  
        src = SEQ_SRC + name
        imgSrc = src + '/img/'
        
        path = imgSrc
        
        if not os.path.exists(imgSrc):
            sys.exit(name + ' does not have /img directory.')

        imgfiles = os.listdir(imgSrc)
        nz, ext, startFrame, endFrame = get_format(name, imgfiles)
        
        attrSrc = os.path.join(src, 'attrs.txt')
        if not os.path.exists(attrSrc):
            attrlist_src = os.path.join(ATTR_SRC, 'attrlist.txt')
            attrlistFile = open(attrlist_src)
            lines = attrlistFile.readlines()
            attrs = None
            for line in lines:
                if name in line:
                    attrs = line.split('\t')[1]
                    attrFile = open(attrSrc, 'w')
                    attrFile.write(attrs)
                    attrFile.close()
                    break
            if attrs == None:
                sys.exit(name + ' does not have attrlist')
                
        attrFile = open(attrSrc)
        lines = attrFile.readline()
        attributes = lines.split(', ')

        imgFormat = "{0}{1}{2}{3}".format("{0:0",nz,"d}.",ext)

        gtFile = open(os.path.join(src, GT_FILE))
        gtLines = gtFile.readlines()
        gtRect = []
        for line in gtLines:
            if '\t' in line:
                gtRect.append(map(int,line.strip().split('\t')))
            elif ',' in line:
                gtRect.append(map(int,line.strip().split(',')))

        init_rect = [0,0,0,0]
        seq = Sequence(name, path, startFrame, endFrame,
            attributes, nz, ext, imgFormat, gtRect, init_rect)
        seqList.append(seq)
    return seqList

def get_format(name, imgfiles):
    filenames = imgfiles[0].split('.')
    nz = len(filenames[0])
    ext = filenames[1]
    startFrame = int(filenames[0])
    endFrame = startFrame + len(imgfiles) - 1
    if name == "David":
        startFrame = 300
        endFrame = 770
    elif name == "Football1":
        endFrame = 74
    elif name == "Freeman3":
        endFrame = 460
    elif name == "Freeman4":
        endFrame = 283
    return nz, ext, startFrame, endFrame