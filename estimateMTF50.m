% MTF50 or F50 - frequency where MTF is 0.5
function MTF50 = estimateMTF50(MTFContainer, frequencyContainer, dataSet)
MTF50 = nan(1,width(MTFContainer));
for i=1:width(MTFContainer)
    % Find frequency of MTF = 0.50 approximately between two closest points.
    MTF = MTFContainer{i};
    frequency = frequencyContainer{i};
    a = find(MTF > 0.5);
    idx = a(end);

    % Star was not detected.
    if dataSet == "6m"
        if i == 7 || i == 11
            continue;
        end
    elseif dataSet == "23m"
        if i == 2 || i == 7 || i == 25
            continue;
        end
    end
    MTF50(i) = interp1([MTF(idx)  MTF(idx+1)],[frequency(idx)  frequency(idx+1)], 0.5);
end
end