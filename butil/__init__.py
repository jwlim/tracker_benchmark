from config import *
from seq_config import *
from eval_results import *
from load_results import *
from shift_bbox import *
from split_seq import *

def d_to_f(x):
	return map(lambda o:round(float(o),4), x)

def matlab_double_to_py_float(double):
	return map(d_to_f, double)