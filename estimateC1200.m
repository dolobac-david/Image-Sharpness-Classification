function C1200 = estimateC1200(CContainer, LPPHContainer, dataSet)

C1200 = zeros(1,width(CContainer));
for i=1:width(CContainer)
    % Find LP/PH where contrast is 1200, approximately between two closest points.
    C = CContainer{i};
    LPPH = LPPHContainer{i};
    a = find(LPPH > 1200);
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
    C1200(i) = interp1([LPPH(idx)  LPPH(idx-1)], [C(idx)  C(idx-1)], 1200);
end
end