clear all;
close all;
clc;



%% Load Images
% Choose.
dataSet = "6m";
% dataSet = "23m";

% Edit this line individually.
%folder_path = "C:\Users\david\Desktop\roz\projekt\20240222";
folder_path = "E:\Škola\Rocnik5\MPC-ROZ\projekt\project_MPC-ROZ\Dataset";
image_files = dir(fullfile(folder_path, "*"+dataSet+".png"));

for i = 1:numel(image_files)
    file_path = fullfile(folder_path, image_files(i).name);
    original_image = imread(file_path);
    all_images{1, i} = original_image;
end


%% Augment
clear augmentedImages
augmentedImages = AugmentData(all_images, 0, 0.0003 , 0, 5, 0.05);

%% Compute 
angles = 1:360;

for j = 1:6
    
   % Choose.
% frequencyType = "Line Pairs / Picture Height";
frequencyType = "Line Pairs / Pixel";
    for i=11:35
        %I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_"+dataSet+".png");
        I = augmentedImages{j, i- 10};
        [imgHeight,imgWidth] = size(I);
    
        % Find initial center of star.
        centerOfStar= findCenterOfStar(I);
    
        % Find max radius of star.
        if dataSet == "6m"
            maxRadius = findMaxRadius(I, imgHeight, imgWidth, centerOfStar, frequencyType);
    %             maxRadius = 80;
        elseif dataSet == "23m"
            maxRadius = 40;
        end
        maxRadiusKnown = true;
    
    %     figure;
    %     imshow(I);
    %     hold on;
    %     title("Center of star, image " + string(i));
    %     plot(centerOfStar(1),centerOfStar(2),'Color','green','Marker','+','MarkerSize',10);
    %     drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', maxRadius,'StripeColor','red'); 
    %     hold off
    
        % Refine location of center.
        centerOfStar = refineCenterOfStarLocation(I, maxRadius, centerOfStar);
    
        %figure
        %imshow(I);
        %hold on;
        %title("Refined center of star, image " + string(i));
        %plot(centerOfStar(1),centerOfStar(2),'Color','green','Marker','+','MarkerSize',10);
        %drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', maxRadius,'StripeColor','red');
        %hold off;
    
        % Estimate number of line pairs in star.
        pixelValues = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, maxRadius);
        [peaks,locs] = findpeaks(double(pixelValues));
        TF = islocalmin(pixelValues);
        numberOfLinePairsOfStar = width(peaks);
    % 
    %     figure;
    %     plot(angles,pixelValues);
    %     hold on;
    %     title("radius = " + string(maxRadius) + ", angle step size = 1 deg")
    %     xlabel("angles [rad]");
    %     ylabel("Digital values"); 
    %     plot(locs,peaks,"g+");
    %     plot(find(TF == 1),pixelValues(TF),"r+");
    %     hold off;
    
        [frequency, C, MTF] = estimateMTF(I, imgHeight, imgWidth, centerOfStar, ...
            numberOfLinePairsOfStar, maxRadius, maxRadiusKnown, frequencyType);
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
        frequencyContainer{i-10} = frequency;
        CContainer{i-10} = C;
    end
    
    if dataSet == "6m"
        MTFContainer6m = MTFContainer;
        frequencyContainer6m = frequencyContainer;
        CContainer6m = CContainer;
    elseif dataSet == "23m"
        MTFContainer23m = MTFContainer;
        frequencyContainer23m = frequencyContainer;
        CContainer23m = CContainer;
    end
    
    %% Visualization
    
    % Choose:
    MTFOrC = "MTF";
    % MTFOrC = "C";
    
    if MTFOrC == "MTF"
        visualize(dataSet, MTFOrC, frequencyContainer, MTFContainer, frequencyType);
    elseif MTFOrC == "C"
        visualize(dataSet, MTFOrC, frequencyContainer, CContainer, frequencyType);
    end
    
    %% Feature extraction
    
    % Choose.
    feature = "MTF50";
    % feature = "CNyquist";
    
    % MTF50 - frequency where MTF is 0.5
    if feature == "MTF50"
        MTF50 = estimateMTF50(MTFContainer, frequencyContainer, dataSet);
        featurePlot(MTF50,"MTF50", dataSet)
        if frequencyType == "Line Pairs / Picture Height"
            threshold = 1166;
        elseif frequencyType == "Line Pairs / Pixel"
            threshold = 0.535;
        end
         xline(threshold)
        hold off;
    end
    
    % CNyquist - contrast where frequency is 0.5 cycles/pixel
    if feature == "CNyquist"
        CNyquist = estimateCNyquist(CContainer, frequencyContainer, dataSet);
        featurePlot(CNyquist,"CNyquist", dataSet);
    %     threshold = 0.207;
    %     xline(threshold)
        hold off;
    end
    
    %% Evaluation
    % Choose.
    feature = "MTF50";
    %feature = "CNyquist";
    
    % Evaluate for set threshold.
    if feature == "MTF50"
        [TPR,FPR,TNR,precision,accuracy]  = evaluate(MTF50, threshold, dataSet);
    elseif feature == "CNyquist"
        [TPR,FPR,TNR,precision,accuracy]  = evaluate(CNyquist, threshold, dataSet);
    end
    
    % ROC
    if feature == "MTF50"
        minfrequency = min(MTF50)-0.0001;
        maxfrequency = max(MTF50)+0.0001;
        step = (maxfrequency - minfrequency)/100;
        thresholdForROC = minfrequency:step:maxfrequency;
    elseif feature == "CNyquist"
        thresholdForROC = 0:0.01:1;
    end
    
    FPRVec = zeros(1,width(thresholdForROC));
    TPRVec = zeros(1,width(thresholdForROC));
    if feature == "MTF50"
        for i=1:width(thresholdForROC)
            [TPR,FPR,TNR,precision,accuracy]  = evaluate(MTF50, thresholdForROC(i), dataSet);
            FPRVec(i) = FPR;
            TPRVec(i) = TPR;
        end
    elseif feature == "CNyquist"
        for i=1:width(thresholdForROC)
            [TPR,FPR,TNR,precision,accuracy]  = evaluate(CNyquist, thresholdForROC(i), dataSet);
            FPRVec(i) = FPR;
            TPRVec(i) = TPR;
        end
    end
    
    figure
    plot(FPRVec,TPRVec)
    AUC = abs(trapz(FPRVec, TPRVec));
    legend("AUC = " + string(AUC),"Location","southeast")
    title("ROC curve for" + dataSet)
    xlabel("FPR - False positive rate")
    ylabel("TPR - True positive rate")
end