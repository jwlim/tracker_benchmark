Please use the following syntax:

Context Tracker 2.1.exe [context] [save] [show] [random] [seq_name] [inp_dir] [out_dir] [startframe] [endframe] [strname_len] [img_format] [x] [y] [w] [h]

Where:
+ context: turn on/off context (0,1)  // I didn't check it so just stick with 1 for now
+ save: turn on/off save result image (0,1)
+ show: turn on/off show result image (0,1)
+ random: turn on/off random generation in the tracker (0,1)
+ seq_name: name of the test sequence
+ inp_dir: directory where the sequence is (without the seq_name)
+ out_dir: directory to output the result sequence // the seq_name directory will be created automatically inside this directory
+ startframe: index of the starting image frame // count from zero
+ endframe: index of the last image frame // count from zero
+ strname_len: the length of the image name without counting the extension, such as 0001.jpg will give the length of 4
+ img_format: the image format of the sequence // for example jpg
+ x,y,w,h: the initial bounding box with topleft corner (x,y) and size (w,h).
