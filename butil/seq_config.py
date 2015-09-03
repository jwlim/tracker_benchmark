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

		imgNum = len(os.listdir(imgSrc))
		startFrame, endFrame = get_range(name, imgNum)
		
		attrSrc = os.path.join(src, 'attrs.txt')
		if not os.path.exists(attrSrc):
			sys.exit(name + ' does not have attr.txt')
		attrFile = open(attrSrc)
		lines = attrFile.readline()
		attributes = lines.split(', ')

		imgFormat = IMG_FORMAT

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
			attributes, imgFormat, gtRect, init_rect)
		seqList.append(seq)
	return seqList

def get_range(name, imgNum):
	if name == "David":
		return 300, 770
	elif name == "Football1":
		return 1, 74
	elif name == "Freeman3":
		return 1, 460
	elif name == "Freeman4":
		return 1, 283
	else :
		return 1, imgNum