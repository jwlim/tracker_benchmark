
function Setup_CT()

if exist('integral')
  disp('* mex function integral already exists...');
else
  disp('* buiding mex function integral ...');
  mex('-O', 'integral.cpp');
end

if exist('FtrVal')
  disp('* mex function FtrVal already exists...');
else
  disp('* buiding mex function FtrVal ...');
  mex('-O', 'FtrVal.cpp');
end

end
