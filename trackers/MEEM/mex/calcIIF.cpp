/**
 * @file calcIIF.cpp
 * @mex interface for IIF computation routine
 * @author Jianming Zhang
 * @date 2013
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;


Mat doWork(InputArray _src,Size ksize,int nbins)
{
	Mat src = _src.getMat();
	CV_Assert( src.type() == CV_8UC1 && nbins > 0 );
	
	vector<Mat> mv;
	Mat dst = Mat::zeros(src.size(),CV_8UC1);
	Mat mask = Mat::zeros(src.size(),CV_8UC1);

	int step = 256/nbins;
	for (int i = 0; i < nbins; i++)
	{
		Mat temp, temp_blr;
		inRange(src,Scalar(i*step),Scalar(i*step+step),temp);
		mask += temp;

		blur(temp, temp_blr, ksize, Point(-1,-1), BORDER_DEFAULT);
		dst += mask.mul(temp_blr,1/double(255));
	}
	return dst;
}








/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<3 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);


    // Option processing
    /*Size ksize(5,5);
    Point anchor(-1,-1);
    int borderType = BORDER_DEFAULT;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="KSize")
            ksize = rhs[i+1].toSize();
        else if (key=="Anchor")
            anchor = rhs[i+1].toPoint();
        else if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }**/
    
    // Process
	Mat src(rhs[0].toMat(CV_USRTYPE1,false));
	if (src.depth() != CV_8U)
		mexErrMsgIdAndTxt("mexopencv:error","Input Image must be uint8");
	Size ksize = rhs[1].toSize();
	int nbins = rhs[2].toInt();

	Mat dst = doWork(src,ksize,nbins);
    
    //blur(src, dst, ksize, anchor, borderType);
    plhs[0] = MxArray(dst, mxUNKNOWN_CLASS, false);
}