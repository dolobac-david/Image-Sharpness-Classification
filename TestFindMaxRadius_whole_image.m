clear;
close all;
clc;

% Edit this line individually.
fileName = "C:\Users\david\Desktop\roz\projekt\20240222";
% fileName = "E:\Škola\Rocnik5\MPC-ROZ\projekt\project_MPC-ROZ\Dataset";

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
    %hold off;

    % Estimated center of star.
    centerOfStar = points.Location(idxOfPoint,:);

    % Estimate number of line pairs in star.
    maxRadius = 700;
    pixelValues = pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfStar, maxRadius);
    [peaks,locs] = findpeaks(double(pixelValues));
    numberOfLinePairsOfStar = width(peaks);

    % Transform circles around center of star into spatial frequency Line Pairs / Picture Height
    % and estimate contrast for every circle.
    radius_step = 2;
    radiusStep = maxRadius:-radius_step:10;
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

    %% Calculating the maximum radius
    %Get local Max/Min
    local_minima = islocalmin(MTF);
    local_maxima = islocalmax(MTF);
    
    first_min_idx = 0;
    % find the first local minimum after threshold
    MTF_threshold = 0.72;
    for min_idx = 1:size(MTF, 2)
        
        if((MTF(min_idx) < MTF_threshold) && local_minima(min_idx))
            first_min_idx = min_idx;
            break;
        end
    end

    %find min -> of local mins(5) -> after_first_min
    %indices_min -> idxs of all local_mins in MTF
    %indices_min_after_min -> the same, but after the first_min_idx and minima_cnt elements
    %min_after_min -> values of indices_min_after_min
    min_of_local_min = 0;
    minima_cnt = 7;
    indices_min = find(local_minima == 1);
    indices_min_after_min = find(indices_min >= first_min_idx);
    min_after_min = MTF(indices_min(indices_min_after_min(1:minima_cnt)));

    
    %if the 5 values don't have a local min, take the minimum from those
    val_mins = islocalmin(min_after_min);
    zero_idx = find(min_after_min==0, 1, 'first');      % if MTF==0 somewhere, it doesn't detect it as a local min
    if(zero_idx > 0)
        val_mins(zero_idx) = 1;
        no_local_min = 1;
    else
        no_local_min = 0;
        if(all(val_mins == 0))
            [~, im] = min(min_after_min);
            val_mins = zeros(1, minima_cnt);
            val_mins(im) = 1;
            no_local_min = 1;
        end
    end

    
    %find the minimum value of local minumus
    %min_local_min_idx -> where the local mins are
    %idx_mins -> which idx from min_local_min_idx it is
    %new_min_idx -> new local minimum
    min_local_min_idx = find(val_mins == 1);
    [~, idx_mins] = min(min_after_min(val_mins == 1));
    new_min_idx = indices_min(indices_min_after_min(min_local_min_idx(idx_mins)));

    % if 10% variation between highest minumum and last minumum in the minima_cnt
    % variation_idxs -> pair of idxs. [The original minumum, new minumum]
    variation_idxs = [min_local_min_idx(idx_mins), 0];
    variation_min = 10;
    [val, idx_var_min] = min(min_after_min);
    for m = 1:size(min_after_min, 2)
        if(idx_var_min == m)
            continue;
        end
        if(abs(val - min_after_min(m)) < min_after_min(m)/variation_min && m > variation_idxs(1)) % if within limit && is after the minimum value
            variation_idxs = [min_local_min_idx(idx_mins), m];
        end
    end

    %if there is one local minima before the Siemens Star (before the second peaks - maximas)
    if(MTF(new_min_idx) > MTF(first_min_idx) && no_local_min)
        new_min_idx = first_min_idx;
    end

    %if the variation was found
    if(variation_idxs(2) > 0)
        indices_max = find(local_maxima == 1);
        indices_max_after_min = find(indices_max > indices_min(indices_min_after_min(variation_idxs(2))) );
        %it is not after the local maxima after the new_min_idx/first_min_idx
        if(variation_idxs(2) > 0 && ( indices_max(indices_max_after_min(1)) > indices_min(indices_min_after_min(variation_idxs(2))) ))      % idx MTF > idx MTF
            new_min_idx = indices_min(indices_min_after_min(variation_idxs(2)));
        end
    end


    % find the first local maximum after the new_first local minimum
    indices_max = find(local_maxima == 1);
    indices_max_after_min = find(indices_max > new_min_idx);

    % max_radius_idx -> which MTF idx it is
    max_radius_idx = indices_max(indices_max_after_min(1));
    max_radius_circle = maxRadius - (max_radius_idx*radius_step);

    drawcircle('Center',[centerOfStar(1), centerOfStar(2)],'Radius', max_radius_circle,'StripeColor','red');    %max circle
    hold off
    %% Graph Plotting

    figure;
    plot(linePairsPerPictureHeight,MTF)
    title("MTF of picture "+string(i));
    xlabel("LP/PH");
    ylabel("MTF");
    hold on
    plot(linePairsPerPictureHeight ,MTF, linePairsPerPictureHeight(local_minima), MTF(local_minima),'r*')
    plot(linePairsPerPictureHeight ,MTF, linePairsPerPictureHeight(local_maxima), MTF(local_maxima),'b*')
    x_coords_min = [linePairsPerPictureHeight(first_min_idx), linePairsPerPictureHeight(first_min_idx)];
    y_coords_min = [0, 1];
    plot(x_coords_min, y_coords_min, 'g-', 'LineWidth', 2);

    if(~isempty(max_radius_idx))
        x_coords_max = [linePairsPerPictureHeight(max_radius_idx), linePairsPerPictureHeight(max_radius_idx)];
        y_coords_max = [0, max(MTF)];
        plot(x_coords_max, y_coords_max, 'g-', 'LineWidth', 2);
    else
        fprintf('NO MAX RADIUS FOUND [%i]\n', i)
    end

    hold off

end



















%% FUNCTIONS
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