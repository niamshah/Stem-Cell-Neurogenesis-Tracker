function [ smallestDis,closestCell ] = smallestDistance(x,y,centroidNum)
smallestDis = 0;
closestCell = 0;
for rows = 1:size(centroidNum,1)
    row = centroidNum(rows,:);
    centroidX = row(1);
    centroidY = row(2);
    cellNum = row(3);
    distance = pdist([x,y;centroidX, centroidY],'euclidean');
    if rows == 1
        smallestDis = distance;
        closestCell = cellNum;
    elseif distance<smallestDis
        smallestDis = distance;
        closestCell = cellNum;
    end
end


end

