clear;
close all;
clc;

% Edit this line individually.
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";

for i=11:35
    I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_6m.png");
    % imshow(I)
    
    [imgHeight, imgWidth] = size(I);
    points = detectSIFTFeatures(I);
    radiusStep = 10:5:120;
    periodVariance = nan(points.length,width(radiusStep));
    for j=1:points.length
        centerOfStar = points.Location(j,:);
        
%         figure;
%         imshow(I);
%         hold on;
%         plot(points);
%         plot(centerOfStar(1),centerOfStar(2),"r+",MarkerSize=10);
%         hold off;
        
        for k=1:width(radiusStep)
            [pixelValues, outOfBoundary] = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, radiusStep(k));       
            
            if outOfBoundary
                break;
            end

            [peaks,locs] = findpeaks(double(pixelValues));
                
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

    figure;
    imshow(I);
    hold on;
    title("Center of star, image " + string(i));
    plot(points(idxOfPoint));
    hold off;

    % Estimated center of star.
    centerOfStar = points.Location(idxOfPoint,:);

    % Estimate number of line pairs in star.
    maxRadius = 110;
    pixelValues = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, maxRadius);
    [peaks,locs] = findpeaks(double(pixelValues));
    numberOfLinePairsOfStar = width(peaks);

    % Transform circles around center of star into spatial frequency Line Pairs / Picture Height
    % and estimate contrast for every circle.
    radiusStep = maxRadius:-2:10;
    linePairsPerPictureHeight = zeros(1,width(radiusStep));
    MTF = zeros(1,width(radiusStep));
    for j=1:width(radiusStep)
        linePairWidthInPixels = (2*pi*radiusStep(j)) / numberOfLinePairsOfStar;
        linePairsPerPictureHeight(j) = imgHeight / linePairWidthInPixels;

        pixelValues= pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, radiusStep(j));
%         figure;
%         imshow(I)
%         title('Radius = ' + string(radiusStep(j)));
%         hold on;
%         plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10);
%         viscircles(centerOfStar,radiusStep(j));

%         figure;
%         plot(pixelValues);
%         hold on;
%         title("radius = " + string(radiusStep(j)) + ", angle step size = 1 deg")
%         xlabel("angles [deg]");
%         ylabel("Digital values");

        Imax = max(pixelValues);
        Imin = min(pixelValues);
        if j==1
            C0 = (Imax -Imin) /(Imax+Imin);
        end
        C = (Imax -Imin) /(Imax+Imin);
        MTF(j) = C/C0;
    end
    figure;
    plot(linePairsPerPictureHeight,MTF)
    title("MTF of picture "+string(i));
    xlabel("LP/PH");
    ylabel("MTF");
end

function [pixelValues, outOfBoundary]= pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfCircle, radius)

% figure;
% imshow(I)
% title('Radius = ' + string(radius);
% hold on;
% plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10);
% viscircles(centerOfStar,radius);

angles = 1:360;
x = centerOfCircle(1) + radius*cosd(angles);
y = centerOfCircle(2) + radius*sind(angles);
%             plot(x,y,'g+', 'MarkerSize', 10);
    
xNearestPixel = round(x);
yNearestPixel = round(y);
    
% plot(xNearestPixel,yNearestPixel,'b+', 'MarkerSize', 10);
% legend('Center');
% hold off;

outOfBoundary = false;
pixelValues = zeros(1,width(angles));
if nnz(yNearestPixel > imgHeight) ~= 0 || nnz(xNearestPixel > imgWidth) ~=0 || nnz(yNearestPixel <= 0) ~= 0 || nnz(xNearestPixel <= 0) ~=0 
    outOfBoundary = true;
else
    for i=1:width(angles)
        pixelValues(i) = I(yNearestPixel(i),xNearestPixel(i));
    end

%     figure;
%     plot(angles,pixelValues);
%     hold on;
%     title("radius = " + string(radius) + ", angle step size = 1 deg")
%     xlabel("angles [rad]");
%     ylabel("Digital values");        
end
end

function centerOfStar = refineCenterOfStarLocation(I)

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