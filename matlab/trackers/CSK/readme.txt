
This MATLAB code implements a GUI for the tracking algorithm described in:


João F. Henriques, Rui Caseiro, Pedro Martins, and Jorge Batista,
"Exploiting the Circulant Structure of Tracking-by-detection with Kernels,"
ECCV, 2012.


It is free for research use. If you find it useful, please acknowledge the
paper above with a reference.

The main script for tracking is "run_tracker.m". It should work with any
recent version of MATLAB (eg., 2009a and above). It only requires the
Signal Processing toolbox, which is fairly standard.

You probably want to change the value of "base_path" at the top of the main
script to your videos' location. Each video is a folder with appropriate
files, in MILTrack's format. They can be downloaded from:
http://vision.ucsd.edu/~bbabenko/project_miltrack.shtml

Alternatively, you can use any folder with PNG images as a video. It must
contain a text file in MILTrack's ground truth format, with bounding box
coordinates for at least the first frame, to initialize the tracker.


João F. Henriques, 2012
http://www.isr.uc.pt/~henriques/

