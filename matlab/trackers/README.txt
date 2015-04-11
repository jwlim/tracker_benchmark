                                                                     
                                                                     
                                                                     
                                             
1.Setup for trackers
	*platform: Windows
	*the 5 vivid trackers and TLD can only run on 32 bit Matlab
	*ASLA depends on vlfeat
	*BSBT, BT, SBT, CPF, Frag, MSW, SMS depend on opencv 1.0
	*MIL depends on IPP 5.0 and opencv 1.0
	*ST (Struck) depends on opencv 1.0 and Eigen library
	*LSK depends on MATLAB Compiler Runtime (MCR) 7.16
		location: <matlabroot>\toolbox\compiler\deploy\win32\MCRInstaller.exe
	*CXT depends on opencv 2.4 and the DLLS are included
	*VTD and VTS have GUI so that they cannot be included in our library
		VTD: http://cv.snu.ac.kr/newhome/publication/code/VTD_EXE_V0.64_M.zip
		VTS: http://cv.snu.ac.kr/newhome/publication/code/VTS_EXE_V0.32_M.zip
2.main function
	*main_SRE.m is for the SRE test
	*main_TRE.m is for the TRE test
	*main_OPE.m is for the OPE test
		OPE is the first trial of TRE 
3.performance plots
	*perfPlot.m is for drawing plots
		NOT tested