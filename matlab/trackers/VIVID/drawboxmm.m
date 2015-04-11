
function drawboxmm(minx,maxx,miny,maxy,color,width)

if (nargin < 5)
    color = 'r';
end
if (nargin < 6)
    width = 4;
end
xfoo = [minx minx maxx maxx minx];
yfoo = [miny maxy maxy miny miny];
hold on; h=plot(xfoo,yfoo,color); set(h,'LineWidth',width); 
hold off; drawnow;
