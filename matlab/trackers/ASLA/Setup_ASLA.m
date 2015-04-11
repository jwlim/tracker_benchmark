
function Setup_ASLA()

if exist('interp2')
  disp('* mex function interp2 already exists...');
else
  disp('* buiding mex function interp2 ...');
  mex('-O', 'interp2.cpp');
end

end
