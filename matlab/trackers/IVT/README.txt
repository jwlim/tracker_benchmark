README.txt  (May 25, 2007)
--------------------------

This code is a Matlab implementation of the tracking algorithm
described in "Incremental Learning for Robust Visual Tracking" by
Ross, Lim, Lin, and Yang (2007).

Questions regarding the code may be directed to Jongwoo Lim
(jlim@honda-ri.com) or David Ross (dross@cs.toronto.edu), but first
check the FAQ below.

The data files required to run the experiments may be obtained at
http://www.cs.toronto.edu/~dross/ivt/.  They are available in
both Matlab 7 (.mat) and Matlab 6.x (v6.mat) formats.  Download the
desired data files and save them to the directory that trackparam.m
lives in.

Matlab script file to start:
  trackparam.m : loads a dataset and sets parameters up
  trackparamv6.m : trackparam script for matlab version 6.x
  runtracker.m : run tracking
so you can try 'trackparam; runtracker;' in matlab command window.
By default it tracks the 'dudek' sequence, but this can be changed by
editing the 'title' variable in trackparam.

Matlab functions:
  sklm.m : incremental SVD algorithm
  estwarp_condens.m : CONDENSATION affine warp estiomator
  affparam*.m : affine parameter handling functions
  interp2.dll : faster implementation of matlab interp2 function

Data files available:
  davidin300.mat : an indoor sequence of a person with lighting, pose changes
  car11.mat, car4.mat : cars on the street
  dudek.mat : subsampled dudek sequence from [15]
  sylv.mat : a toy under high light
  trellis70.mat : an outdoor sequence
  fish.mat : a fish porcelaine
  toycan.mat : a toy robot and a soda can

---------------------------
FAQ: Frequently Asked Questions
----------------------------

Right now there is only one frequently asked question: 

1.  What do the functions affparam*.m do?

In trackparam.m we use one parametrization that is easy to create
manually, to specify the initial tracking window.

  p = [188,192,110,130,-0.08]

This means that the initial tracking window is centered at x=188,
y=192, is 110 pixels wide by 130 pixels tall, and is angled at -0.08
radians.  Since we do not specify a skew here, the initial window is a
(rotated) rectangle.

This parametrization is immediately via:

  param0 = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];

In this representation, the parameters are x-translation,
y-translation, global scale, rotation angle, aspect ratio, and scaling
angle.  In this representation, instead of having a scale factor for x
and one for y, the entire object is scaled by p(3)/32, then the y-axis
is scaled by the aspect ratio p(4)/p(3).  The global scale is divided
by 32 because our tracking window is always 32 pixels by 32 pixels (in
runtracker.m we set opt.tmplsize = [32,32];).  If the "scaling angle"
is non-zero then the tracking window will be skewed.

The affparam2mat function takes this param0 representation and
converts it to a affine 2x3 transformation matrix.  (Somewhat
unituitively, this 2x3 matrix is reshaped to a 6x1 vector.)  The
affparam2geom function does the reverse conversion, from 2x3 matrix to
param0 format.

Given a set of affine parameters, affparaminv converts the parameters
for the inverse transformation...  I think.  Let this serve as an
example as to why you should comment your code.

The reference form which these functions were developed is the book
"Multiple View Geometry in Computer Vision" by Richard Hartley and
Andrew Zisserman.

