function featurePlot(feature,featureName, dataSet)
figure;
hold on;
for i=1:width(feature)

    % Stars not detected.
    if dataSet == "6m"
        if i == 7 || i == 11
            continue;
        end
    elseif dataSet == "23m"
        if i == 2 || i == 7 || i == 25
            continue;
        end
    end

    if i==4 || i==5 || i==10 || i==12 || i==14 || i==18 || i==20   
        plot(feature(i),i+10,'g+', 'MarkerSize', 10);
    elseif i==1 || i==2 || i==7 || i==8 || i==11 || i==15 || i==16 || i==21 || i==22
        plot(feature(i),i+10,'r+', 'MarkerSize', 10);
    else
        plot(feature(i),i+10,'b+', 'MarkerSize', 10);
    end
end
title(featureName +" of pictures from " + dataSet);
xlabel(featureName);
ylabel("Images");