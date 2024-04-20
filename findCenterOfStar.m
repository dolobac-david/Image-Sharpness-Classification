function centerOfStar= findCenterOfStar(I)

[imgHeight, imgWidth] = size(I);
points = detectSIFTFeatures(I);
radii = 10:5:120;
periodVariance = nan(points.length,width(radii));
for j=1:points.length
    centerOfStar = points.Location(j,:);
    
%         figure;
%         imshow(I);
%         hold on;
%         plot(points);
%         plot(centerOfStar(1),centerOfStar(2),"r+",MarkerSize=10);
%         hold off;
    
    for k=1:width(radii)
        [pixelValues, outOfBoundary] = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, radii(k));       
        
        if outOfBoundary
            break;
        end

        [~,locs] = findpeaks(double(pixelValues));
            
%                 plot(locs,peaks,"g+");
%                 hold off;
            
        period = diff(locs);    
        if length(period) > 1
            periodVariance(j,k) = var(period);
        end
    end
end
%         close all;

[minPeriodVariances, idxOfRadii] = min(periodVariance,[],2);
[minPeriodVariance, idxOfPoint] = min(minPeriodVariances);

%     [B, idx] = sort(minPeriodVariances);

% Estimated center of star.
centerOfStar = points.Location(idxOfPoint,:);
end