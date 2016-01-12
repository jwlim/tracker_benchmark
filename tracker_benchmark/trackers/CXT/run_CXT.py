import subprocess
import sys

def run_CXT(tracker, exe, args):
    path = os.path.abspath(TRACKER_SRC + tracker)
    path = os.path.join(path, exe)
    command = [path] + map(str, args)
    subprocess.call(command)

if __name__ == "__main__":
    # tracker = 'CXT'
    # exe = 'CXT.exe'
    # seqs = butil.load_all_seq_configs()
    seqs = [butil.load_seq_config('Coke'), butil.load_seq_config('Bolt')]
    # resultPath = './results/';
    # for seq in seqs:
    #     x = seq.gtRect[0][0] - 1
    #     y = seq.gtRect[0][1] - 1
    #     w = seq.gtRect[0][2]
    #     h = seq.gtRect[0][3]
    #     args = ['1', '0', '0', '1', seq.name, seq.path, resultPath,
    #         seq.startFrame, seq.endFrame, seq.nz, seq.ext, x, y, w, h]
    #     run_tracker_win(tracker, exe, args)
    #     