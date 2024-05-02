clear all
close all
clc

%fileName = "C:\Users\david\Desktop\roz\projekt\20240222";
fileName = "E:\Škola\Rocnik5\MPC-ROZ\projekt\project_MPC-ROZ\Dataset";

% Choose:
 dataSet = "6m";
%  dataSet = "23m";

% frequencyType = "Line Pairs / Picture Height";
frequencyType = "Line Pairs / Pixel";
  j = 1;
for i=11:35
    I = imread(fileName + "\VG25_2_0"+string(i)+"_GO_E2000_"+dataSet+".png");
    [imgHeight,imgWidth] = size(I);

    % Find initial center of star.
    initialCenterOfStar= findCenterOfStar(I);

    % Find max radius of star.
    if dataSet == "6m"
        maxRadius = findMaxRadius(I, imgHeight, imgWidth, initialCenterOfStar, frequencyType);
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
    max_radius_circle = maxRadius*0.35;

    centerOfStar = refineCenterOfStarLocation(I, max_radius_circle, initialCenterOfStar);

%     figure
%     imshow(I);
%     hold on;
%     title("Refined center of star, image " + string(i));
%     plot(centerOfStar(1),centerOfStar(2),'Color','green','Marker','+','MarkerSize',10);
%     drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', maxRadius,'StripeColor','red');
%     hold off;

    % Estimate number of line pairs in star.
    pixelValues{1, i-10} = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, maxRadius);

    %if(i == 11)
        figure(i-10)
        imshow(I);
        hold on;
        title("Center of star, image " + string(i));
        drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', max_radius_circle,'StripeColor','red');    %max circle
    %end
    %figure
    %plot(pixelValues{1, j})
    %title("Pixels of " + i);
    %j = j + 1;
end


%% Filtering
for i=1:25
    data = pixelValues{1,i};
    fs = 1000;
    t = (0:length(data)-1) / fs;
    order = 4;
    cutoff_freq = 35; % Cutoff frequency (Hz)
    [b, a] = butter(order, cutoff_freq/(fs/2), 'high');
    filtered_data{1,i} = filter(b, a, data);
end


%% Autocorrelation
for i = 1:25
autocorr_values = autocorr(filtered_data{1,i}, 359);

% Plot autocorrelation
%stem(360, autocorr_values)
%figure(i+50);

    figure(i+25);
    subplot(3,1,1);
    plot(t, pixelValues{1,i});
    title("Original Data Series" + (i+10));
    xlabel('Time (s)');
    ylabel('Value');
    
    subplot(3,1,2);
    plot(t, filtered_data{1,i});
    title('Filtered Data Series (High-pass Butterworth)');
    xlabel('Time (s)');
    ylabel('Value');
    
    subplot(3,1,3);
    plot(autocorr_values)
    xlabel('Lag')
    ylabel('Autocorrelation')
    title("Autocorrelation of Signal:" + (i+10))



end