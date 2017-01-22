function finalAxonPoints = axonID(picName, centroidNum)


img = imread(picName);
originalImage = img;
img = im2double(img);
img = img(:,:,1);

image_threshold = img; 
image_threshold(img>0.15) = 256;
image_threshold(img<0.15) = 0;
I = image_threshold;
binI = im2bw(I);
filteredI = bwareafilt(binI,[40 1000000000000]);
originalI = filteredI;


figure, imshow(filteredI);

startPc = 0;

for R=1:size(filteredI,1)
    startPc=0;
    for C=1:size(filteredI,2)
       color = squeeze(filteredI(R,C,:));
       if color == 1 && startPc==0
           startPc=C;
       elseif color == 0 && startPc ~= 0 && C-startPc < 8
           for pix = startPc:C
               filteredI(R,pix,:)=0;
           end
           startPc=0;
       elseif color == 0
           startPc=0;
           
       end
        
    end
end

startPr=0;
for C=1:size(filteredI,2)
    startPr=0;
    for R=1:size(filteredI,1)
       color = squeeze(filteredI(R,C,:));
       if color == 1 && startPr==0
           startPr=R;
       elseif color == 0 && startPr ~= 0 && R-startPr < 8
           for pix = startPr:R
               filteredI(pix,C,:)=0;
           end
           startPr=0;
       elseif color == 0
           startPr=0;
           
       end
        
    end
end
filteredI = imcomplement(filteredI);
mask = cast(filteredI, class(originalI));
img_masked = originalI .* mask;
binMask = im2bw(img_masked);
img_masked = bwareafilt(binMask,[60 1000000000000]);

%figure, imshow(img_masked);

topAxon = [];
bottomAxon = [];
for R=1:size(img_masked,1)
    for C=1:size(img_masked,2)
        pixel = 0;
        Color = squeeze(img_masked(R,C,:));
        if Color == 1
            isTop = true;
            isBottom = true;
            pixel = C;
            if R~=1
                for X = (C-15):(C+15)
                    if X >0 && X<size(img_masked,2)
                        row = R-1;
                        Color1 = squeeze(img_masked(row,X,:));
                        if Color1==1
                            isTop = false;
                        end
                    end
                end
            end
            if R~= size(img_masked,1)
                for X = (C-15):(C+15)
                    if X > 0 && X<size(img_masked,2)
                        row = R+1;
                        Color1 = squeeze(img_masked(row,X,:));
                            if Color1==1
                                isBottom = false;
                            end
                    end
                end
            end
            %hold on;
            if isTop 
               %plot(pixel,R,'r.');
               topAxon = cat(1,topAxon, [pixel R]);
            elseif isBottom
                %plot(pixel,R,'r.');
                bottomAxon = cat(1,bottomAxon, [pixel R]);
            end
        end
    end
end

for rows = 1:size(topAxon,1)
    if rows < size(topAxon,1)
        row = topAxon(rows,:);
        pixel = row(1);
        R = row(2);
        MRow = rows;
        first = true;
        timesInLoop = 0;
        nextPixel = pixel;
        nextR = 0;
        pixel1 = nextPixel;
        while first || (nextR == R && nextPixel == (pixel1+1)) 
            pixel1 = nextPixel;
            timesInLoop = timesInLoop + 1;
            if MRow < size(topAxon, 1)
                MRow = MRow + 1;
                nextRow = topAxon((MRow), :);
                nextPixel = nextRow(1);
                nextR = nextRow(2);
            end
            if nextPixel == pixel1+1
                topAxon = topAxon([1:MRow-1,MRow+1:end],:);
                MRow = MRow-1;
            end
            first = false;
        end
        if timesInLoop>1
            avg = round(mean([pixel pixel1])); 
            topAxon(rows,:) = [avg R];
        end
        
    end
end

