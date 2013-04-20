
function bbox = Rect2BBox(rect)

transpose = false;
if size(rect,2) ~= 4 && size(rect,1) == 4
  transpose = true;
  rect = rect';
end

bbox = rect;
bbox(:,3) = rect(:,1) + rect(:,3) - 1;
bbox(:,4) = rect(:,2) + rect(:,4) - 1;

if transpose
  bbox = bbox';
end

end
