Matlab Version Tracker Testbed
version:	1.0
Date: 	03/29/2005

This application test the performance of various tracking algorithm. 

Include: (5 trackers)
	tkMeanshift_Init.dll
	tkMeanshift_Next.dll
	tkPeakDifference_Init.dll
	tkPeakDifference_Next.dll
	tkRatioShift_Init.dll
	tkRatioShift_Next.dll
	tkTemplateMatch_Init.dll
	tkTemplateMatch_Next.dll
	tkVarianceRatio_Init.dll
	tkVarianceRatio_Next.dll

Usage: 
	Please refer the "testtracker.m"
	Each tracker include two functions (dlls) below:

	1. [initModel] = tkXXX_Init(image, objectBox [,objectMask]);
	Initilize tracker on the first frame
		Inputs:
			image: 	3 channels and UINT8 input image for initial frame.
			objectBox:	Box around object in the order of [left right top bottom].
			objectMask:	(optional), mask to define object shape.
		Outputs:
			initModel:	object model, could be histogram or matix (type varied for different trackers).

	2. [targetBox, targetMask] = tkXXX_Next(initModel, image, candidateBox)
	Apply tracker on the following frame
		Inputs:
			initModel:	object model initialized on the first frame
			image: 	3 channels and UINT8 input image for next frame.
			objectBox:	candidate object Box to start search in the order of  [left right top bottom].
		Outputs:
			targetBox:	tracked target Box in the order of  [left right top bottom].
			targetMask:	mask to define target shape.


Required Library:(OpenCV)
 	cv096.dll
	cxcore096.dll
	highgui096.dll

		
