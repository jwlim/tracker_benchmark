import urllib2
import zipfile
import shutil

from config import *
from model.sequence import Sequence

def setup_seqs(loadSeqs):
    seqs = make_seq_configs(loadSeqs)
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

def make_seq_configs(loadSeqs):
    if loadSeqs == 'ALL':
        names =  os.listdir(SEQ_SRC)
    else:
        names = loadSeqs
    seqList = []
    for name in names:  
        src = SEQ_SRC + name
        imgSrc = src + '/img/'
        
        path = imgSrc
        
        if not os.path.exists(imgSrc):
            print name + ' does not have img directory'
            if DOWNLOAD_SEQS:
                download_sequence(name)
            else:
                print 'If you want to download sequences,\n' \
                    + 'check if config.py\'s DOWNLOAD_SEQS is True'
                sys.exit(1)

        imgfiles = os.listdir(imgSrc)
        imgfiles = [x for x in imgfiles if x.split('.')[1] in ['jpg', 'png']]
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
            elif ' ' in line:
                gtRect.append(map(int,line.strip().split(' ')))

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

def download_sequence(seqName):
    file_name = SEQ_SRC + seqName + '.zip'

    if seqName == 'Jogging2':
        src = SEQ_SRC + 'Jogging/'
        dst = SEQ_SRC + 'Jogging2/'
        if os.path.exists(src + 'img'):
            shutil.copytree(src + 'img', dst + 'img')
            shutil.move(src + 'groundtruth_rect.2.txt', dst + GT_FILE)
        else:
            url = DOWNLOAD_URL.format('Jogging')
            download_and_extract_file(url, file_name, SEQ_SRC)
            shutil.copytree(src + 'img', dst + 'img')
            shutil.move(src + 'groundtruth_rect.2.txt', dst + GT_FILE)
            os.rename(src + 'groundtruth_rect.1.txt', src + GT_FILE)

    elif seqName == 'Skating2-1' or seqName == 'Skating2-2':
        url = DOWNLOAD_URL.format('Skating2')
        download_and_extract_file(url, file_name, SEQ_SRC)
        src = SEQ_SRC + 'Skating2/'
        dst1 = SEQ_SRC + 'Skating2-1/'
        dst2 = SEQ_SRC + 'Skating2-2/'
        if not os.path.exists(dst1 + 'img'):
            shutil.copytree(src + 'img', dst1 + 'img')
        if not os.path.exists(dst2 + 'img'):
            shutil.copytree(src + 'img', dst2 + 'img')
        shutil.move(src + 'groundtruth_rect.1.txt', dst1 + GT_FILE)
        shutil.move(src + 'groundtruth_rect.2.txt', dst2 + GT_FILE)
        shutil.rmtree(src)

    elif seqName == 'Human4-1' or seqName == 'Human4-2':
        url = DOWNLOAD_URL.format('Human4')
        download_and_extract_file(url, file_name, SEQ_SRC)
        src = SEQ_SRC + 'Human4/'
        dst1 = SEQ_SRC + 'Human4-1/'
        dst2 = SEQ_SRC + 'Human4-2/'
        if not os.path.exists(dst1 + 'img'):
            shutil.copytree(src + 'img', dst1 + 'img')
        if not os.path.exists(dst2 + 'img'):
            shutil.copytree(src + 'img', dst2 + 'img')
        shutil.move(src + 'groundtruth_rect.1.txt', dst1 + GT_FILE)
        shutil.move(src + 'groundtruth_rect.2.txt', dst2 + GT_FILE)
        shutil.rmtree(src)

    else:
        url = DOWNLOAD_URL.format(seqName)
        download_and_extract_file(url, file_name, SEQ_SRC)
   
    if seqName == 'Jogging':
        src = SEQ_SRC + 'Jogging/'
        gtfile = src + 'groundtruth_rect.1.txt'
        os.rename(gtfile, src + GT_FILE)

    if os.path.exists(SEQ_SRC + '__MACOSX'):
        shutil.rmtree(SEQ_SRC + '__MACOSX')


def download_and_extract_file(url, dst, ext_dst):  
    try:
        print 'Connecting to {0} ...'.format(url)
        u = urllib2.urlopen(url)
    except:
        print 'Cannot download {0} : {1}'.format(
            url.split('/')[-1], sys.exc_info()[1])
        sys.exit(1)
    f = open(dst, 'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    print "Downloading {0} ({1} Bytes)..".format(url.split('/')[-1], file_size)
    file_size_dl = 0
    block_sz = 8192
    while True:
        buffer = u.read(block_sz)
        if not buffer:
            break

        file_size_dl += len(buffer)
        f.write(buffer)
        status = r"{0:d} ({1:3.2f}%)".format(
            file_size_dl, file_size_dl * 100. / file_size)
        status = status + chr(8)*(len(status)+1)
        print status,
    f.close()

    f = open(dst, 'rb')
    z = zipfile.ZipFile(f)
    print '\nExtracting {0}...'.format(url.split('/')[-1])
    z.extractall(ext_dst)
    f.close()
    os.remove(dst)