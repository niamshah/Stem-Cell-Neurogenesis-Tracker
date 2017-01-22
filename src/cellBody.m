function  [img, filteredI] = cellBody(image)
img = imread(image);
img = im2double(img);
img = img(:,:,1);

image_threshold = img; 
image_threshold(img>0.25) = 256;
image_threshold(img<0.25) = 0;

I = image_threshold;
binI = im2bw(I);
filteredI = bwareafilt(binI,[40 100000000000]);
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

end

