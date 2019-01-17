from config import *
import scripts.butil
import subprocess

MDNET_PATH = '/home/chwon/challenge/py-MDNet'
MDNET_PATH = os.path.abspath(MDNET_PATH)

def run_MDNet(seq, rp, bSaveImage):
    tmp_res = os.path.join(MDNET_PATH, 'tmp_res.json')
    seq_config = {}
    seq_config['seq_name'] = seq.name
    seq_config['img_list'] = seq.s_frames
    seq_config['init_bbox'] = seq.init_rect
    seq_config['savefig_dir'] = ''
    seq_config['result_path'] = tmp_res
    
    tmp_config = os.path.join(MDNET_PATH, 'tmp_config.json')
    tmp_config_file = open(tmp_config, 'w')
    json.dump(seq_config, tmp_config_file, indent=2)
    tmp_config_file.close()

    curdir = os.path.abspath(os.getcwd())
    os.chdir(os.path.join(MDNET_PATH, 'tracking'))
    command = map(str,['python', 'run_tracker.py', '-j', tmp_config])
    subprocess.call(command)
    os.chdir(curdir)
    res = json.load(open(tmp_res, 'r'))
    os.remove(tmp_res)
    os.remove(tmp_config)
    return res
