% Get intensity profile of given circle.
function [pixelValues, outOfBoundary]= pixelValuesOfCircle(I,imgHeight, imgWidth, centerOfCircle, radius)
% 
% figure;
% imshow(I)
% title('Radius = ' + string(radius));
% hold on;
% plot(centerOfCircle(1),centerOfCircle(2),'r+', 'MarkerSize', 10);
% viscircles(centerOfCircle,radius);

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