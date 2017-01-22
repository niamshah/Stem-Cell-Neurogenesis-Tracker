function [xC,yC,closestCell ] = smallestDistance1(x,y,centroidNum)
smallestDis = 0;
closestCell = 0;
xC =0;
yC = 0;
for rows = 1:size(centroidNum,1)
    row = centroidNum(rows,:);
    centroidX = row(1);
    centroidY = row(2);
    cellNum = row(3);
    distance = pdist([x,y;centroidX, centroidY],'euclidean');
    if rows == 1
        smallestDis = distance;
        closestCell = cellNum;
        xC = centroidX;
        yC = centroidY;
    elseif distance<smallestDis
        smallestDis = distance;
        closestCell = cellNum;
        xC = centroidX;
        yC = centroidY;
    end
end


end