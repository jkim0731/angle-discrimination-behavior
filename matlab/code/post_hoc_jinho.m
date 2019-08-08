% exclusion method to calculate the importantce of each features in object angle and choice prediction
% using already built data structures

% there are 10 iterations. I can either calculate importance in each
% iteration and then average, or average the coefficients and then
% calculate the importance.

% basic settings
mdlName = 'mdlDiscreteNaiveMeanTouch_12features';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])
%%
% (1) calculate and then average. First need to test if applying to the
% full data matches well with only to the test data (hope that it
% is not too much better than applying to test data)
nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
fitTotal = zeros(nGroup, nIter);
fitModel = zeros(nGroup, nIter);
for gi = 1 : nGroup
% for i = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);    
    for ii = 1 : nIter
%     for ii = 1
        coeffs = groupMdl{gi}.fitCoeffs{ii};
        predMat = dataX * coeffs;
        [~,idx] = max(predMat, [], 2);
        predY = listOfY(idx);
        fitTotal(gi,ii) = 1-length(find(dataY-predY))/length(dataY);
        
    end
    fitModel(gi,:) = groupMdl{gi}.gof.modelAccuracy;
end
% %%
mean(mean(fitTotal - fitModel))

%% 
%% 4.8 % increase in discrete naive touch
%% 6.47 % increase in discrete expert touch


%% what about averaging the coefficients first?
nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
fitTotal = zeros(nGroup, 1);
fitModel = zeros(nGroup, 1);
for gi = 1 : nGroup
% for i = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = zeros(size(groupMdl{gi}.fitCoeffs{1}));
    for ii = 1 : nIter
%     for ii = 1
        coeffs = coeffs + groupMdl{gi}.fitCoeffs{ii}/nIter;
    end
    
    predMat = dataX * coeffs;
    [~,idx] = max(predMat, [], 2);
    predY = listOfY(idx);
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    fitModel(gi,1) = mean(groupMdl{gi}.gof.modelAccuracy);
end

mean(fitTotal - fitModel)


%%
%% 6.42 % increase in discrete naive touch
%% 8.43 % increase in discrete expert touch
%%

%% How about in choices?
mdlName = 'mdlDiscreteExpertChoice_12features_answer';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

%% first, calculate first and then average
nGroup = length(groupMdl);
nIter = size(groupMdl{1}.fitCoeffs,2);
fitTotal = zeros(nGroup, nIter);
fitModel = zeros(nGroup, nIter);
for gi = 1 : nGroup
% for i = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;  
    for ii = 1 : nIter
%     for ii = 1
        coeffs = groupMdl{gi}.fitCoeffs(:,ii);
        predMat = dataX * coeffs;
        predY = (1./(1+exp(-predMat))) > 0.5;
        fitTotal(gi,ii) = mean(dataY == predY);
    end
    fitModel(gi,:) = groupMdl{gi}.gof.modelAccuracy;
end
% %%
mean(mean(fitTotal - fitModel))

%% then, average coefficients first and then calculate
nGroup = length(groupMdl);
nIter = size(groupMdl{1}.fitCoeffs,2);
fitTotal = zeros(nGroup, 1);
fitModel = zeros(nGroup, 1);
for gi = 1 : nGroup
% for i = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;  
    coeffs = mean(groupMdl{gi}.fitCoeffs,2);
    predMat = dataX * coeffs;
    predY = (1./(1+exp(-predMat))) > 0.5;
    fitTotal(gi) = mean(dataY == predY);
    fitModel(gi) = mean(groupMdl{gi}.gof.modelAccuracy);
end
% %%
mean(mean(fitTotal - fitModel))


%%
%% 0.0119 increase for calculating and then averaging
%% 0.0173 increase for averaging and then calculating
%%



%%
%% I have added train and test indices in the results 2019/07/29
%% so now I can test the effect of reducing coefficient in the each individual iterations
%%

%% Importance of features. First, choice.
mdlName = 'mdlRadialDistanceChoice_12features_answer';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])
nGroup = length(groupMdl);
nIter = size(groupMdl{1}.fitCoeffs,2);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
%% (1) calculate in test set of each iteration
%% (2) from each iteration and test the whole set
%% (3) from averaged coefficients and test the whole set

