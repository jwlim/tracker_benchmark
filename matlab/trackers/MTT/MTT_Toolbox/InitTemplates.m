function [T,T_norm,T_mean,T_std] = InitTemplates(tsize, img_name, cpt)
% generate templates from single image
%   (r1,c1) ***** (r3,c3)            (1,1) ***** (1,cols)
%     *             *                  *           *
%      *             *       ----->     *           *
%       *             *                  *           *
%     (r2,c2) ***** (r4,c4)              (rows,1) **** (rows,cols)
% r1,r2,r3;
% c1,c2,c3

%% prepare templates geometric parameters
p{1}= cpt;
p{2} = cpt + [-1 0 0; 0 0 0];
p{3} = cpt + [1 0 0; 0 0 0];
p{4} = cpt + [0 -1 0; 0 0 0];
p{5} = cpt + [0 1 0; 0 0 0];
p{6} = cpt + [0 0 1; 0 0 0];
p{7} = cpt + [0 0 0; -1 0 0];
p{8} = cpt + [0 0 0; 1 0 0];
p{9} = cpt + [0 0 0; 0 -1 0];
p{10} = cpt + [0 0 0; 0 1 0];

 
%% Initializating templates and image
T	= zeros(prod(tsize),length(p));

% nz	= strcat('%0',num2str(numzeros),'d');
% image_no = sfno;
% fid = sprintf(nz, image_no);
% img_name = strcat(fprefix,fid,'.',fext);

img = imread(img_name);
if(size(img,3) == 3)
    img = double(rgb2gray(img));
end

%% cropping and normalizing templates
for n=1: length(p)
    [T(:,n),T_norm(n),T_mean(n),T_std(n)] = ...
		corner2image(img, p{n}, tsize);   
end