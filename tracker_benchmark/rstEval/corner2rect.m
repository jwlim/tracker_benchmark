function rect = corner2rect(points)

if size(points,1) ~= 2
    disp('error!');
    return;
end

left = min(points(1,:));
right = max(points(1,:));

bottom = max(points(2,:));
top = min(points(2,:));

rect = round([left, top, right - left + 1, bottom - top + 1]);
