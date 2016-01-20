% ***********************************************************************
% Copyright (c) Laura Sevilla-Lara and Erik G. Learned-Miller, 2012.
% ***********************************************************************

function track2video(data, res_path, seq_name, s_frames, wsize, show_track)
    
linewidth = 2;
mov = avifile([res_path seq_name '_DFT.avi']);

for i=1:size(data, 1)
    im = double(imread(s_frames{i}));
    if size(im,3)==1
        im = cat(3, im, im, im);
    end
    % draw each of the rectangles
    im = uint8(drawRect(im, data(i, :), wsize, 'r', linewidth)); 
    if show_track
        imshow(im);
        pause(0.1);
    end;
    mov = addframe(mov, im);
end;
    
mov = close(mov);
    
    
    
