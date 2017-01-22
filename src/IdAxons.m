%{
img = imread('./Neurogenesis/iNGNFluoresced.png');
originalImage = img;
img = im2double(img);
img = img(:,:,1);

image_threshold = img; 
image_threshold(img>0.25) = 256;
image_threshold(img<0.25) = 0;

I = image_threshold;
binI = im2bw(I);
filteredI = bwareafilt(binI,[40 10000]);
startPc = 0;

for R=1:size(filteredI,1)
    startPc=0;
    for C=1:size(filteredI,2)
       color = squeeze(filteredI(R,C,:));
       if color == 1 && startPc==0
           startPc=C;
       elseif color == 0 && startPc ~= 0 && C-startPc < 6
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
       elseif color == 0 && startPr ~= 0 && R-startPr < 6
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
mask = cast(filteredI, class(originalImage));
img_masked = originalImage .* repmat(mask, [1 1 3]);
image_threshold1 = img_masked; 
mask = img_masked;
image_threshold1(mask>1) = 256;
image_threshold1(mask<1) = 0;
axonImg = im2bw(image_threshold1,0.99);
axonImg = bwareafilt(axonImg,[30 10000]);

imshow(axonImg);
%}
img = imread('./Neurogenesis/iNGNFluoresced.png');
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
    if size(topCA,1)==1 && size(bottomCA,1)==1
        xC = [topCA(1,2) bottomCA(1,2)];
        yC = [topCA(1,1) bottomCA(1,1)];
        hold on;
        plot(xC, yC);
    end
end
