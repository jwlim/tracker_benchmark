function [px,py,pw,ph,pwt] = HaarFtr(clfparams,ftrparams,M)

% $Description:
%    -Compute harr feature
% $Agruments
% Input;
%    -clfparams: classifier parameters
%    -clfparams.width: width of search window 
%    -clfparams.height:height of search window
%    -ftrparams: feature parameters
%    -ftrparams.minNumRect: minimal number of feature rectangles
%    -ftrparams.maxNumRect: maximal ....
%    -M: totle number of features
% Output:
%    -px: x coordinate, size: M x ftrparms.maxNumRect
%    -py: y ...
%    -pw: corresponding width,size:...
%    -ph: corresponding height,size:...
%    -pwt:corresponding weight,size:....Range:[-1 1]
% $ History $
%   - Created by Kaihua Zhang, on April 22th, 2011
%
width = clfparams.width;
height = clfparams.height;

px = zeros(M,ftrparams.maxNumRect);
py = zeros(M,ftrparams.maxNumRect);
pw = zeros(M,ftrparams.maxNumRect);
ph = zeros(M,ftrparams.maxNumRect);
pwt= zeros(M,ftrparams.maxNumRect);

for i=1:M
     numrects = randi([ftrparams.minNumRect,ftrparams.maxNumRect]);
     for j = 1:numrects
        px(i,j) = randi([2,width-5]);
        py(i,j) = randi([2,height-5]);
        pw(i,j) = randi([2,width-px(i,j)-2]);
        ph(i,j) = randi([2,height-py(i,j)-2]);    
        pwt(i,j)= (-1)^randi(2);             
     end      
end
