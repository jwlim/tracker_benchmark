
This software is an imaplentation of the tracking method described in MEEM: Robust Tracking via Multiple Experts using Entropy Minimization", Jianming Zhang, Shugao Ma, Stan Sclaroff, ECCV, 2014.

The code is maintained by Jianming Zhang. If you have questions, please contact jimmie33@gmail.com


Aug. 2014


This code has been tested on 64-bit Windows with OpenCV 2.40+.


Installation:

0. You should have OpenCV 2.40+ installed.
1. Unzip the files to <install_dir>.
2. Launch Matlab.
3. Go to <install_dir>\mex, and open "compile.m".
4. Change the OpenCV inlude and lib directory to yours, ans save.
5. run "compile" in Matlab.
4. Go back to <install_dir>, and run "demo".


How to use:

result = MEEMTrack(input, ext, show_img, init_rect, start_frame, end_frame)

@result: a struct containing the information about the tracking result.
@input: input image sequence directory.
@ext: image extention, e.g. "jpg".
@show_imag: 1 for display result frame by frame, 0 for quiet mode.
@init_rect: (optional) [x y w h]. If not specified, you need to manually draw the initial bounding box.
@start_frame: (optional) starting frame number.
@end_frame: (optional) ending frame number.

If show_img = 1, then you can exit the tracking by press any key.

Tracking results are represented by blue bounding boxes if no restoration happens. If restoration occurs, the result before the restoration is shown in red, and the result after the restoration is shown in yellow. The larger red window shows the searching area. 


Comment:

1. The tracking bounding box can be shaky even when object is still. This is due to the grid sampling process used in our code. For better visualization, you may want post-process the trajectory by slightly smoothing it.
2. We find that on different machines, this code can generate different results. The differences are usually very small. We suspect that this is caused by the differences in the numeric errors of some matlab functions. However, on a couple of long sequences, the tracking results can be substantially different at the end due to the "butterfly effects". This again suggests the importance of spatial robustness evluation, where the intialization is slightly changed for each run, so that the scores will not be too sensitive to small purturbations.


Changelog:

10.03.2014: Removed the svmtrain_my.m and related files, which caused compatility issues in different versions of Matlab. The original purpose of using svmtrain_my.m was to suppress some solver errors (e.g. convergence-condition-not-met error) that can interrupt the tracking. 
