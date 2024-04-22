function visualize(dataSet, MTFOrC, LPPHContainer, MTFOrCContainer)

figure;
hold on;
for i=1:7
    plot(LPPHContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(1:7));
title(MTFOrC+ " of pictures");
xlabel("LP/PH");
ylabel(MTFOrC);

figure;
hold on;
for i=8:14
    plot(LPPHContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(8:14));
title(MTFOrC+" of pictures");
xlabel("LP/PH");
ylabel("MTFOrC");

figure;
hold on;
for i=15:21
    plot(LPPHContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(15:21));
title(MTFOrC+" of pictures");
xlabel("LP/PH");
ylabel(MTFOrC);

figure;
hold on;
for i=22:25
    plot(LPPHContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(22:25));
title(MTFOrC+" of pictures");
xlabel("LP/PH");
ylabel(MTFOrC);
end