This code is a MATLAB implementation of the tracking algorithm described in CVPR 2012 paper 
        "Robust Object Tracking via Sparsity-based Collaborative Model" 
               by Wei Zhong, Huchuan Lu and Ming-Hsuan Yang.


***********************************************************************
The code runs on Windows XP with MATLAB R2009b.

Main MATLAB files:
  trackparam.m : load a dataset and sets parameters up
  demo.m : run tracking

Edit the variable 'title' in trackparam.m for different sequences, and run demo.m.

Datasets available:
'animal';
'board';
'car11';
'caviar';
'faceocc2';
'girl';
'jumping';
'panda';
'shaking';
'singer1';
'stone';


***********************************************************************
Thanks to Jongwoo Lim and David Ross. The affine transformation part is derived from their code for "Incremental Learning for Robust Visual Tracking" (IJCV 2008) by David Ross, Jongwoo Lim, Ruei-Sung Lin and Ming-Hsuan Yang.

Thanks to Fan Yang. The k-means part is derived from their code for "Bag of Features Tracking" (ICPR 2010) by Fan Yang, Huchuan Lu and Yen-Wei Chen.

The implementation uses the following SPAM software package: SPArse Modeling Software
http://www.di.ens.fr/willow/SPAMS/downloads.html
J. Mairal, F. Bach, J. Ponce and G. Sapiro. Online Learning for Matrix Factorization and Sparse Coding. Journal of Machine Learning Research, volume 11, pages 19-60. 2010.
J. Mairal, F. Bach, J. Ponce and G. Sapiro. Online Dictionary Learning for Sparse Coding. International Conference on Machine Learning, Montreal, Canada, 2009


***********************************************************************
This is the version 1 of the distribution. We appreciate any comments/suggestions. For more quetions, please contact us at zhongwei.dut@gmail.com or lhchuan@dlut.edu.cn or mhyang@ucmerced.edu.
	
Wei Zhong, Huchuan Lu and Ming-Hsuan Yang 
May 2012