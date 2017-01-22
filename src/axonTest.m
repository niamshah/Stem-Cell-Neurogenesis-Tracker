img_masked = imread('./Neurogenesis/AxonTest1.png');
img_masked = im2bw(img_masked);
figure, imshow(img_masked);

for R=1:size(img_masked,1)
    for C=1:size(img_masked,2)
        pixel = 0;
        Color = squeeze(img_masked(R,C,:));
        if Color == 1
            isTop = true;
            isBottom = true;
            pixel = C;
            if R~=1
                for X = (C-50):(C+50)
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
                for X = (C-50):(C+50)
                    if X > 0 && X<size(img_masked,2)
                        row = R+1;
                        Color1 = squeeze(img_masked(row,X,:));
                            if Color1==1
                                isBottom = false;
                            end
                    end
                end
            end
            
            if isTop || isBottom
                hold on;
                plot(pixel,R,'r.');
                fprintf('%d %d', pixel, R);
            end
        end
    end
end
bound = bwboundaries(img_masked);
bound = bound{1,1};
xCoords = bound(:,1)';
yCoords = bound(:,2)';
in = inpolygon(131,82,xCoords,yCoords);
disp(in);