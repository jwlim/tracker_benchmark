The data directory for tracker benchmark.

Each dataset should be in one directory named as the sequence name.
Initially the directory contains the image files and a text file containing
ground-truth bounding boxes.

With matlab/SaveSequenceConfig.m, you can make 'cfg.mat' for further tracking
evaulation task.
This cfg.mat contains basic information about the sequence, and ground-truth
bounding rectangles. This will be loaded in matlab/LoadAllSequenceConfig.m.

