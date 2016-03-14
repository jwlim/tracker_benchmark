%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Implemetation of the tracker described in paper
%	"MEEM: Robust Tracking via Multiple Experts using Entropy Minimization", 
%   Jianming Zhang, Shugao Ma, Stan Sclaroff, ECCV, 2014
%	
%	Copyright (C) 2014 Jianming Zhang
%
%	This program is free software: you can redistribute it and/or modify
%	it under the terms of the GNU General Public License as published by
%	the Free Software Foundation, either version 3 of the License, or
%	(at your option) any later version.
%
%	This program is distributed in the hope that it will be useful,
%	but WITHOUT ANY WARRANTY; without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	GNU General Public License for more details.
%
%	You should have received a copy of the GNU General Public License
%	along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%	If you have problems about this software, please contact: jmzhang@bu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rect = rsz_rt(rect,bd_sz,scale,shift)
% @rect is the window in the scaled image
% @img_scale, the scale of the image
% returned roi should be in the scaled image

r = sqrt(prod(rect(3:4)));
if shift
    rect = round([rect(1)-0.5*scale*r,rect(2)-0.5*scale*r,rect(1)+1*rect(3)+...
        0.5*scale*r,rect(2)+1*rect(4)+0.5*scale*r]);
    % shift the rect so it will not go outside of the image
    x_shift = max([1-rect(1), 0]);
    if x_shift == 0, x_shift = min([bd_sz(2) - rect(3),0]); end
    y_shift = max([1-rect(2), 0]);
    if y_shift == 0, y_shift = min([bd_sz(1) - rect(4),0]); end

    rect([1,3]) = min(max(rect([1,3]) + x_shift,1),bd_sz(2));
    rect([2,4]) = min(max(rect([2,4]) + y_shift,1),bd_sz(1));
else
    rect = round([max([rect(1)-0.5*scale*r,1]),max([rect(2)-0.5*scale*r,1]),...
           min([rect(1)+1*rect(3)+0.5*scale*r,bd_sz(2)]),min([rect(2)+1*rect(4)+0.5*scale*r,bd_sz(1)])]);
end