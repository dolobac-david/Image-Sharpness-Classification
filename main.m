% clear;
% close all;
clc;

% Edit this line individually.
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";
angles = 1:360;

% Choose.
dataSet = "6m";
% dataSet = "23m";

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
%% Feature extraction

% Choose.
% feature = "MTF50";
feature = "C1200";

% MTF50 or F50 - frequency where MTF is 0.5
if feature == "MTF50"
    MTF50 = estimateMTF50(MTFContainer, LPPHContainer, dataSet);
    featurePlot(MTF50,"MTF50", dataSet)
    threshold = 1166; % from MTF50
    xline(threshold)
    hold off;
end

% C1200 - contrast where frequency is 1200 LP/PH
if feature == "C1200"
    C1200 = estimateC1200(CContainer, LPPHContainer, dataSet);
    featurePlot(C1200,"C1200", dataSet);
    threshold = 0.207; % from C1200
    xline(threshold)
    hold off;
end

%% Evaluation
% Choose.
% feature = "MTF50";
feature = "C1200";

if feature == "MTF50"
    [TPR,FPR,TNR,precision,accuracy]  = evaluate(MTF50, threshold, dataSet);
elseif feature == "C1200"
    [TPR,FPR,TNR,precision,accuracy]  = evaluate(C1200, threshold, dataSet);
end

% ROC
thresholdForROC = 0:0.01:1;
FPRVec = zeros(1,width(thresholdForROC));
TPRVec = zeros(1,width(thresholdForROC));
if feature == "MTF50"
    for i=1:width(thresholdForROC)
        [TPR,FPR,TNR,precision,accuracy]  = evaluate(MTF50, thresholdForROC(i), dataSet);
        FPRVec(i) = FPR;
        TPRVec(i) = TPR;
    end
elseif feature == "C1200"
    for i=1:width(thresholdForROC)
        [TPR,FPR,TNR,precision,accuracy]  = evaluate(C1200, thresholdForROC(i), dataSet);
        FPRVec(i) = FPR;
        TPRVec(i) = TPR;
    end
end

figure
plot(FPRVec,TPRVec)
AUC = abs(trapz(FPRVec, TPRVec));
legend("AUC = " + string(AUC),"Location","southeast")
title("ROC curve")
xlabel("FPR - False positive rate")
ylabel("TPR - True positive rate")