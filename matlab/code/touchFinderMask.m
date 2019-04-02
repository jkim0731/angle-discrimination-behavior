function [tOnsetMask, tDurationMask] = touchFinderMask(currBMat,wfa,whiskDir,touchOrder)

if strcmp(whiskDir,'protraction')
    tfchunks = 'protractionTFchunksByWhisking'; % this is only the protraction whisk of protraciton touches; can also set as protractionTFchunks whic hare pro+ret whisks on protraciton touches
elseif strcmp(whiskDir,'all')
    tfchunks = 'protractionTFchunks'; 
end

numTrials= intersect(wfa.trialNums, currBMat.trialNums);
numTrialsIndB = find(ismember(currBMat.trialNums, numTrials));
numTrialsIndW = find(ismember(wfa.trialNums, numTrials));


tOnsetMask = nan(5000,length(numTrialsIndW)); 
tDurationMask = nan(5000,length(numTrialsIndW)); 

for i = 1:length(numTrialsIndW)
    currTrial = numTrialsIndW(i);
    allTouches = wfa.trials{currTrial}.(tfchunks);
    
    if strcmp(touchOrder,'first')
        tOnsetFrame = cellfun(@(v) v(1),allTouches);
        if ~isempty(tOnsetFrame)
            tOnsetFrame = tOnsetFrame(1);
        end
    elseif strcmp(touchOrder,'all')
        tOnsetFrame = cellfun(@(v)v(1),allTouches);
    else
        error('need to select touch direction "all" or "first" ')
    end
    tOnsetMask(tOnsetFrame,i)=1; 
    
    tDurationMask(cell2mat(allTouches'),i) = 1; 
end

