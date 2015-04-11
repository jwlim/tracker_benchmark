This code is for the tracker published in the following paper.
Xu Jia, Huchuan Lu, and Ming-Hsuan Yang, Visual Tracking via Adaptive Structural Local Appearance Model, IEEE Conference on Computer Vision and Pattern Recognition (CVPR 2012), Providence, June, 2012

The code runs on Windows 7 with MATLAB 2009b.

The main tracking function is in tracker.m and the parameters related to image sequences are set in setTrackParam.m

The initial tracking uses two functions vl_kdtreebuild and vl_kdtreequery from the VLFeat open source library.

The formal tracking uses the following SPArse Modeling Software.
http://www.di.ens.fr/willow/SPAMS/downloads.html
J. Mairal, F. Bach, J. Ponce, and G. Sapiro. Online learning for matrix factorization and sparse coding. Journal of Machine Learning Research, 11:19¨C60, 2010.

The results are slightly sensitive to affine parameters. You may obtain better results by adjusting the parameters.  


This is the first version of code. We appreciate any comments/suggestions. For more quetions, please contact us via jiayushenyang@gmail.com, lhchuan@dlut.edu.cn or mhyang@ucmerced.edu.
	
Xu Jia, Huchuan Lu and Ming-Hsuan Yang 
April 2012