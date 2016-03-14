 

addpath('mexopencv');

addpath('ICF');
base_path = './';
res_path = 'Results/';

name = 'Jogging';

video_path = [base_path name '/'];

[ source.img_files, pos, target_sz, ground_truth, source.video_path]...
 = load_video_info(video_path);
source.n_frames = numel(source.img_files);
rect_init = [pos, target_sz];

bboxes = MUSTer_tracking(source, rect_init);

dlmwrite([res_path name '.txt'], bboxes);

