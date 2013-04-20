// interp2.cpp
//
//   Copyright (C) Jongwoo Lim.
//   All rights reserved.
//
//////////////////////////////////////////////////////////////////////

#include "mex.h"
#include <math.h>

//#include "cvbase/cvimage.h"

#define ARR(A,r,c,nr,nc)  (((r)<0 || (r)>=(nr) || (c)<0 || (c)>=(nc))? 0 : (A)[(c)*(nr)+(r)])

inline double interp(double *img, int w, int h, double x, double y)
{
  register int x0 = (int) x, y0 = (int) y, x1 = x0+1, y1 = y0+1;
  register double rx0 = x-x0, rx1 = 1-rx0, ry = y-y0;
  return ((rx1*ARR(img,y0,x0,h,w) + rx0*ARR(img,y0,x1,h,w))*(1-ry) +
          (rx1*ARR(img,y1,x0,h,w) + rx0*ARR(img,y1,x1,h,w))*ry);
}

//-----------------------------------------------------------------------------

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  // check inputs
  if (nrhs < 3 || nrhs > 6)
    mexErrMsgTxt("invalid number of inputs: [x,y,]z,xi,yi[,method]");
  if (nlhs != 1)
    mexErrMsgTxt("invalid number of outputs: zi");

  const char *_argin[] = { "x","y","z","xi","yi","method" };
  const char **argin = (nrhs < 4)? &_argin[2] : _argin;
  char buf[1024];

  // Check input data
  const mxArray *X = NULL, *Y = NULL, *Z, *XI, *YI;
  if (nrhs < 4)
    Z = prhs[0], XI = prhs[1], YI = prhs[2];
  else
    X = prhs[0], Y = prhs[1], Z = prhs[2], XI = prhs[3], YI = prhs[4];

  if (nrhs == 4 || nrhs == 6)
    nrhs--;  // Ignore method

  for (int ri = 0; ri < nrhs; ri++) {
    if (!prhs[ri])
    { sprintf(buf,"invalid mxArray(%s)", argin[ri]);  mexErrMsgTxt(buf); }
    if (!mxIsDouble(prhs[ri]))
    { sprintf(buf,"data must be double (%s)", argin[ri]);  mexErrMsgTxt(buf); }
  }
  if (mxGetNumberOfDimensions(Z) != 2)
    mexErrMsgTxt("invalid Z dimension: should be 2");
  // Need to check whether dims of X,Y,Z matche
  if (mxGetNumberOfElements(XI) != mxGetNumberOfElements(YI))
    mexErrMsgTxt("XI and YI does not match");

  // Build output data
  const int *dimz = mxGetDimensions(Z), *dim = mxGetDimensions(XI);
  int ndim = mxGetNumberOfDimensions(XI);

  register double dx = -1, dy = -1, sx = 1, sy = 1;
  if (nrhs >= 4) {
    int nx = mxGetNumberOfElements(X), ny = mxGetNumberOfElements(Y);
    double *pX = mxGetPr(X), *pY = mxGetPr(Y);
    if (nx == dimz[1] && ny == dimz[0])
      dx = -pX[0], sx = (dimz[1]-1)/(pX[nx-1]-pX[0]),
      dy = -pY[0], sy = (dimz[0]-1)/(pY[ny-1]-pY[0]);
    else if (nx == ny && ny == mxGetNumberOfElements(Z))
      dx = -pX[0], sx = (dimz[1]-1)/(pX[(dimz[1]-1)*dimz[0]]-pX[0]),
      dy = -pY[0], sy = (dimz[0]-1)/(pY[dimz[0]-1]-pY[0]);
    else
      mexErrMsgTxt("X and Y do not match with Z");
  }
  if (mxIsComplex(Z)) {
    mxArray *ZI = plhs[0] = mxCreateNumericArray(ndim, dim, mxDOUBLE_CLASS, mxCOMPLEX);

    // Load input data and fill output array
    double *pZr = mxGetPr(Z), *pZi = mxGetPi(Z), *pXI = mxGetPr(XI), *pYI = mxGetPr(YI);
    double *pZIr = mxGetPr(ZI), *pZIi = mxGetPi(ZI);

//    cvImage<double> imgr(pZr, dimz[0], dimz[1]), imgi(pZi, dimz[0], dimz[1]);
    int h = dimz[0], w = dimz[1];
    for (int i = 0, n = mxGetNumberOfElements(XI); i < n; i++) {
      pZIr[i] = interp(pZr, w,h, sx*(pXI[i]+dx), sy*(pYI[i]+dy));
      pZIi[i] = interp(pZi, w,h, sx*(pXI[i]+dx), sy*(pYI[i]+dy));
//      cvtPoint<double> p(sy*(pYI[i]+dy),sx*(pXI[i]+dx));
//      pZIr[i] = imgr.interp<double,double>(p);
//      pZIi[i] = imgi.interp<double,double>(p);
    }
  }
  else {
    mxArray *ZI = plhs[0] = mxCreateNumericArray(ndim, dim, mxDOUBLE_CLASS, mxREAL);

    // Load input data and fill output array
    double *pZ = mxGetPr(Z), *pXI = mxGetPr(XI), *pYI = mxGetPr(YI);
    double *pZI = mxGetPr(ZI);

//    cvImage<double> img(pZ, dimz[0], dimz[1]);
    int h = dimz[0], w = dimz[1];
    for (int i = 0, n = mxGetNumberOfElements(XI); i < n; i++) {
      pZI[i] = interp(pZ, w,h, sx*(pXI[i]+dx), sy*(pYI[i]+dy));
//      cvtPoint<double> p(sy*(pYI[i]+dy),sx*(pXI[i]+dx));
//      pZI[i] = img.interp<double,double>(p);
    }
  }
}

//-----------------------------------------------------------------------------