for rows = 1:size(bottomAxon,1)
    if rows < size(bottomAxon,1)
        row = bottomAxon(rows,:);
        pixel = row(1);
        R = row(2);
        MRow = rows;
        first = true;
        timesInLoop = 0;
        nextPixel = pixel;
        nextR = 0;
        pixel1 = nextPixel;
        while first || (nextR == R && nextPixel == (pixel1+1)) 
            pixel1 = nextPixel;
            timesInLoop = timesInLoop + 1;
            if MRow < size(bottomAxon, 1)
                MRow = MRow + 1;
                nextRow = bottomAxon((MRow), :);
                nextPixel = nextRow(1);
                nextR = nextRow(2);
            end
            if nextPixel == pixel1+1
                bottomAxon = bottomAxon([1:MRow-1,MRow+1:end],:);
                MRow = MRow-1;
            end
            first = false;
        end
        if timesInLoop>1
            avg = round(mean([pixel pixel1])); 
            bottomAxon(rows,:) = [avg R];
        end
        
    end
end


finalAxonPoints = [];
figure, imshow(img_masked);
for rows = 1:size(topAxon,1)
    row = topAxon(rows,:);
    pixel = row(1);
    R = row(2);
    hold on;
    plot(pixel,R,'r.');
end
for rows = 1:size(bottomAxon,1)
    row = bottomAxon(rows,:);
    pixel = row(1);
    R = row(2);
    hold on;
    plot(pixel,R,'r.');
