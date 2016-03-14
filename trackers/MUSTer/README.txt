This MATLAB code implements the MUlti-Store Tracker (MUSTer) [1]. The implementation is built upon the code provided by [2],[3],[4],[5],[6],[7]. The code provided by [4] is used for computing the HOG features. The code provided by [6] is used for computing the color name representation. The code provided by [7] is used for extracting SIFT features, feature matching and computing optical flow.  

Requirement:
If you are working on a Win64 PC, the code may be executed directly by:
1) Move *.dll into the work directory or add "*/MUSTer_code_v1/opencv" to your system path. 
Otherwise, install the packages as follows:
1) install opencv 2.4.6 required by mexopencv
2) setup mexopencv in the folder "mexopencv". Please follow the instruction in "http://kyamagu.github.io/mexopencv/".
3) compile "ICF/gradientMex.cpp" 

Instruction:
1) Run the "run_tracker.m" script in MATLAB.

Contact:
Zhibin Hong
zhib.hong@gmail.com

[1] Zhibin Hong, Zhe Chen, Chaohui Wang, Xue Mei, Danil Prokhorov, and Dacheng Tao. "MUlti-Store Tracker (MUSTer): a Cognitive Psychology Inspired Approach to Object Tracking". CVPR, 2015.

[2] Martin Danelljan, Gustav Häger, Fahad Shahbaz Khan and Michael Felsberg. "Accurate Scale Estimation for Robust Visual Tracking". BMVC, 2014.

[3] J. Henriques, R. Caseiro, P. Martins, and J. Batista. High-speed tracking with kernelized correlation filters. TPAMI, 2015.

[4] Piotr Dollár."Piotr’s Image and Video Matlab Toolbox (PMT)." http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html.

[5] Martin Danelljan, Fahad Shahbaz Khan, Michael Felsberg and Joost van de Weijer.
    "Adaptive Color Attributes for Real-Time Visual Tracking". CVPR, 2014.

[6] J. van de Weijer, C. Schmid, J. J. Verbeek, and D. Larlus. "Learning color names for real-world applications." TIP, 2009.

[7] Kota Yamaguchi. mexopencv: Collection and a development kit of matlab mex functions for OpenCV library. "http://kyamagu.github.io/mexopencv/"