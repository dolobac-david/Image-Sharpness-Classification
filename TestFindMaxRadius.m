clear all
close all


folder_path = 'cropped/23m';
image_files = dir(fullfile(folder_path, '*.png'));

all_images = cell(1, numel(image_files));
for i = 1:numel(image_files)
    file_path = fullfile(folder_path, image_files(i).name);
    original_image = imread(file_path);
    all_images{1, i} = original_image;
end

figure(1)
imshow(all_images{1, 1});

center_of_star = cell(1, size(all_images, 2));
for i = 1:size(all_images, 2)
    center_of_star{1, i} = refineCenterOfStarLocation(all_images{1, i});
end

radius = FindMaxRadius(all_images, center_of_star);



%%
for i = 1:size(all_images, 2)
    figure(9+i)
    imshow(all_images{1, i});
    hold on
    drawcircle('Center',[center_of_star{1, i}],'Radius', double(radius{i}),'StripeColor','red');    %max circle
    plot(center_of_star{1, i}(1,1), center_of_star{1, i}(1,2), 'go', 'MarkerSize', 7);              %centre
    title(['Max Circle Data [', num2str(i), ']']);
    hold off
end




















%% FUNCTIONS

function radius = FindMaxRadius(data, center_of_star)

    radius = cell(1, size(data, 2));
    for image_idx = 1:size(data, 2)
        if size(data{1, image_idx}, 3) == 3
            gray_image = rgb2gray(data{1, image_idx});
        else
            gray_image = data{1, image_idx};
        end
        
        threshold = graythresh(gray_image);
        binary_image = imbinarize(gray_image, threshold);
        se = strel('disk', 1);
        eroded_image = imerode(binary_image, se);
%         figure(66)
%         imshow(eroded_image)
%         title(['Eroded Image data[', num2str(image_idx), ']']);
        boundary_image = binary_image - eroded_image;
%         figure(67)
%         imshow(boundary_image)
%         title(['Boundary Image data[', num2str(image_idx), ']']);

        figure(99)
        imshow(data{1, image_idx});
        hold on;
        boundaries = bwboundaries(boundary_image);
        euc_dist = zeros(1, length(boundaries));
        per_boundry_idx = zeros(1, length(boundaries));

        for k = 1:length(boundaries)
            b_tmp = zeros(1, length(boundaries{k}));
            for b_idx = 1:length(boundaries{k})
                b_tmp(b_idx) = pdist([center_of_star{1, image_idx}; [boundaries{k}(1,2), boundaries{k}(1,1)]], 'euclidean');
            end
            [euc_dist(k), per_boundry_idx(k)] = max(b_tmp);
            boundary = boundaries{k};
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
            title(['Boundaries for data[', num2str(image_idx), ']']);

        end
        
        radius{1, image_idx} =  max(euc_dist) - 4;  % "-3" random number, to just make sure the 'max' circle is inside the Siemens star
        drawcircle('Center',[center_of_star{1, image_idx}],'Radius', double(radius{image_idx}),'StripeColor','red');    %max circle
        plot(center_of_star{1, image_idx}(1,1), center_of_star{1, image_idx}(1,2), 'go', 'MarkerSize', 7);              %centre
        hold off
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
