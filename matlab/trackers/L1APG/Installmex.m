function Installmex 

   computer_model = computer;
   matlabversion = sscanf(version,'%f');
   matlabversion = matlabversion(1);
   tmp = version('-release'); 
   matlabrelease = str2num(tmp(1:4));
%%
   if strcmp(computer_model,'PCWIN')
      str1 = ['  ''',matlabroot,'\extern\lib\win32\microsoft\libmwlapack.lib''  ']; 
      str2 = ['  ''',matlabroot,'\extern\lib\win32\microsoft\libmwblas.lib''  '];
      libstr = [str1,str2];     
   elseif strcmp(computer_model,'PCWIN64')
      str1 = ['  ''',matlabroot,'\extern\lib\win64\microsoft\libmwlapack.lib''  ']; 
      str2 = ['  ''',matlabroot,'\extern\lib\win64\microsoft\libmwblas.lib''  '];
      libstr = [str1,str2];  
   else
      libstr = '  -lmwlapack -lmwblas  '; 
   end
   mexcmd = 'mex -O  -largeArrayDims  -output '; 
   
   curdir = pwd;  
   fprintf(' current directory is:  %s\n',curdir); 
   fprintf ('\n Now compiling the mexFunctions in:\n'); 
   %%
   fname{1} = 'IMGaffine_c';
   
   for k = 1:length(fname)
       cmd([mexcmd,fname{k},'  ',fname{k},'.c  ',libstr]);  
   end  
   
   function cmd(s) 
   
   fprintf(' %s\n',s); 
   eval(s); 