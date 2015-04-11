function init_pos = SelectTarget(sImg)
% Select initial position for a target to track
%		init_pos = SelectTarget(sImg)
% Input:
% Output:
%	init_pos - target selected by user (or automatically), it is a 2x3
%		matrix, such that each COLUMN is a point indicating a corner of the target
%		in the first image. Let [p1 p2 p3] be the three points, they are
%		used to determine the affine parameters of the target, as following
% 			  p1-------------------p3
% 				\					\
% 				 \       target      \
% 				  \                   \
% 				  p2-------------------\

%%
im	= imread(sImg);
figure;
imshow(im);	hold on;
title('Left click three corners of the target, top-left, bottom-left, and top-right.', 'FontSize', 14);
xlabel('Right click after done', 'FontSize', 14);

pos		= zeros(2,3);
btn		= -1;
count	= 0;
while btn~=3
    [x,y,btn]	= ginput(1);
    if btn==1
        if count==3
            imshow(im);	hold on;
            title('Left click three corners of the target, top-left, bottom-left, and top-right.', 'FontSize', 14);
            xlabel('Right click after done', 'FontSize', 14);
        end
        
        count	= mod(count,3)+1;
        pos(1,count)	= y;
        pos(2,count)	= x;
        
        errorTolerance = 4; %2 pixel error tolerance
        if(count == 2 &&  pos(1,2) < pos(1,1))%-errorTolerance)
            title('Error in selecting the second point. Please start over.', 'Color', 'r', 'FontSize', 14);
            return;
        elseif(count == 3 && (pos(2,3) < pos(2,1)-errorTolerance || pos(1,3) > pos(1,2)+errorTolerance)) %pos(2,3) < pos(2,2)-errorTolerance || 
            title('Error in selecting the third point. Please start over.', 'Color', 'r', 'FontSize', 14);
            return;
        end
        
        plot(pos(2,1:count), pos(1,1:count), 'r+','LineWidth',2);
        if count==3
            plot(pos(2,1:2), pos(1,1:2),'Color','blue','LineWidth',2);
            plot(pos(2,[1 3]), pos(1,[1 3]),'Color','blue','LineWidth',2);
            p4	= pos(:,2)+pos(:,3)-pos(:,1);
            plot([pos(2,2) p4(2)], [pos(1,2) p4(1)], 'Color','blue','LineWidth',2);
            plot([pos(2,3) p4(2)], [pos(1,3) p4(1)], 'Color','blue','LineWidth',2);
        end
    end
end

tsize = [15, 12];
afnv_obj = corners2afnv( pos, tsize);
%afnv_obj = corners2afnv( [r1,r2,r3;c1,c2,c3], tsize);
map_afnv = afnv_obj.afnv;
for i=1:size(im,3)
    img_map(:,:,i) = IMGaffine_r(im(:,:,i), map_afnv, tsize);
end
img_map = imresize(img_map, 2);
imshow(uint8(img_map));

if count==3
    init_pos	= pos;
else
    init_pos	= [];
end


