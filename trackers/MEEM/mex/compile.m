% make the mex file for Windows system
% Jianming Zhang
% 9/14/2013

function compile()

% set the values
opts.opencv_include_path    =   'D:\opencv2411\build\include'; % OpenCV include path
opts.opencv_lib_path        =   'D:\opencv2411\build\x64\vc12\lib'; % OpenCV lib path
opts.clean                  =   false; % clean mode
opts.dryrun                 =   false; % dry run mode
opts.verbose                =   1; % output verbosity
opts.debug                  =   false; % enable debug symbols in MEX-files


% Clean
if opts.clean
    if opts.verbose > 0
        fprintf('Cleaning all generated files...\n');
    end

    cmd = fullfile(['*.' mexext]);
    if opts.verbose > 0, disp(cmd); end
    if ~opts.dryrun, delete(cmd); end

    cmd = fullfile('*.obj');
    if opts.verbose > 0, disp(cmd); end
    if ~opts.dryrun, delete(cmd); end

    return;
end

% compile flags
[cv_cflags,cv_libs] = pkg_config(opts);
mex_flags = sprintf('%s %s', cv_cflags, cv_libs);
if opts.verbose > 1
    mex_flags = ['-v ' mex_flags];    % verbose mex output
end
if opts.debug
    mex_flags = ['-g ' mex_flags];    % debug vs. optimized builds
end
compstr = computer;
is64bit = strcmp(compstr(end-1:end),'64');
if (is64bit)
  mex_flags = ['-largeArrayDims ' mex_flags];
end

% Compile im2colstep.c
src = 'im2colstep.c';
cmd = sprintf('mex %s %s', mex_flags, src);
if opts.verbose > 0, disp(cmd); end
if ~opts.dryrun, eval(cmd); end

% Compile MxArray and BMS
src = 'MxArray.cpp';
   
cmd = sprintf('mex %s -c %s', mex_flags, src);
if opts.verbose > 0, disp(cmd); end
if ~opts.dryrun, eval(cmd); end

src = {'resize.cpp' 'calcIIF.cpp'};
% Compile the mex file
for i = 1:numel(src)
    obj = 'MxArray.obj';
    cmd = sprintf('mex %s %s %s', mex_flags, src{i}, obj);
    if opts.verbose > 0, disp(cmd); end
    if ~opts.dryrun, eval(cmd); end
end

end

%
% Helper functions for windows
%
function [cflags,libs] = pkg_config(opts)
    %PKG_CONFIG  constructs OpenCV-related option flags for Windows
    I_path = opts.opencv_include_path;
    L_path = opts.opencv_lib_path;
    l_options = strcat({' -l'}, lib_names(L_path));
    if opts.debug
        l_options = strcat(l_options,'d');    % link against debug binaries
    end
    l_options = [l_options{:}];

    if ~exist(I_path,'dir')
        error('OpenCV include path not found: %s', I_path);
    end
    if ~exist(L_path,'dir')
        error('OpenCV library path not found: %s', L_path);
    end

    cflags = sprintf('-I''%s''', I_path);
    libs = sprintf('-L''%s'' %s', L_path, l_options);
end

function l = lib_names(L_path)
    %LIB_NAMES  return library names
    d = dir( fullfile(L_path,'opencv_*.lib') );
    l = regexp({d.name}, '(opencv_core.+)\.lib|(opencv_imgproc.+)\.lib|(opencv_highgui.+)\.lib', 'tokens', 'once');
    l = [l{:}]
end