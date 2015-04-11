This is an example code for the Multi-Task Tracking published in the following papers:

Tianzhu Zhang, Bernard Ghanem, Si Liu, Narendra Ahuja."Robust Visual Tracking via Multi-Task Sparse Learning", 
IEEE International Conference on Computer Vision and Pattern Recognition (CVPR Oral), 2012.

Tianzhu Zhang, Bernard Ghanem, Si Liu, Narendra Ahuja."Robust Visual Tracking via Structured Multi-Task Sparse Learning," 
International Journal of Computer Vision (IJCV), 2012.
 
If you use the code and compare with our MTT trackers, please cite the above two papers.

The main tracking function is in MTTrack_Demo.m. You can run this function to get tracking results on video car11. All the varialbes have been commented and self-explanatory. The result will be stored in the path "MTT_Results/"

To get much better results, you can attempt to change some parameters, such as sz_T for object size, rel_std_afnv for particles sampling, and m_theta for template update. 

We have three different trackers, denoted as L21, L11, L\infinity 1 (L01 in code). For more details, please refer to our papers.
 
The released code is the first version. Because the directors of our company think it is in conflict with a patent application, we cannot share the source code now. 
We compile the pcode to make it convenient for research. We appreciate any comments/suggestions. For more quetions, please contact us at tzzhang10@gmail.com. 

New version will be updated on: https://sites.google.com/site/zhangtianzhu2012/publications

The test platform is modified from the popular L1 tracker. Thank the authors Xue Mei and Haibin Ling.

In the new version, we output the speed per frame.
	
Last updated, Oct 17, 2012