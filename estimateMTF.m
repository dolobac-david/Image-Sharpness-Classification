% Estimate MTF of star in given image.
function [frequency, C, MTF] = estimateMTF(I, imgHeight, imgWidth, centerOfStar, numberOfLinePairsOfStar, maxRadius, maxRadiusKnown, frequencyType)

% Transform circles around center of star into spatial frequency Line Pairs
% / Picture Height or cycles / pixel and compute MTF value for every circle.
angles = 1:360;
if maxRadiusKnown
    numberOfCircles = 49;
    minRadius = 10;
    radiusStep = (maxRadius-minRadius)/numberOfCircles;
    radii = maxRadius:-radiusStep:minRadius; 
else
    radii = maxRadius:-2:10;
end

linePairWidthInPixels =  zeros(1,width(radii))';
if frequencyType == "Line Pairs / Picture Height"
    linePairsPerPictureHeight = zeros(1,width(radii))';
elseif frequencyType == "Line Pairs / Pixel"
    cyclesPerPixel = zeros(1,width(radii))';
end

C = zeros(1,width(radii))';
MTF = zeros(1,width(radii));
for j=1:width(radii)
    linePairWidthInPixels(j) = (2*pi*radii(j)) / numberOfLinePairsOfStar;

    if frequencyType == "Line Pairs / Picture Height"
        linePairsPerPictureHeight(j) = imgHeight / linePairWidthInPixels(j);
    elseif frequencyType == "Line Pairs / Pixel"
        cyclesPerPixel(j) = 1 / linePairWidthInPixels(j);       
    end

    pixelValues = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, radii(j));
 
%     figure;
%     plot(angles,pixelValues);
%     hold on;
%     title("radius = " + string(radii(j)) + ", angle step size = 1 deg")
%     xlabel("angles [rad]");
%     ylabel("Digital values"); 
%     plot(angles,peaks,"g+");
%     hold off;

    Imax = max(pixelValues);
    Imin = min(pixelValues);
    
    % Contrast on lowest frequency which correponds to biggest circle
    if j==1
        C(j) = (Imax -Imin) /(Imax+Imin);
    end
    C(j) = (Imax -Imin) /(Imax+Imin);
    MTF(j) = C(j)/C(1);
end

if frequencyType == "Line Pairs / Picture Height"
    frequency = linePairsPerPictureHeight;
elseif frequencyType == "Line Pairs / Pixel"
    frequency = cyclesPerPixel;       
end 

end