Trakcer Benchmark (Tested on python 2.7.10)

Usage
- Default (for all trackers, all sequences, all evaltypes(OPE, SRE, TRE))
    - command : python run_trackers.py

- For specific trackers, sequences, evaltypes    
    - command : python run_trackers.py -t "tracker" -s "sequence" -e "evaltype"
    - e.g. : python run_trackers.py -t IVT,TLD -s Couple,Crossing -e OPE,SRE)


Libraries
- Matlab Engine for python (only needed for executing matlab script files of trackers)

    http://kr.mathworks.com/help/matlab/matlab-engine-for-python.html
- matplotlib
- numpy
- Python Imaging Library (PIL)

    http://www.pythonware.com/products/pil/

Troubleshooting
- Segmentaion Fault when running 'python run_tracker.py ...' on MacOSX
    - Set DYLD_LIBRARY_PATH environment variable.
    - e.g.: export DYLD_LIBRARY_PATH=/usr/local/Cellar/python/2.7.11/Frameworks/Python.framework/Versions/Current/lib/:$DYLD_LIBRARY_PATH