end
bound = bwboundaries(img_masked);
for cellArray = 1: numel(bound)
    topCA = [];
    bottomCA = [];
    CA = bound(cellArray);
    CA = CA{1};
    xCoords = CA(:,1)';
    yCoords = CA(:,2)';
    for rows = 1:size(topAxon,1)
        row = topAxon(rows,:);
        pixel = row(1);
        R = row(2);
        in = inpolygon(R,pixel,xCoords,yCoords);
        if in ==1
            topCA = cat(1,topCA, [R pixel]);
        end
    end
    for rows = 1:size(bottomAxon,1)
        row = bottomAxon(rows,:);
        pixel = row(1);
        R = row(2);
        in = inpolygon(R,pixel,xCoords,yCoords);
        if in ==1
            bottomCA = cat(1,bottomCA, [R pixel]);
        end
    end
    if size(topCA,1)>1 && size(bottomCA,1)>1
        tempTopCA = [];
        for rows = 1:size(topCA,1)
            row = topCA(rows,:);
            xCoord = row(2);
            yCoord = row(1);
            [distanceToCell, cell] = smallestDistance(xCoord, yCoord, centroidNum);
            tempTopCA = cat(1,tempTopCA, [yCoord xCoord distanceToCell cell]);
        end
        topCA = [];
        tempTopCA = sortrows(tempTopCA, 4);
        for rows = 1:size(tempTopCA,1)
            if rows~=1
                rows = rows-1;
            end
            if rows<=size(tempTopCA,1)
                row = tempTopCA(rows,:);
                cell = row(4);
                dist = row(3);
                if rows<size(tempTopCA,1)
                    nextRow = tempTopCA(rows+1,:);
                    nextCell = nextRow(4);
                    nextDist = nextRow(3);
                    if cell == nextCell
                        if dist>=nextDist
                            tempTopCA(rows+1,:) = [];
                        else
                            tempTopCA(rows,:) = [];
                        end
                    end
                end
            end
        end
        lastRN = size(tempTopCA,1);
        lastRow = tempTopCA(lastRN,:);
        cell = lastRow(4);
        dist = lastRow(3);
        if lastRN>1
            prevRow = tempTopCA(lastRN-1,:);
            prevCell = prevRow(4);
            prevDist = prevRow(3);
            if cell == prevCell
                if dist>=prevDist
                    tempTopCA(lastRN-1,:) = [];
                else
                    tempTopCA(lastRN,:) = [];
                end
            end
        end
        topCA = tempTopCA(:,1:2);
        tempBottomCA = [];
        for rows = 1:size(bottomCA,1)
            row = bottomCA(rows,:);
            xCoord = row(2);
            yCoord = row(1);
            [distanceToCell, cell] = smallestDistance(xCoord, yCoord, centroidNum);
            tempBottomCA = cat(1,tempBottomCA, [yCoord xCoord distanceToCell cell]);
        end
        bottomCA = [];
        tempBottomCA = sortrows(tempBottomCA, 4);
        for rows = 1:size(tempBottomCA,1)
            if rows~=1
                rows = rows-1;
            end
            if rows<=size(tempBottomCA,1)
                row = tempBottomCA(rows,:);
                cell = row(4);
                dist = row(3);
                if rows<size(tempBottomCA,1)
                    nextRow = tempBottomCA(rows+1,:);
                    nextCell = nextRow(4);
                    nextDist = nextRow(3);
                    if cell == nextCell
                        if dist>=nextDist
                            tempBottomCA(rows+1,:) = [];
                        else
                            tempBottomCA(rows,:) = [];
                        end
                    end
                end
            end
        end
        lastRN = size(tempBottomCA,1);
        lastRow = tempBottomCA(lastRN,:);
        cell = lastRow(4);
        dist = lastRow(3);
        if lastRN>1
            prevRow = tempBottomCA(lastRN-1,:);
            prevCell = prevRow(4);
            prevDist = prevRow(3);
            if cell == prevCell
                if dist>=prevDist
                    tempBottomCA(lastRN-1,:) = [];
                else
                    tempBottomCA(lastRN,:) = [];
                end
            end
        end
        bottomCA = tempBottomCA(:,1:2);
    end
    if size(topCA,1)==1 && size(bottomCA,1)==1
        xC = [topCA(1,2) bottomCA(1,2)];
        yC = [topCA(1,1) bottomCA(1,1)];
        hold on;
        plot(xC, yC);
        [xCt,yCt, closestCellT] = smallestDistance1(topCA(1,2),topCA(1,1), centroidNum);
        [xCb,yCb, closestCellB] = smallestDistance1(bottomCA(1,2),bottomCA(1,1), centroidNum);
        finalAxonPoints = cat(1,finalAxonPoints, [xCt yCt xCb yCb closestCellT closestCellB]);
    elseif size(topCA,1)==1 
        if size(bottomCA,1)>0
            l2h = mysortrows(bottomCA, 1);
            xC = [topCA(1,2) l2h(end,2)];
            yC = [topCA(1,1) l2h(end,1)];
            hold on;
            plot(xC, yC);
            [xCt,yCt, closestCellT] = smallestDistance1(topCA(1,2),topCA(1,1), centroidNum);
            [xCb,yCb, closestCellB] = smallestDistance1(l2h(end,2),l2h(end,1), centroidNum);
            finalAxonPoints = cat(1,finalAxonPoints, [xCt yCt xCb yCb closestCellT closestCellB]);
        end
    elseif size(bottomCA,1)==1
        if size(topCA,1)>0
            l2h = mysortrows(topCA, 1);
            xC = [l2h(1,2) bottomCA(1,2)];
            yC = [l2h(1,1) bottomCA(1,1)];
            hold on;
            plot(xC, yC);
            [xCt,yCt, closestCellT] = smallestDistance1(l2h(1,2),l2h(1,1), centroidNum);
            [xCb,yCb, closestCellB] = smallestDistance1(bottomCA(1,2),bottomCA(1,1), centroidNum);
            finalAxonPoints = cat(1,finalAxonPoints, [xCt yCt xCb yCb closestCellT closestCellB]);
        end
    elseif size(topCA,1)>0 && size(bottomCA,1)>0
        largestDis = 0;
        tX = 0;
        tY = 0;
        bX = 0;
        bY = 0;
        biggestX = 0;
        biggestX2=0;
        first = true;
        for j = 1:2
            largestDis = 0;
            if j==2 && first
                first = false;
                biggestX = tX;
                biggestX2 = bX;
            end
            for rows = 1:size(topCA,1)
                row = topCA(rows,:);
                yC = row(1);
                xC = row(2);
                for rowsb = 1:size(bottomCA,1)
                    rowb = bottomCA(rowsb,:);
                    yCb = rowb(1);
                    xCb = rowb(2);
                    dis = pdist([xC,yC;xCb, yCb],'euclidean');
                    if dis>largestDis && xC~=biggestX && xCb~=biggestX2
                        largestDis = dis;
                        tX = xC;
                        tY = yC;
                        bX = xCb;
                        bY = yCb;
                    end
                end
            end
            xC = [tX bX];
            yC = [tY bY];
            hold on;
            plot(xC, yC);
            [xCT, yCT, closestCellT] = smallestDistance1(tX,tY, centroidNum);
            [xCB,yCB, closestCellB] = smallestDistance1(bX,bY, centroidNum);
            finalAxonPoints = cat(1,finalAxonPoints, [xCT yCT xCB yCB closestCellT closestCellB]);
        end
    end
    
end

end


