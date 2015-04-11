
function [dst_file_name, dst_seq_name, dst_tracker_name] = ConvertName(file_name)

[seq_name, str] = strtok(file_name, '_.');
tracker_name = strtok(str, '_.');

dst_tracker_name = ToUpper(tracker_name);
switch dst_tracker_name
  case 'L1_APG', dst_tracker_name = 'L1APG';
end

dst_seq_name = seq_name;
switch dst_seq_name
  case 'cliffbar', dst_seq_name = 'ClifBar';
  case 'dragonbaby', dst_seq_name = 'DragonBaby';
  case 'redteam', dst_seq_name = 'RedTeam';
  case 'faceocc1', dst_seq_name = 'FaceOcc1';
  case 'faceocc2', dst_seq_name = 'FaceOcc2';
  case 'fleetface', dst_seq_name = 'FleetFace';
  case 'jogging', dst_seq_name = 'Jogging.1';
  case 'jogging-2', dst_seq_name = 'Jogging.2';
end
dst_seq_name(1) = ToUpper(dst_seq_name(1));

dst_seq_name(find(dst_seq_name == '-')) = '.';

dst_file_name = [dst_seq_name '_' dst_tracker_name '.mat'];

if numel(dst_tracker_name) < 2,
  disp(file_name);
  disp(dst_tracker_name);
end
end


function s = ToUpper(s)

for i = 1:numel(s)
  if s(i) >= 'a' && s(i) <= 'z'
    s(i) = s(i) - 'a' + 'A';
  end
end
end
