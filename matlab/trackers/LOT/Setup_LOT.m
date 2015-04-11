
function Setup_LOT()

if exist('emd_mex')
  disp('* mex function emd_mex already exists...');
else
  disp('* buiding mex function interp2 ...');
  mex -O emd/emd_mex.c emd/emd.c
end

end
