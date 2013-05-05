
function seq = LoadSequenceConfig(seq_name, varargin)
%
% LoadSequenceConfig : load the config mat file for the test sequence.
%
% Usage:
%   seq = LoadSequenceConfig(seq_name, ...)
%     - load the config mat file for the test sequence 'seq_name'.
%
%   Output:
%   (from cfg.mat file)
%     - name : the sequence name string.
%     - imgfilename_fmt : the printf-formatted path to the test images.
%     - range_str : the matlab-formatted range string of frame indices.
%     - annotations : a cell array containing the annotation string.
%     - gt_rect : the ground-truth bounding boxes in all frames.
%   (generated)
%     - imgfilepath_fmt : the path format string of the test images.
%     - img_range : the frame index list.
%     - init_rect : the initial bounding box for tracking.
%
%   Options:
%     - 'data_dir': the directory containing the test sequences.
%           (default: '../data')

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)
%

if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct('data_dir', '../data');
  if ~isempty(varargin), opt = setfield(opt, varargin{:}); end;
end

seq_dir_path = [opt.data_dir '/' seq_name];
seq_mat = load([seq_dir_path '/cfg.mat']);
seq = seq_mat.cfg;

seq.imgfilepath_fmt = [seq_dir_path '/' seq.imgfilename_fmt];
seq.img_range = eval(seq.range_str);
seq.init_rect = seq.gt_rect(1,:);

end