%% But, first of all, look at the coeficients (absolute value)
allCoeffs = cell2mat(cellfun(@(x) mean(abs(x.fitCoeffs),2), groupMdl', 'uniformoutput', false));
figure, 
% plot(0:nFeatures, mean(allCoeffs,2)), hold on
errorbar(0:nFeatures, mean(allCoeffs,2), std(allCoeffs, [], 2)/sqrt(nGroup))
xticks(1:nFeatures)
xticklabels(groupMdl{1}.fitCoeffsFields)
xtickangle(45)
title('Coefficients')
ylabel('Mean |Coefficient|')
%% (1) - taking one out

fitTotal = zeros(nGroup, 1+nFeatures, nIter);
for gi = 1 : nGroup
% for gi = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    testIdx = groupMdl{gi}.testIdx;
    for ii = 1 : nIter
        coeffs = groupMdl{gi}.fitCoeffs(:,ii);
        testDataX = dataX(testIdx{ii},:);
        testDataY = dataY(testIdx{ii});
        predMat = testDataX * coeffs;
        predY = (1./(1+exp(-predMat))) > 0.5;
        fitTotal(gi,1,ii) = mean(predY == testDataY);

        for fi = 1 : nFeatures
            tempDataX = testDataX(:,setdiff([1:nFeatures+1],fi+1));
            tempCoeffs = coeffs(setdiff([1:nFeatures+1],fi+1),:);
            tempPredMat = tempDataX * tempCoeffs;
            predY = (1./(1+exp(-tempPredMat))) > 0.5;
            fitTotal(gi,fi+1,ii) = mean(predY==testDataY);
        end
    end
end

figure, plot(0:nFeatures, mean(mean(fitTotal,3)), 'k-'), hold on
errorbar(0:nFeatures, mean(mean(fitTotal,3)), std(mean(fitTotal,3))/sqrt(nGroup), 'k.')
xticks(1:nFeatures)
xticklabels(groupMdl{1}.fitCoeffsFields)
xtickangle(45)
title('Importance - exclusion')
ylabel('Mean correlation between model and the choice')
%% (1) - just using the one

fitTotal = zeros(nGroup, 1+nFeatures, nIter);
for gi = 1 : nGroup
% for gi = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    testIdx = groupMdl{gi}.testIdx;
    for ii = 1 : nIter
        coeffs = groupMdl{gi}.fitCoeffs(:,ii);
        testDataX = dataX(testIdx{ii},:);
        testDataY = dataY(testIdx{ii});
        predMat = testDataX * coeffs;
        predY = (1./(1+exp(-predMat))) > 0.5;
        fitTotal(gi,1,ii) = mean(predY == testDataY);

        for fi = 1 : nFeatures
            tempDataX = testDataX(:,[1,fi+1]);
            tempCoeffs = coeffs([1,fi+1],:);
            tempPredMat = tempDataX * tempCoeffs;
            predY = (1./(1+exp(-tempPredMat))) > 0.5;
            fitTotal(gi,fi+1,ii) = mean(predY==testDataY);

        end
    end
end

figure, plot(0:nFeatures, mean(mean(fitTotal,3)), 'k-'), hold on
errorbar(0:nFeatures, mean(mean(fitTotal,3)), std(mean(fitTotal,3))/sqrt(nGroup), 'k.')
xticks(1:nFeatures)
xticklabels(groupMdl{1}.fitCoeffsFields)
xtickangle(45)
title('Importance - selection')
ylabel('Mean correlation between model and the choice')
%%
%% To match with glm for spikes, use averaged coeffs here.
%% It can be thought as another layer of cross-validation (it was proven to be more conservative than AIC, empirically in my neural glm)
%% When it comes to a question, I can just re run everything with individual iterations and then average them. 



%% Object angle prediction
% basic settings
mdlName = 'mdlDiscreteNaiveTouch_12features_lick';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
fitTotal = zeros(nGroup, 1+nFeatures);

for gi = 1 : nGroup
% for i = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = zeros(size(groupMdl{gi}.fitCoeffs{1}));
    for ii = 1 : nIter
%     for ii = 1
        coeffs = coeffs + groupMdl{gi}.fitCoeffs{ii}/nIter;
    end
    
    predMat = dataX * coeffs;
    [~,idx] = max(predMat, [], 2);
    predY = listOfY(idx);
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    
    for fi = 1 : nFeatures
        tempDataX = dataX(:,setdiff(1:nFeatures+1, fi+1));
        tempCoeffs = coeffs(setdiff(1:nFeatures+1, fi+1),:);
        predMat = tempDataX * tempCoeffs;
        [~,idx] = max(predMat, [], 2);
        predY = listOfY(idx);
        fitTotal(gi,fi+1) = 1-length(find(dataY-predY))/length(dataY);
    end    
end

figure, plot(0:nFeatures, mean(fitTotal), 'k-'), hold on
errorbar(0:nFeatures, mean(fitTotal), std(fitTotal)/sqrt(nGroup), 'k.')
 
%%
mdlName = 'mdlDiscreteExpertTouch_12features_lick';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
fitTotal = zeros(nGroup, 1+nFeatures);

for gi = 1 : nGroup
% for i = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = zeros(size(groupMdl{gi}.fitCoeffs{1}));
    for ii = 1 : nIter
%     for ii = 1
        coeffs = coeffs + groupMdl{gi}.fitCoeffs{ii}/nIter;
    end
    
    predMat = dataX * coeffs;
    [~,idx] = max(predMat, [], 2);
    predY = listOfY(idx);
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    
    for fi = 1 : nFeatures
        tempDataX = dataX(:,setdiff(1:nFeatures+1, fi+1));
        tempCoeffs = coeffs(setdiff(1:nFeatures+1, fi+1),:);
        predMat = tempDataX * tempCoeffs;
        [~,idx] = max(predMat, [], 2);
        predY = listOfY(idx);
        fitTotal(gi,fi+1) = 1-length(find(dataY-predY))/length(dataY);
    end
end

figure, plot(0:nFeatures, mean(fitTotal), 'k-'), hold on
errorbar(0:nFeatures, mean(fitTotal), std(fitTotal)/sqrt(nGroup), 'k.')


%% Choice

%%
mdlName = 'mdlDiscreteNaiveChoice_12features_answer';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
fitTotal = zeros(nGroup, 1+nFeatures);
diffY = zeros(nGroup, nFeatures);
for gi = 1 : nGroup
% for gi = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = mean(groupMdl{gi}.fitCoeffs,2);
    
    predMat = dataX * coeffs;    
    predY = (1./(1+exp(-predMat))) > 0.5;
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    
    for fi = 1 : nFeatures
%         tempDataX = dataX(:,[1, fi+1]);
%         tempCoeffs = coeffs([1, fi+1],:);
        tempDataX = dataX(:,setdiff([1:nFeatures+1],fi+1));
        tempCoeffs = coeffs(setdiff([1:nFeatures+1],fi+1),:);
        tempPredMat = tempDataX * tempCoeffs;
        predY = (1./(1+exp(-tempPredMat))) > 0.5;
        fitTotal(gi,fi+1) = 1-length(find(dataY-predY))/length(dataY);
        diffY(gi,fi) = mean(abs(predMat - tempPredMat));
    end
end

figure, plot(0:nFeatures, mean(fitTotal), 'k-'), hold on
errorbar(0:nFeatures, mean(fitTotal), std(fitTotal)/sqrt(nGroup), 'k.')

figure, plot(mean(diffY))
%%
mdlName = 'mdlDiscreteExpertChoice_12features_lick';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
fitTotal = zeros(nGroup, 1+nFeatures);
diffY = zeros(nGroup, nFeatures);
for gi = 1 : nGroup
% for gi = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = mean(groupMdl{gi}.fitCoeffs,2);
    
    predMat = dataX * coeffs;    
    predY = (1./(1+exp(-predMat))) > 0.5;
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    
    for fi = 1 : nFeatures
%         tempDataX = dataX(:,[1, fi+1]);
%         tempCoeffs = coeffs([1, fi+1],:);
        tempDataX = dataX(:,setdiff([1:nFeatures+1],fi+1));
        tempCoeffs = coeffs(setdiff([1:nFeatures+1],fi+1),:);
        tempPredMat = tempDataX * tempCoeffs;
        predY = (1./(1+exp(-tempPredMat))) > 0.5;
        fitTotal(gi,fi+1) = 1-length(find(dataY-predY))/length(dataY);
        diffY(gi,fi) = mean(abs(predMat - tempPredMat));
    end
end

figure, plot(0:nFeatures, mean(fitTotal), 'k-'), hold on
errorbar(0:nFeatures, mean(fitTotal), std(fitTotal)/sqrt(nGroup), 'k.')

figure, plot(mean(diffY))

%%
mdlName = 'mdlExpertMeanChoice_12features';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
fitTotal = zeros(nGroup, 1+nFeatures);
diffY = zeros(nGroup, nFeatures);
for gi = 1 : nGroup
% for gi = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = mean(groupMdl{gi}.fitCoeffs,2);
    
    predMat = dataX * coeffs;    
    predY = (1./(1+exp(-predMat))) > 0.5;
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    
    for fi = 1 : nFeatures
%         tempDataX = dataX(:,[1, fi+1]);
%         tempCoeffs = coeffs([1, fi+1],:);
        tempDataX = dataX(:,setdiff([1:nFeatures+1],fi+1));
        tempCoeffs = coeffs(setdiff([1:nFeatures+1],fi+1),:);
        tempPredMat = tempDataX * tempCoeffs;
        predY = (1./(1+exp(-tempPredMat))) > 0.5;
        fitTotal(gi,fi+1) = 1-length(find(dataY-predY))/length(dataY);
        diffY(gi,fi) = mean(abs(predMat - tempPredMat));
    end
end

figure, plot(0:nFeatures, mean(fitTotal), 'k-'), hold on
errorbar(0:nFeatures, mean(fitTotal), std(fitTotal)/sqrt(nGroup), 'k.')

figure, plot(mean(diffY))

%%
mdlName = 'mdlRadialDistanceMeanChoice_12features';
baseDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';
load([baseDir, mdlName])

nGroup = length(groupMdl);
nIter = length(groupMdl{1}.fitCoeffs);
nFeatures = length(groupMdl{1}.fitCoeffsFields);
fitTotal = zeros(nGroup, 1+nFeatures);
diffY = zeros(nGroup, nFeatures);
for gi = 1 : nGroup
% for gi = 1
    dataX = [ones(size(groupMdl{gi}.io.X,1),1),groupMdl{gi}.io.X];
    dataY = groupMdl{gi}.io.Y;
    listOfY = unique(dataY);
    coeffs = mean(groupMdl{gi}.fitCoeffs,2);
    
    predMat = dataX * coeffs;    
    predY = (1./(1+exp(-predMat))) > 0.5;
    fitTotal(gi,1) = 1-length(find(dataY-predY))/length(dataY);
    
    for fi = 1 : nFeatures
%         tempDataX = dataX(:,[1, fi+1]);
%         tempCoeffs = coeffs([1, fi+1],:);
        tempDataX = dataX(:,setdiff([1:nFeatures+1],fi+1));
        tempCoeffs = coeffs(setdiff([1:nFeatures+1],fi+1),:);
        tempPredMat = tempDataX * tempCoeffs;
        predY = (1./(1+exp(-tempPredMat))) > 0.5;
        fitTotal(gi,fi+1) = 1-length(find(dataY-predY))/length(dataY);
        diffY(gi,fi) = mean(abs(predMat - tempPredMat));
    end
end

figure, plot(0:nFeatures, mean(fitTotal), 'k-'), hold on
errorbar(0:nFeatures, mean(fitTotal), std(fitTotal)/sqrt(nGroup), 'k.')

figure, plot(mean(diffY))