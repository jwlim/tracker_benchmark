
function [avail_seqs] = ScanSequences(varargin)
%
% ScanSequences
% - scans the test sequences in the data directory to find out the attributes.
%
% Usage:
% ScanSequences(...)
% [avail_seqs] = ScanSequences(...)
% - avail_seqs : a cell array of strings with available test sequence names.
%
% Options:
% - data_dir : the directory containing the test sequences. (default: '../data')

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)


global SEQUENCE_ANNOTATIONS;

%- Process options.
if numel(varargin) == 1 && isstruct(varargin{1})
  opt = varargin{1};
else
  opt = struct();
  if ~isempty(varargin), opt = setfield(opt, varargin{:}); end;
end
if ~isfield(opt, 'data_dir'), opt.data_dir = '../data'; end;
if ~isfield(opt, 'download_images'), opt.download_images = false; end;

SEQUENCE_ANNOTATIONS = struct();
SEQUENCE_ANNOTATIONS.attributes = {};

SEQUENCE_ANNOTATIONS.V11_100 = { ...
  'Basketball', 'Biker', 'Bird1', 'Bird2', 'BlurBody', 'BlurCar1', 'BlurCar2', ...
  'BlurCar3', 'BlurCar4', 'BlurFace', 'BlurOwl', 'Board', 'Bolt', 'Bolt2', ...
  'Box', 'Boy', 'Car1', 'Car2', 'Car24', 'Car4', 'CarDark', 'CarScale', ...
  'ClifBar', 'Coke', 'Couple', 'Coupon', 'Crossing', 'Crowds', 'Dancer', ...
  'Dancer2', 'David', 'David2', 'David3', 'Deer', 'Diving', 'Dog', 'Dog1', ...
  'Doll', 'DragonBaby', 'Dudek', 'FaceOcc1', 'FaceOcc2', 'Fish', 'FleetFace', ...
  'Football', 'Football1', 'Freeman1', 'Freeman3', 'Freeman4', 'Girl', ...
  'Girl2', 'Gym', 'Human2', 'Human3', 'Human4.2', 'Human5', 'Human6', ...
  'Human7', 'Human8', 'Human9', 'Ironman', 'Jogging.1', 'Jogging.2', 'Jump', ...
  'Jumping', 'KiteSurf', 'Lemming', 'Liquor', 'Man', 'Matrix', 'Mhyang', ...
  'MotorRolling', 'MountainBike', 'Panda', 'RedTeam', 'Rubik', 'Shaking', ...
  'Singer1', 'Singer2', 'Skater', 'Skater2', 'Skating1', 'Skating2.1', ...
  'Skating2.2', 'Skiing', 'Soccer', 'Subway', 'Surfer', 'Suv', 'Sylvester', ...
  'Tiger1', 'Tiger2', 'Toy', 'Trans', 'Trellis', 'Twinnings', 'Vase', ...
  'Walking', 'Walking2', 'Woman' };

SEQUENCE_ANNOTATIONS.V11_50 = { ...
  'Basketball' 'Biker' 'Bird1' 'BlurBody' 'BlurCar2' 'BlurFace' 'BlurOwl' ...
  'Bolt' 'Box' 'Car1' 'Car4' 'CarDark' 'CarScale' 'ClifBar' 'Couple' ...
  'Crowds' 'David' 'Deer' 'Diving' 'DragonBaby' 'Dudek' 'Football' ...
  'Freeman4' 'Girl' 'Human3' 'Human4.2' 'Human6' 'Human9' 'Ironman' 'Jump' ...
  'Jumping' 'Liquor' 'Matrix' 'MotorRolling' 'Panda' 'RedTeam' 'Shaking' ...
  'Singer2' 'Skating1' 'Skating2.1' 'Skating2.2' 'Skiing' 'Soccer' 'Surfer' ...
  'Sylvester' 'Tiger2' 'Trellis' 'Walking' 'Walking2' 'Woman' };

avail_seqs = {};
dir_seqs = dir(opt.data_dir);
disp(['scanning ' opt.data_dir ' ...']);
for i = 1:numel(dir_seqs)
  s = dir_seqs(i);
  if ~s.isdir || s.name(1) == '.', continue; end;
  
  seq_cfg_path = [opt.data_dir '/' s.name '/cfg.mat'];
  try
    seq_mat = load(seq_cfg_path);
  catch err
    warning('TrackerBenchmark:ScanSequencesError', ...
        ['no cfg.mat file or unable to load it: ' err.message]);
    continue;
  end
  
  if ~isfield(seq_mat, 'seq')
    warning('TrackerBenchmark:Generic', ['invalid ' seq_cfg_path ' - no seq field.']);
  end
  seqs = seq_mat.seq;
  
  %- Register sequences with multiple targets.
  if numel(seqs) > 1
    SEQUENCE_ANNOTATIONS.(s.name) = {seqs(:).name};
  end
  %- Register the attributes of each target.
  for k = 1:numel(seqs)
    seq_name = seqs(k).name;
    if isempty(seq_name), continue; end;
    avail_seqs = union(avail_seqs, seq_name);
    AddToAttrList(seq_name, seqs(k).annotations);
    
    if ~isempty(intersect(SEQUENCE_ANNOTATIONS.V11_50, seq_name))
      AddToAttrList(seq_name, seqs(k).annotations, 'V11_50');
    end
    if ~isempty(intersect(SEQUENCE_ANNOTATIONS.V11_100, seq_name))
      AddToAttrList(seq_name, seqs(k).annotations, 'V11_100');
    end
  end
end
%- Setup an alias 'ALL' to represent all available sequences.
SEQUENCE_ANNOTATIONS.ALL = avail_seqs;

disp(['found ' num2str(numel(avail_seqs)) ' sequences...']);

if nargout < 1
  clear avail_seqs;
end

end


function AddToAttrList(seq_name, att, prefix)

global SEQUENCE_ANNOTATIONS;
for j = 1:numel(att)
  SEQUENCE_ANNOTATIONS.attributes = union(SEQUENCE_ANNOTATIONS.attributes, att{j});
  if nargin > 2
    att_name = [prefix '_' att{j}];
  else
    att_name = att{j};
  end
  if ~isfield(SEQUENCE_ANNOTATIONS, att_name)
    SEQUENCE_ANNOTATIONS.(att_name) = {seq_name};
  else
    SEQUENCE_ANNOTATIONS.(att_name){end + 1} = seq_name;
  end
end
end
