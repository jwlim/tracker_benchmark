
function rect = BBox2Rect(bbox)

transpose = false;
if size(bbox,2) ~= 4 && size(bbox,1) == 4
  transpose = true;
  bbox = bbox';
end

rect = zeros(size(bbox));
rect(:,1) = min(bbox(:,1), bbox(:,3));
rect(:,2) = min(bbox(:,2), bbox(:,4));
rect(:,3) = max(bbox(:,1), bbox(:,3)) - rect(:,1) + 1;
rect(:,4) = max(bbox(:,2), bbox(:,4)) - rect(:,2) + 1;

if transpose
  rect = rect';
end

end
