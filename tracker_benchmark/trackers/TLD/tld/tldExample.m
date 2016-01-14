% Copyright 2011 Zdenek Kalal
%
% This file is part of TLD.
% 
% TLD is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.

function [bb,conf,fps] = tldExample(opt)

global tld; % holds results and temporal variables

% figure(2); 

source.im0 = img_alloc(opt.s_frames{1});
    
rect = opt.init_rect;
source.bb = [rect(1),rect(2),rect(1)+rect(3)-1,rect(2)+rect(4)-1]';
opt.source = source; 
opt.nFrames=length(opt.s_frames);

tld = tldInit(opt,[]); % train initial detector and initialize the 'tld' structure

if tld.bSaveImage
    figure(1)
    imshow(tld.img{1}.input);
    bb=tld.source.bb;
    rectangle('Position',[bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)],'LineWidth',4,'EdgeColor','r')
    text(10, 15, ['#' num2str(1)], 'Color','y', 'FontWeight','bold', 'FontSize',24);
    
    imwrite(frame2im(getframe(gcf)),[tld.output num2str(1) '.jpg']);
end

% RUN-TIME ----------------------------------------------------------------
totalTime=0;
for i = 2:length(opt.s_frames) % for every frame
    
%     disp(num2str(i));
    
    tld.img{i} = img_alloc(tld.s_frames{i});%img_get(tld.source,I); % grab frame from camera / load image
    
    tic
    tld = tldProcessFrame(tld,i); % process frame i
    totalTime=totalTime+toc;
    
    % display results on frame i


    if tld.bSaveImage
        imshow(tld.img{i}.input);
        text(10, 15, ['#' num2str(i)], 'Color','y', 'FontWeight','bold', 'FontSize',24);
        bb=tld.bb(:,i);
        if bb(3)-bb(1) > 0 && bb(4)-bb(2)>0
            rectangle('Position',[bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)],'LineWidth',4,'EdgeColor','r')

            drawnow
        end
%         imwrite(img.cdata,[tld.output num2str(i,'%05d') '.jpg']);
        imwrite(frame2im(getframe(gcf)),[tld.output num2str(i) '.jpg']);
    end      
end

bb = tld.bb; conf = tld.conf; % return results

fps = (opt.nFrames-1)/totalTime;

disp(['fps: ' num2str(fps)]);
