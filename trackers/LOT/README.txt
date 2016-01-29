Locally Orderless Tracking 

http://www.eng.tau.ac.il/~oron/LOT/LOT.html

==============================

We distribute our implementation for Locally Orderless Tracking (LOT) under the GNU-GPL license.
We include complied Mex files for Windows 32bit adn 64bit as well as all source files required for compilation on additional platforms.
Related Publication:
 [1] Locally Orderless Tracking. 
     Shaul Oron, Aharon Bar-Hillel, Dan Levi and Shai Avidan
	 Computer Vision and Pattern Recognition 2012

When using this code for academic purposes please cite [1].

Getting started
===============
	1) Unzip the archive
	2) Open Matlab 
	3) If you have matlab parallel toolbox run matlabpool before starting for better performance
	4) Open and run LocallyOrderlessTracking.m (from the "source" directory)
    5) A figure showing the first frame of the provided example sequence will open 
       Mark the target (face) with a rectangle and double-click to start tracking
       Tracking results will be displayed in a new figure window
    6) To track your own video you can edit loadDefaultParams.m and change param.inputDir
	
	*) Full documentation is provided in the "documetation" directory.

Re-distributions
=================	
 The code provided here also uses and incluedes a re-distribution of the following code:
 - EMD mex downloaded from: http://www.mathworks.com/matlabcentral/fileexchange/12936-emd-earth-movers-distance-mex-interface
	Which is based on:
	[2] A Metric for Distributions with Applications to Image Databases. 
		Y. Rubner, C. Tomasi, and L. J. Guibas.  ICCV 1998
	See also: http://ai.stanford.edu/~rubner/emd/default.htm
 - Turbopixels downloaded from: http://www.cs.toronto.edu/~babalex/research.html
	which is based on is based on:
	[3] TurboPixels: Fast Superpixels Using Geometric Flows. 
		Alex Levinshtein, Adrian Stere, Kiriakos N. Kutulakos, David J. Fleet, Sven J. Dickinson, and Kaleem Siddiqi. TPAMI 2009

		
Copyright (c) Shaul Oron,  Computer Vision Lab, Faculty of Engineering, Tel-Aviv University, Israel  <shauloro@post.tau.ac.il>
Last Updated: 19/04/2012


