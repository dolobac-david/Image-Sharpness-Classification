% Estimate MTF of star in given image.
function [linePairsPerPictureHeight, C, MTF] = estimateMTF(I, imgHeight, imgWidth, centerOfStar, numberOfLinePairsOfStar, maxRadius, maxRadiusKnown)

% Transform circles around center of star into spatial frequency Line Pairs / Picture Height
% and estimate contrast for every circle.
if maxRadiusKnown
    numberOfCircles = 49;
    minRadius = 10;
    radiusStep = (maxRadius-minRadius)/numberOfCircles;
    radii = maxRadius:-radiusStep:minRadius; 
else
    radii = maxRadius:-2:10;
end
linePairWidthInPixels =  zeros(1,width(radii))';
linePairsPerPictureHeight = zeros(1,width(radii))';
%     linePairsPerPixel = zeros(1,width(radii))';
C = zeros(1,width(radii))';
MTF = zeros(1,width(radii));
for j=1:width(radii)
    linePairWidthInPixels(j) = (2*pi*radii(j)) / numberOfLinePairsOfStar;
    linePairsPerPictureHeight(j) = imgHeight / linePairWidthInPixels(j);
%         linePairsPerPixel(j) = 1 / linePairWidthInPixels(j);

    pixelValues = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, radii(j));

%     figure;
%     imshow(I)
%     title('Radius = ' + string(radii(j)));
%     hold on;
%     plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10);
%     viscircles(centerOfStar,radii(j));
% 
%         figure;
%         plot(pixelValues);
%         hold on;
%         title("radius = " + string(radii(j)) + ", angle step size = 1 deg")
%         xlabel("angles [deg]");
%         ylabel("Digital values");

    Imax = max(pixelValues);
    Imin = min(pixelValues);
    
    % Contrast on lowest frequency which correponds to biggest circle
    if j==1
        C(j) = (Imax -Imin) /(Imax+Imin);
    end
    C(j) = (Imax -Imin) /(Imax+Imin);
    MTF(j) = C(j)/C(1);
end
end