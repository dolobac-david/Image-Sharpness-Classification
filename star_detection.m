clear;
close all;
clc;

% Edit 
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";

radiusStep = 10:5:120;
angles = 1:360;
for i=11:35
    I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_6m.png");
    % imshow(I)
    
    [imgHeight, imgWidth] = size(I);
    radiusStep = 10:5:120;
    points = detectSIFTFeatures(I);
    periodVariance = zeros(points.length,width(radiusStep));
    peaksVariance = zeros(points.length,width(radiusStep));
    for j=1:points.length
        outOfBoundary = false;
        centerOfStar = points.Location(j,:);
        
%         figure;
%         imshow(I);
%         hold on;
%         plot(points);
%         plot(centerOfStar(1),centerOfStar(2),"r+",MarkerSize=10);
%         hold off;
        
        for k=1:width(radiusStep)
%             figure;
%             imshow(I)
%             title('Radius = ' + string(radiusStep(k)));
%             hold on;
%             plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10);
%             viscircles(centerOfStar,radiusStep(k));
        
            x = centerOfStar(1) + radiusStep(k)*cosd(angles);
            y = centerOfStar(2) + radiusStep(k)*sind(angles);
%             plot(x,y,'g+', 'MarkerSize', 10);
    
            xNearestPixel = round(x);
            yNearestPixel = round(y);
    
%             plot(xNearestPixel,yNearestPixel,'b+', 'MarkerSize', 10);
%             legend('Center');
%             hold off;
            
            for l=1:width(angles)
                if yNearestPixel(l) > imgHeight || xNearestPixel(l) > imgWidth || yNearestPixel(l) <= 0 || xNearestPixel(l) <= 0 
                    outOfBoundary = true;
                    break;
                else
                    outOfBoundary = false;
                    pixelValue(l) = I(yNearestPixel(l),xNearestPixel(l));
                end
            end
    
            if ~outOfBoundary
%                 figure;
%                 plot(angles,pixelValue);
%                 hold on;
%                 title("radius = " + string(radiusStep(k)) + ", angle step size = 1 deg")
%                 xlabel("angles [rad]");
%                 ylabel("Digital values");
        
                [peaks,locs] = findpeaks(double(pixelValue),angles);
                
%                 plot(locs,peaks,"g+");
%                 hold off;
                
                period = diff(locs);    
                if length(period) > 1
                    periodVariance(j,k) = var(period);
                    peaksVariance(j,k) = var(peaks);
                else
                    periodVariance(j,k) = nan;
                    peaksVariance(j,k) = nan;
                end
            else
                periodVariance(j,k) = nan;
                peaksVariance(j,k) = nan;
            end
        end
%         close all;
    end

    [minPeriodVariances, idxOfRadii] = min(periodVariance,[],2);
    [minPeriodVariance, idxOfPoint] = min(minPeriodVariances);

    figure;
    imshow(I);
    hold on;
    title("Center of star, image " + string(i));
    plot(points(idxOfPoint));
    hold off;
% 
%     [B,idx] = mink(minPeriodVariances,10);

%     figure;
%     imshow(I);
%     hold on;
%     title("10 strongest candidates for center of star, image " + string(i));
%     plot(points(idx));
%     hold off;

%     [minPeaksVariances, idxOfRadii] = min(peaksVariance,[],2);
%     [minPeakVariance, idxOfPoint] = min(minPeaksVariances);

%     figure;
%     imshow(I);
%     hold on;
%     title("Center of star, peak variance, image " + string(i));
%     plot(points(idxOfPoint));
%     hold off;
end

function centerOfStar = findCenterOfStarPixelPrecision(I)

rows = sum(I,2);
cols = sum(I,1);

% figure;
% plot(rows)
% title("Rows sumation")
% 
% figure;
% plot(cols)
% title("Columns sumation")

[~,y] = min(rows);
[~,x] = min(cols);

centerGuess = [x,y];
points = detectMinEigenFeatures(I);

figure;
imshow(I)
hold on;
plot(x,y,'r+', 'MarkerSize', 10)
plot(points);
title("Initial center of star")
hold off; 

dist = vecnorm((points.Location - centerGuess),2,2);
[~,idx] = min(dist);
centerOfStar = points.Location(idx,:);
end