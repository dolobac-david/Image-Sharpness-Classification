function visualize(dataSet, MTFOrC, frequencyContainer, MTFOrCContainer, frequencyType)

figure;
hold on;
for i=1:7
    plot(frequencyContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(1:7));
title(MTFOrC+ " of pictures");
xlabel(frequencyType);
ylabel(MTFOrC);

figure;
hold on;
for i=8:14
    plot(frequencyContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(8:14));
title(MTFOrC+" of pictures");
xlabel(frequencyType);
ylabel(MTFOrC);

figure;
hold on;
for i=15:21
    plot(frequencyContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(15:21));
title(MTFOrC+" of pictures");
xlabel(frequencyType);
ylabel(MTFOrC);

figure;
hold on;
for i=22:25
    plot(frequencyContainer{i},MTFOrCContainer{i});
    label(i) = 'Image ' + string(i+10) + ' from '+dataSet;
end
hold off;
legend(label(22:25));
title(MTFOrC+" of pictures");
xlabel(frequencyType);
ylabel(MTFOrC);
end