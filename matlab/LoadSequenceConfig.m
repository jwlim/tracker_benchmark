
function [seqs, seq_map] = LoadSequenceConfig(seq_names, varargin)
%
% LoadSequenceConfig
% - loads the sequence config structs for the given sequence names or
%   attribute names.
%
% Usage:
% [seq, seq_map] = LoadSequenceConfig(seq_name, ...)
% - seq_names : a string or a cell array of strings with attribute or
%       sequence names.
% - seqs : the array of loaded sequence config structures.
%       If multiple names are given, the sequence lists are merged to only
%       contain unique sequence configs. To find which sequence corresponds
%       to which given name use seq_map.
% - seq_map : a cell array with the same size of the input seq_name,
%       containing the index of sequences with the attribute.
%
% Sequence config structure:
% - name : the unique name of the sequence.
% - img_filename_fmt : the printf-formatted path of image files within the
%       data directory.
% - img_range_str : a matlab-format index string of image index range.
% - images_url : a URL for downloading the image files.
% - annotations : the attributes annotated to the test sequence.
% - gt_rect : the ground-truth bounding boxes (x, y, width, height).
% - gt_rect_range_str : the index range of the ground-truth bounding boxes.
% - img_filepath_fmt : the printf-formatted path to the image files.
%
% Options:
% - data_dir : the directory containing the test sequences. (default: '../data')
% - download_images : if set true, downloads and unzip the images.
%       (default: false)

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)


global SEQUENCE_ANNOTATIONS;
if isempty(SEQUENCE_ANNOTATIONS)
  error('SEQUENCE_ANNOTATIONS is not set. Run ScanSequences first');
end

%- Process options.
if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  for i = 1:2:numel(varargin), opt.(varargin{i}) = varargin{i + 1}; end;
end
if ~isfield(opt, 'data_dir'), opt.data_dir = '../data'; end;
if ~isfield(opt, 'download_images'), opt.download_images = false; end;

[seq_names, seq_map] = FindSequenceNames(seq_names);

for i = 1:numel(seq_names)
  seq_name = seq_names{i};
  seq_idx = 1;
  
  tok = regexp(seq_name, '([^.]*)[.]?(.*)', 'tokens');
  if ~isempty(tok{1}{2})
    seq_name = tok{1}{1};
    seq_idx = str2double(tok{1}{2});
  end
  
  seq_dir_path = [opt.data_dir '/' seq_name];
  seq_mat = load([seq_dir_path '/cfg.mat']);
  if ~isfield(seq_mat, 'seq')
    error(['invalid cfg.mat in ' seq_dir_path ' - no seq field.']);
  end
  seq = seq_mat.seq(seq_idx);
  seq.img_filepath_fmt = [seq_dir_path '/' seq.img_filename_fmt];
  seqs(i) = seq;
  
  if isfield(opt, 'download_images') && opt.download_images
    if ~isfield(seq, 'images_url') || isempty(seq.images_url)
      error('seq.images_url is not given or empty.');
    end
    disp(['downloading ' seq_name '.zip from ' seq.images_url '...' ]);
    zip_filepath = [opt.data_dir '/' seq_name '.zip'];
    urlwrite(seq.images_url, zip_filepath);
    disp(['extracting ' seq_name '.zip to ' opt.data_dir '...' ]);
    unzip(zip_filepath, opt.data_dir);
  end
end

end
