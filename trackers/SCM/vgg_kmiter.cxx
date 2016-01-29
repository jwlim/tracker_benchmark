#include "mex.h"
#include <float.h>
#include <memory.h>

// [CX', sse] = vgg_kmiter(X, CX)
//  X is DxN matrix of N D-dim points, stored in columns
//  CX is DxM matrix of M cluster centres
//  out:
//  CX' is DxM matrix of new cluster centres
//  sse is sum of squared distances to (old?) cluster centres

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	const double	*px, *pcx;
	double			*pcxp;

	int				npts, dim, nclus;
	const double	*X, *CX;
	double			*CXp, *psse, *CN;
	double			d, dmin;
	int				i, j, k, c;

	if (nrhs != 2)
		mexErrMsgTxt("two input arguments expected.");
	if (nlhs != 2)
		mexErrMsgTxt("two output arguments expected.");

	if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
		mxGetNumberOfDimensions(prhs[0]) != 2)
		mexErrMsgTxt("input 1 (X) must be a real double matrix");

	dim = mxGetM(prhs[0]);
	npts = mxGetN(prhs[0]);

	if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ||
		mxGetNumberOfDimensions(prhs[1]) != 2 ||
		mxGetM(prhs[1]) != dim)
		mexErrMsgTxt("input 2 (CX) must be a real double matrix compatible with input 1 (X)");

	nclus = mxGetN(prhs[1]);

	plhs[0] = mxCreateDoubleMatrix(dim, nclus, mxREAL);
	CXp = mxGetPr(plhs[0]);

	plhs[1] = mxCreateScalarDouble(0.0);
	psse = mxGetPr(plhs[1]);

	X = mxGetPr(prhs[0]);
	CX = mxGetPr(prhs[1]);

	CN = (double *) calloc(nclus, sizeof(double));

	memset(CXp, 0, dim * nclus * sizeof(double));

	for (i = 0, px = X; i < npts; i++, px += dim)
	{
		dmin = DBL_MAX;
		c = 0;
		for (j = 0, pcx = CX; j < nclus; j++, pcx += dim)
		{
			d = 0.0;
			for (k = 0; k < dim; k++)
				d += (px[k] - pcx[k]) * (px[k] - pcx[k]);
			if (d < dmin)
			{
				dmin = d;
				c = j;
			}
		}

		*psse += dmin;

		CN[c]++;
		pcxp = CXp + c * dim;
		for (k = 0; k < dim; k++)
			pcxp[k] += px[k];
	}

	for (j = 0, pcxp = CXp; j < nclus; j++, pcxp += dim)
	{
		if (CN[j])
		{
			for (k = 0; k < dim; k++)
				pcxp[k] /= CN[j];
		}
	}

	free(CN);
}
