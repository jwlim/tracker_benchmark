% The make utility for all the C and MEX code

function make(command)

if (nargin > 0 && strcmp(command,'clean'))
    delete('*.mexglx');
    delete('*.mexw32');
    delete('lsmlib/*.mexglx');
    delete('lsmlib/*.mexw32');
    return;
end
mex   DT.cpp
mex   height_function_der.cpp
mex   height_function_grad.cpp
mex   local_min.cpp
mex   zero_crossing.cpp
mex   -lm get_full_speed.cpp
mex  corrDn.cpp wrap.cpp convolve.cpp edges.cpp
mex  upConv.cpp wrap.cpp convolve.cpp edges.cpp

cd lsmlib
mex   computeDistanceFunction2d.cpp FMM_Core.cpp FMM_Heap.cpp lsm_FMM_field_extension2d.cpp
mex   computeExtensionFields2d.cpp FMM_Core.cpp FMM_Heap.cpp lsm_FMM_field_extension2d.cpp
mex   doHomotopicThinning.cpp FMM_Core.cpp FMM_Heap.cpp lsm_FMM_field_extension2d.cpp
cd ..