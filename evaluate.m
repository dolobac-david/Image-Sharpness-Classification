function [TPR,FPR,TNR,precision,accuracy]  = evaluate(features, threshold, dataSet)

% 1 - sharp image, positive; 0 - blurry image, negative.
predictedlabels = features > threshold;
GTLabels = nan(1,width(features));

% Exclude images where star was not detected
if dataSet == "6m"
    idxSharp = [4 5 10 12 14 18 20];
    idxBlur = [1 2 8 15 16 21 22];
elseif dataSet == "23m"
    idxSharp = [4 5 10 12 14 18 20];
    idxBlur = [1 8 11 15 16 21 22];
end

GTLabels(idxSharp) = 1;
GTLabels(idxBlur) = 0;

TP = nnz(GTLabels == 1 & predictedlabels == 1);
FP = nnz(GTLabels == 0 & predictedlabels == 1);
FN = nnz(GTLabels == 1 & predictedlabels == 0);
TN = nnz(GTLabels == 0 & predictedlabels == 0);

P = TP + FN;
N = TN + FP;

% TPR (true positive rate) sensitivity
TPR = TP/P;
% False positive rate
FPR = FP/N;
% TNR (true negative rate) specificity
TNR = TN/N;
precision = TP/(TP+FP);
accuracy = (TP+TN)/(P+N);
end