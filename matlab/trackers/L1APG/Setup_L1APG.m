
function Setup_L1APG()

if exist('IMGaffine_c')
  disp('* mex function IMGaffine_c already exists...');
else
  disp('* buiding mex function IMGaffine_c ...');
  mex('-O', 'IMGaffine_c.c');
end

end
