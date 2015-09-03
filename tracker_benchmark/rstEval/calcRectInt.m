function overlap = calcRectInt(A,B)
%
%each row is a rectangle.
% A(i,:) = [x y w h]
% B(j,:) = [x y w h]
% overlap(i,j) = area of intersection
% normoverlap(i,j) = overlap(i,j) / (area(i)+area(j)-overlap)
%
% Same as built-in rectint, but faster and uses less memory (since avoids repmat).


leftA = A(:,1);
bottomA = A(:,2);
rightA = leftA + A(:,3) - 1;
topA = bottomA + A(:,4) - 1;

leftB = B(:,1);
bottomB = B(:,2);
rightB = leftB + B(:,3) - 1;
topB = bottomB + B(:,4) - 1;

tmp = (max(0, min(rightA, rightB) - max(leftA, leftB)+1 )) .* (max(0, min(topA, topB) - max(bottomA, bottomB)+1 ));
    areaA = A(:,3) .* A(:,4);
    areaB = B(:,3) .* B(:,4);
    overlap = tmp./(areaA+areaB-tmp);
% if tmp > 0
% 
%     overlap = tmp;
% 
%     areaA = A(3) .* A(4);
%     areaB = B(3) .* B(4);
%     overlap = tmp./(areaA+areaB-tmp);
% else
%     overlap = 0;
% end