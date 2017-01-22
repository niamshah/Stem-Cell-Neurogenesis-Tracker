[img, filteredI] = cellBody('./Neurogenesis/iNGNFluoresced.png');
figure, imshow(filteredI,[])
labeledImage = bwlabel(filteredI,8);
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle');
%figure, imshow(coloredLabels,[])
axis image;
cellMeasurements = regionprops(labeledImage, 'all');
numberOfCells = size(cellMeasurements, 1);
textFontSize = 7;	
labelShiftX = -7;
allCellCentroids = [cellMeasurements.Centroid];
centroidsX = allCellCentroids(1:2:end-1);
centroidsY = allCellCentroids(2:2:end);
%figure, imshow(filteredI,[])
BWoutline = bwperim(filteredI);
Segout = img;
Segout(BWoutline) = 255;
figure, imshow(Segout), title('outlined original image');
centroidNum = [];
for k = 1 : numberOfCells           
	text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color','red');
    centroidNum = cat(1,centroidNum, [centroidsX(k) centroidsY(k) k]);
end
finalAxonPoints = axonID('./Neurogenesis/iNGNFluoresced.png',centroidNum);
figure;
for k = 1 : numberOfCells   
    circle(centroidsX(k),centroidsY(k),10);
	text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', textFontSize, 'FontWeight', 'Bold');
end
for rows = 1:size(finalAxonPoints,1)
    row = finalAxonPoints(rows,:);
    xC = [row(1) row(3)];
    yC = [row(2) row(4)];
    hold on;
    set(gca,'Ydir','reverse')
    plot(xC, yC);
end
centroidPoints = finalAxonPoints(:,5:end);
centroidPoints = unique(centroidPoints,'rows');
centroidPointsNS= [];
for rows = 1:size(centroidPoints,1)
    if rows<=size(centroidPoints,1)
        row = centroidPoints(rows,:);
        if row(1) ~= row(2)
            centroidPointsNS = cat(1,centroidPointsNS, [row(1) row(2)]);
        end
    end
end
disp(centroidPointsNS);



