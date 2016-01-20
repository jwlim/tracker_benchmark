#include <math.h>
#include "mex.h"
// compute integral img
// s(i,j) = s(i-1,j)+i(i,j)
// ii(i,j) = ii(i,j-1)+s(i,j)
// s(i,j) = s(i+j*M);
// s(0,j) = i(0,j);ii(i,0)=s(i,0)
/* Input Arguments */

#define	img_IN	prhs[0]

/* Output Arguments */

#define	ii_OUT	plhs[0]


static void integral(
				   double	ii[],
				   double	*img,
				   int M,
				   int N)
{
	int i;
	int j;
	double *s = new double[M*N];

	for(j=0; j<N; j++)
	{
		s[j*M] = img[j*M];
		for(i=1; i<M; i++)
		{
			s[i+j*M] = s[i-1+j*M] + img[i+j*M];
		}

	}
	

	for(i=0; i<M; i++)
	{
		ii[i] = s[i];
		for(j=1; j<N; j++)
		{
			
			ii[i+j*M] = ii[i+(j-1)*M] + s[i+j*M];

		}
	}

		
	delete []s;
	return;
}

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray*prhs[] )

{ 
	double *ii; 
	double *img; 
	mwSize M,N; 


	/* Check the dimensions of Y.  Y can be 4 X 1 or 1 X 4. */ 

	M = mxGetM(img_IN); 
	N = mxGetN(img_IN);
	

	/* Create a matrix for the return argument */ 
	ii_OUT = mxCreateDoubleMatrix(M, N, mxREAL); 

	/* Assign pointers to the various parameters */ 
	ii = mxGetPr(ii_OUT);

	img = mxGetPr(img_IN); 
	
	/* Do the actual computations in a subroutine */
	integral(ii,img, M, N); 
	return;

}