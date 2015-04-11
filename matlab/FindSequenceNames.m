
function [seq_names, seq_map] = FindSequenceNames(attr_names, varargin)
%
% FindSequenceNames
% - finds the sequence names with the given attributes.
%
% Usage:
% [seq_names, seq_map] = FindSequenceNames(attr_names, ...)
% - attr_names : a string or a cell array of strings with attribute names.
%       Sequence names can also be used.
% - seq_names : a cell array of the sequence names with the given attributes.
%       If multiple attributes are given, the sequence lists are merged and
%       only one list is returned. To find which sequence has which attribute
%       use seq_map.
% - seq_map : a cell array with the same size of the input attr_names,
%       containing the index of sequences with the attribute.
%
% Options:

% Authors: Jongwoo Lim (jongwoo.lim@gmail.com)


global SEQUENCE_ANNOTATIONS;
if isempty(SEQUENCE_ANNOTATIONS)
  error('SEQUENCE_ANNOTATIONS is not set. Run ScanSequences first');
end

if ~iscell(attr_names), attr_names = {attr_names}; end;

seq_name_map = struct();
for i = 1:numel(attr_names)
  attr_name = attr_names{i};
  if isfield(SEQUENCE_ANNOTATIONS, attr_name)
    attr_seq_names = SEQUENCE_ANNOTATIONS.(attr_name);
  else
    attr_seq_names = {attr_name};  % Assume this is a sequence name.
  end
  for j = 1:numel(attr_seq_names)
    name = regexprep(attr_seq_names{j}, '\.', '_');
    if isfield(seq_name_map, name)
      seq_name_map.(name) = cat(2, seq_name_map.(name), i);
    else
      seq_name_map.(name) = i;
    end
  end
end

seq_names = sort(fieldnames(seq_name_map));
seq_map = cell(size(attr_names));
for i = 1:numel(seq_names)
  idx = seq_name_map.(seq_names{i});
  for j = 1:numel(idx)
    seq_map{idx(j)} = cat(2, seq_map{idx(j)}, i);
  end
  seq_names{i} = regexprep(seq_names{i}, '_', '\.');
end
end
