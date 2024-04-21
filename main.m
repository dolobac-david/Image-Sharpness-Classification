clear;
close all;
clc;

% Edit this line individually.
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";
angles = 1:360;
for i=11:35
    I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_6m.png");
    [imgHeight,imgWidth] = size(I);

    % Find initial center of star.
    initialCenterOfStar= findCenterOfStar(I);

    % Find max radius of star.
    maxRadius = findMaxRadius(I, imgHeight, imgWidth, initialCenterOfStar);
%     maxRadius = 40;
    maxRadiusKnown = true;

%     figure(1);
%     imshow(I);
%     hold on;
%     title("Center of star, image " + string(i));
%     plot(initialCenterOfStar(1),initialCenterOfStar(2),'Color','green','Marker','+','MarkerSize',10);
%     drawcircle('Center',[initialCenterOfStar(1), initialCenterOfStar(2)],'Radius', maxRadius,'StripeColor','red'); 
%     hold off

    % Refine location of center.
    centerOfStar = refineCenterOfStarLocation(I, maxRadius, initialCenterOfStar);
% 
%     figure(2)
%     imshow(I);
%     hold on;
%     title("Refined center of star, image " + string(i));
%     plot(centerOfStar(1),centerOfStar(2),'Color','green','Marker','+','MarkerSize',10);
%     drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', maxRadius,'StripeColor','red');
%     hold off;

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
    
    [linePairsPerPictureHeight, C, MTF] = estimateMTF(I, imgHeight, imgWidth, centerOfStar, ...
        numberOfLinePairsOfStar, maxRadius, maxRadiusKnown);
% %     figure;
% %     hold on;
% %     plot(linePairsPerPictureHeight,MTF)
% %     title("MTF of picture "+string(i));
% %     xlabel("LP/PH");
% %     ylabel("MTF");
% 
% %     figure;
% %     hold on;
% %     plot(linePairsPerPictureHeight,C)
% %     title("Contrast of picture "+string(i));
% %     xlabel("LP/PH");
% %     ylabel("C");
%     
    MTFContainer{i-10} = MTF;
    LPPHContainer{i-10} = linePairsPerPictureHeight;
    contrastContainer{i-10} = C;
end

% Visualization
% MTF 
figure;
hold on;
for i=1:7
    plot(LPPHContainer{i},MTFContainer{i});
    label(i) = 'Image ' + string(i+10);
end
hold off;
legend(label);
title("MTF of pictures");
xlabel("LP/PH");
ylabel("MTF");

figure;
hold on;
for i=8:14
    plot(LPPHContainer{i},MTFContainer{i});
    label(i-7) = 'Image ' + string(i);
end
hold off;
legend(label);
title("MTF of pictures");
xlabel("LP/PH");
ylabel("MTF");

figure;
hold on;
for i=15:21
    plot(LPPHContainer{i},MTFContainer{i});
    label(i-14) = 'Image ' + string(i);
end
hold off;
legend(label);
title("MTF of pictures");
xlabel("LP/PH");
ylabel("MTF");

figure;
hold on;
for i=22:25
    plot(LPPHContainer{i},MTFContainer{i});
    label(i-21) = 'Image ' + string(i);
end
hold off;
legend(label);
title("MTF of pictures");
xlabel("LP/PH");
ylabel("MTF");

% % Contrast
% figure;
% hold on;
% for i=11:17
%     plot(LPPHContainer{i},contrastContainer{i});
%     label(i-10) = 'Image ' + string(i);
% end
% hold off;
% legend(label);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=18:24
%     plot(LPPHContainer{i},contrastContainer{i});
%     label(i-17) = 'Image ' + string(i);
% end
% hold off;
% legend(label);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=25:31
%     plot(LPPHContainer{i},contrastContainer{i});
%     label(i-24) = 'Image ' + string(i);
% end
% hold off;
% legend(label);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=32:35
%     plot(LPPHContainer{i},contrastContainer{i});
%     label(i-31) = 'Image ' + string(i);
% end
% hold off;
% legend(label);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
