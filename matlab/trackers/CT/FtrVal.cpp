#include <math.h>
#include "mex.h"
// compute integral img
// s(i,j) = s(i-1,j)+i(i,j)
// ii(i,j) = ii(i,j-1)+s(i,j)
// s(i,j) = s(i+j*M);
// s(0,j) = i(0,j);ii(i,0)=s(i,0)
/* Input Arguments */

/* Output Arguments */

static void getFtrVal(double samplesFtrVal[],double*iH,double *sx,double * sy,double *px, double *py, double *pw,
					  double *ph, double *pwt, int len_F,int len_S,int len_R,int M,int N)

{
   	int i,j,minJ,maxJ,minI,maxI;
    int m,k;
	int x,y;
    int *temp = new int[len_F];
	for(i=0;i<len_F; i++)
	{
	   m=0;
       for(j=0;j<len_R;j++)
	   {
		   if(px[i+j*len_F]!=0)
		   {
			   m = m+1;
		   }
		   else
		   {
			   break;
		   }

	   }
	   temp[i] = m;
	}

    for(i=0;i<len_F;i++)
       for(j=0;j<len_S;j++)
	   {
	     m = 0;
		 x = sx[j];
		 y = sy[j];

		 for(k=0;k<temp[i];k++)
		 {
			 minJ = x-1+px[i+k*len_F];
             maxJ = x-1+px[i+k*len_F]+pw[i+k*len_F]-1;
             minI = y-1+py[i+k*len_F];
             maxI = y-1+py[i+k*len_F]+ph[i+k*len_F]-1;

			 m = m+pwt[i+k*len_F]*(iH[minI+minJ*M]+iH[maxI+maxJ*M]
			 -iH[maxI+minJ*M]-iH[minI+maxJ*M]);

		 }
		 samplesFtrVal[i+j*len_F]=m;
	   }
   delete []temp;
       
}          
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray*prhs[] )

{ 
	double *iH,*sx,*sy,*px,*py,*pw,*ph,*pwt; 
	 		
    double *samplesFtrVal;

	mwSize len_F,len_S,len_R,M,N;

    int i,j,k,m1,n1,c;

	iH = mxGetPr(prhs[0]);
	sx = mxGetPr(prhs[1]);
	sy = mxGetPr(prhs[2]);
	px = mxGetPr(prhs[3]);//s.rect.x
	py = mxGetPr(prhs[4]);//s.rect.y
	pw = mxGetPr(prhs[5]);//s.rect.width
	ph = mxGetPr(prhs[6]);//s.rect.height
	pwt = mxGetPr(prhs[7]);//s.weight

	len_F = mxGetM(prhs[3]);
	len_S = mxGetN(prhs[1]);
	len_R = mxGetN(prhs[3]);


	M = mxGetM(prhs[0]); 
	N = mxGetN(prhs[0]);
	
    plhs[0] = mxCreateDoubleMatrix(len_F,len_S, mxREAL);

	samplesFtrVal = mxGetPr(plhs[0]);

	getFtrVal(samplesFtrVal,iH,sx,sy,px,py,pw,ph,pwt,len_F,len_S,len_R,M,N);
	    
	return;

}