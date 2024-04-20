clear;
close all;
clc;

% Edit this line individually.
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";
for i=11:35
    I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_6m.png");
    [imgHeight,imgWidth]=size(I);

    % Find initial center of star.
    initialCenterOfStar= findCenterOfStar(I);

    % Find initial max radius of star.
    initialMaxRadius = findMaxRadius(I, imgHeight, imgWidth, initialCenterOfStar);

    figure;
    imshow(I);
    hold on;
    title("Center of star, image " + string(i));
    plot(initialCenterOfStar(1),initialCenterOfStar(2),'Color','green','Marker','+','MarkerSize',10);
    drawcircle('Center',[initialCenterOfStar(1), initialCenterOfStar(2)],'Radius', initialMaxRadius,'StripeColor','red'); 
    hold off

    % Refine location of center.
    centerOfStar = refineCenterOfStarLocation(I, initialMaxRadius, initialCenterOfStar);

    % Refine max radius of star.
    maxRadius = findMaxRadius(I, imgHeight, imgWidth, centerOfStar);

    figure;
    imshow(I);
    hold on;
    title("Refined center of star, image " + string(i));
    plot(centerOfStar(1),centerOfStar(2),'Color','green','Marker','+','MarkerSize',10);
    drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', maxRadius,'StripeColor','red'); 
    hold off;

    % Estimate number of line pairs in star.
    pixelValues = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, maxRadius);
    [peaks,locs] = findpeaks(double(pixelValues));
    numberOfLinePairsOfStar = width(peaks);

%     figure;
%     plot(angles,pixelValues);
%     hold on;
%     title("radius = " + string(maxRadius) + ", angle step size = 1 deg")
%     xlabel("angles [rad]");
%     ylabel("Digital values"); 
%     plot(locs,peaks,"g+");
%     hold off;
% 
    [linePairsPerPictureHeight, C, MTF] = estimateMTF(I, imgHeight, imgWidth, centerOfStar, ...
        numberOfLinePairsOfStar, maxRadius);
    figure;
    hold on;
    plot(linePairsPerPictureHeight,MTF)
    title("MTF of picture "+string(i));
    xlabel("LP/PH");
    ylabel("MTF");

    figure;
    hold on;
    plot(linePairsPerPictureHeight,C)
    title("Contrast of picture "+string(i));
    xlabel("LP/PH");
    ylabel("C");
end

% figure;
% hold on;
% for i=11:35
%     plot(linePairsPerPictureHeight,MTF(i,:));
%     label(i-10) = 'Image ' + string(i);
% end
% hold off;
% legend(label);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");