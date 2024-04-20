% Refine location of star centre in cropped image with star only. 
function centerOfStar = refineCenterOfStarLocation(I, maxRadius, initialCenter)

% Crop roi of star. 
pixelOffset = 5;
leftBoundary = initialCenter(1) - maxRadius - pixelOffset; 
rightBoundary = initialCenter(1) + maxRadius + pixelOffset;
topBoundary = initialCenter(2) - maxRadius - pixelOffset;
bottomBoundary = initialCenter(2) + maxRadius + pixelOffset;

ICropped = I(round(topBoundary):round(bottomBoundary), round(leftBoundary):round(rightBoundary));
rows = sum(ICropped,2);
cols = sum(ICropped,1);

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
points = detectMinEigenFeatures(ICropped);

% figure;
% imshow(ICropped)
% hold on;
% plot(x,y,'r+', 'MarkerSize', 10)
% plot(points);
% title("Initial center of star")
% hold off; 

dist = vecnorm((points.Location - centerGuess),2,2);
[~,idx] = min(dist);
centerOfCroppedStar = points.Location(idx,:);
centerOfStar(1) = centerOfCroppedStar(1) + round(leftBoundary)-1;
centerOfStar(2) = centerOfCroppedStar(2) + round(topBoundary)-1;

% figure;
% imshow(I);
% hold on;
% title("Center of star, image ");
% plot(centerOfStar(1),centerOfStar(2),'Color','green','Marker','+','MarkerSize',10);
% hold off;
end