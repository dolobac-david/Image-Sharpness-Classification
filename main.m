% clear;
% close all;
clc;

% Edit this line individually.
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";
angles = 1:360;

% Choose:
% dataSet = "6m";
dataSet = "23m";

for i=11:35
    I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_"+dataSet+".png");
    [imgHeight,imgWidth] = size(I);

    % Find initial center of star.
    initialCenterOfStar= findCenterOfStar(I);

    % Find max radius of star.
    if dataSet == "6m"
        maxRadius = findMaxRadius(I, imgHeight, imgWidth, initialCenterOfStar);
    elseif dataSet == "23m"
        maxRadius = 40;
    end
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

%     figure
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
    CContainer{i-10} = C;
end
if dataSet == "6m"
    MTFContainer6m = MTFContainer;
    LPPHContainer6m = LPPHContainer;
    CContainer6m = CContainer;
elseif dataSet == "23m"
    MTFContainer23m = MTFContainer;
    LPPHContainer23m = LPPHContainer;
    CContainer23m = CContainer;
end

%% Visualization

% Choose:
% MTFOrC = "MTF";
MTFOrC = "C";

if MTFOrC == "MTF"
    visualize(dataSet, MTFOrC, LPPHContainer, MTFContainer);
elseif MTFOrC == "C"
    visualize(dataSet, MTFOrC, LPPHContainer, CContainer);
end
%% 

% for i=1:width(LPPHContainer)
%     LPPH = LPPHContainer{i};
%     offset = LPPH(1) - 350;
%     LPPHContainerOffset{i} = LPPHContainer{i} - offset;
% end

% % MTF50 or F50 - frequency where MTF is 0.5
% MTF50 = estimateMTF50(MTFContainer23m, LPPHContainer23m, dataSet);
% featurePlot(MTF50,"MTF50", dataSet)
% threshold = 1166; % from MTF50
% xline(threshold)
% hold off;

% C1200 - contrast where frequency is 1200 LP/PH
C1200 = estimateC1200(CContainer, LPPHContainer, dataSet);
featurePlot(C1200,"C1200", dataSet);
threshold = 0.207; % from C1200
xline(threshold)
hold off;
%%  Visualization 6m and 23m
% % MTF 
% figure;
% hold on;
% for i=1:3
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=1:3
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(1:3) label23m(1:3)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=4:6
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=4:6
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(4:6) label23m(4:6)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=5:7
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=5:7
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(5:7) label23m(5:7)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=8:10
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=8:10
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(8:10) label23m(8:10)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=11:13
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=11:13
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(11:13) label23m(11:13)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=14:16
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=14:16
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(14:16) label23m(14:16)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=17:19
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=17:19
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(17:19) label23m(17:19)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=20:22
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=20:22
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(20:22) label23m(20:22)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");
% 
% figure;
% hold on;
% for i=23:25
%     plot(LPPHContainer6m{i},MTFContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=23:25
%     plot(LPPHContainer23m{i},MTFContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(23:25) label23m(23:25)]);
% title("MTF of pictures");
% xlabel("LP/PH");
% ylabel("MTF");

% % Contrast
% figure;
% hold on;
% for i=1:3
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=1:3
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(1:3) label23m(1:3)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=4:6
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=4:6
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(4:6) label23m(4:6)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=5:7
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=5:7
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(5:7) label23m(5:7)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=8:10
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=8:10
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(8:10) label23m(8:10)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=11:13
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=11:13
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(11:13) label23m(11:13)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=14:16
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=14:16
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(14:16) label23m(14:16)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=17:19
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=17:19
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(17:19) label23m(17:19)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=20:22
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=20:22
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(20:22) label23m(20:22)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");
% 
% figure;
% hold on;
% for i=23:25
%     plot(LPPHContainer6m{i},contrastContainer6m{i});
%     label6m(i) = 'Image ' + string(i+10) + ' from 6 m';
% end
% for i=23:25
%     plot(LPPHContainer23m{i},contrastContainer23m{i});
%     label23m(i) = 'Image ' + string(i+10) + ' from 23 m';
% end
% hold off;
% legend([label6m(23:25) label23m(23:25)]);
% title("C of pictures");
% xlabel("LP/PH");
% ylabel("C");