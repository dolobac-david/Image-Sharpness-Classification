clear;
close all;
clc;

% % Load input images.
% imageDir = fullfile("20240222");
% imds = imageDatastore(imageDir);
% 
% for i=1:numel(imds.Files)-49
%     I=readimage(imds,i);
% 
%     IEdge = edge(I,"sobel");
% %     points = detectMinEigenFeatures(I);
% 
% %     figure;
% %     imshow(I);
% %     hold on;
% %     plot(points);
% %     hold off;
% % 
% %     figure
% %     imshow(IEdge)
% %     hold on;
% %     plot(points);
% %     hold off;
% 
% % [centers,radii]=imfindcircles(IEdge,[70,250]);
% figure
% imshow(I)
% 
% figure
% imshow(IEdge)
% % viscircles(centers,radii);
% end
% 
%%
clear;
close all;
clc;

I = imread("cropped\23m\star_left_VG25_2_011_GO_E2000_23m.png");
% I = imread("20240222\VG25_2_015_GO_E2000_23m.png");
imshow(I)

IEdge = edge(I,"sobel");
figure;
imshow(IEdge)

points = detectMinEigenFeatures(I);
figure;
imshow(I);
hold on;
plot(points);
hold off;

centerOfStar = findCenterOfStar(I);
radius = 30;

figure;
imshow(I)
hold on;
plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10)
title("Center of star")
hold off;

figure;
imshow(I)
hold on;
plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10)
viscircles(centerOfStar,radius);

for i=1:1:360
%     x = centerOfStar(1) + radius*cos(deg2rad(i));
%     y = centerOfStar(2) + radius*cos(deg2rad(i));
    
    x = centerOfStar(1) + radius*cos(deg2rad(i-1));
    y = centerOfStar(2) + radius*sin(deg2rad(i-1));
    plot(x,y,'g+', 'MarkerSize', 10)
end
hold off;
% J = imrotate(I,90);
% figure;
% imshow(J)
% title("Rotated image")
% 
% centerOfStar = findCenterOfStar(J);
% 
% figure;
% imshow(J)
% hold on;
% plot(centerOfStar(1),centerOfStar(2),'r+', 'MarkerSize', 10)
% title("Center of star - rotated image")
% hold off;

function centerOfStar = findCenterOfStar(I)

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