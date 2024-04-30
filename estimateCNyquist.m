function CNyquist = estimateCNyquist(CContainer, frequencyContainer, dataSet)

CNyquist = nan(1,width(CContainer));
for i=1:width(CContainer)
    % Find contrast where frequency is 0.5 cycles / pixel, approximately between two closest points.
    C = CContainer{i};
    frequency = frequencyContainer{i};
    a = find(frequency > 0.5);
    idx = a(1);
    if dataSet == "6m"
        if i == 7 || i == 11
            continue;
        end
    elseif dataSet == "23m"
        if i == 2 || i == 7 || i == 25
            continue;
        end
    end
    CNyquist(i) = interp1([frequency(idx)  frequency(idx-1)], [C(idx)  C(idx-1)], 0.5);
end
end