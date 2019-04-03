function featureMat = featureBuilder(currBMat,wfa)

numTrials= intersect(wfa.trialNums, currBMat.trialNums);
numTrialsIndB = find(ismember(currBMat.trialNums, numTrials));
numTrialsIndW = find(ismember(wfa.trialNums, numTrials));

featureMat.theta = nan(5000,length(numTrialsIndW)); 
featureMat.phi =nan(5000,length(numTrialsIndW)); 
featureMat.kappaH = nan(5000,length(numTrialsIndW)); 
featureMat.kappaV =nan(5000,length(numTrialsIndW)); 
featureMat.arcLength =nan(5000,length(numTrialsIndW)); 

for i = 1:length(numTrialsIndW)
     currTrial = numTrialsIndW(i);
     featureMat.theta(1:length(wfa.trials{currTrial}.theta),i) = wfa.trials{currTrial}.theta; 
     featureMat.phi(1:length(wfa.trials{currTrial}.phi),i) = wfa.trials{currTrial}.phi; 
     featureMat.kappaH(1:length(wfa.trials{currTrial}.kappaH),i) = wfa.trials{currTrial}.kappaH; 
     featureMat.kappaV(1:length(wfa.trials{currTrial}.kappaV),i) = wfa.trials{currTrial}.kappaV; 
     featureMat.arcLength(1:length(wfa.trials{currTrial}.arcLength),i) = wfa.trials{currTrial}.arcLength; 
end