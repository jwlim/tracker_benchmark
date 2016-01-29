Readme for paper "Real-Time Compressive Tracking," Kaihua Zhang, Lei Zhang, and Ming-Hsuan Yang, To appear in European Conference on Computer Vision (ECCV 2012), Florence, Italy, October, 2012
Author: Kaihua Zhang, HK POLYU
Email: zhkhua@gmail.com
Project website: http://www4.comp.polyu.edu.hk/~cslzhang/CT/CT.htm
---------------------------------------------------------------------------------------------------------------------------------------------
Note: The test MATLAB version is R2010a.
---------------------------------------------------------------------------------------------------------------------------------------------
Procedures
>Put the video sequences into file ¡®\data¡¯; 
>Initialize the position in the first frame in ¡®\data\init.txt¡¯; The setup has the format  [x y width height] where ¡°x,y ¡± are the coordinate of left top point of the rectangle.
> run ¡°mexCompile.m¡± to generate ¡°mex¡± files 
> run ¡°Runtracker.m¡±
The parameters in the main function ¡°Runtracker.m¡± can be tuned as follows
1.	¡°trparams.init_postrainrad¡± is the search radius for the positive sample; This parameter can be set 4~8. If the object moves very fast, a large parameter should be used to contain more positive samples.
2.	¡°trparams.srchwinsz¡± is the search radius for the search window at the new frame; This parameter can be set 15~35. If the object moves fast, a larger parameter should be used to contain the object.
3.	¡°lRate¡± is the learning rate parameter. This parameter can be set 0.7~0.95; If the object changes fast, a small ¡°lRate¡± should be used to weight more on the new frames.
4.	¡°ftrparams.maxNumRect¡± is the maximum number of nonzero entries at each row of the random matrix. The parameter can be set 4 or 6. If the appearance of the object varies much, 6 should be used to contain more discriminative features.
