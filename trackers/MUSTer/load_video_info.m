function [img_files, pos, target_sz, ground_truth, video_path] = load_video_info(video_path)

    text_files = dir([video_path 'groundtruth_rect.txt']);
    assert(~isempty(text_files), 'No initial position and ground truth (*_gt.txt) to load.')

    f = fopen([video_path text_files(1).name]);
    try
        ground_truth = textscan(f, '%f,%f,%f,%f', 'ReturnOnError',false);  
    catch   
        frewind(f);
        ground_truth = textscan(f, '%f %f %f %f');  
    end
    ground_truth = cat(2, ground_truth{:});
    fclose(f);

    %set initial position and size

    target_sz = [ground_truth(1,3), ground_truth(1,4)];
    pos = [ground_truth(1,1), ground_truth(1,2)];
 
	%for these sequences, we must limit ourselves to a range of frames.
	%for all others, we just load all png/jpg files in the folder.
	img_files = dir([video_path 'img/*.jpg']);
    if numel(img_files) == 0
        img_files = dir([video_path 'img/*.png']);
    end
	img_files = sort({img_files.name});

    video_path = [video_path 'img/'];

end

