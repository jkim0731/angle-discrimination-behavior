function lickMask = predecision_mask(currBMat,wfa)
%% build preDecision mask
% predecision is defined as time before first lick after answer period
% opening
% using any lick after point of lick change from left to right or vice versa as
% decision lick 

%JINHO CHECK: Not sure if we need to load a random wf.mat or we can just set manually to
%.0032
% randomTrial = datasample(1:length(currBMat.trials),1);
% load([num2str(randomTrial) '_WF_2pad.mat'])
% framePeriodinSec = wf.framePeriodInSec;

numTrials= intersect(wfa.trialNums, currBMat.trialNums);
numTrialsIndB = find(ismember(currBMat.trialNums, numTrials));
numTrialsIndW = find(ismember(wfa.trialNums, numTrials));

% 
% figure(580);clf
% subplot(3,1,[1:2])
decisionLick = nan(length(numTrialsIndB),1);
PoleOnsetTime = zeros(length(numTrialsIndB),1); 
AnswerPeriodOpening = PoleOnsetTime;

for i = 1:length(numTrialsIndB)
    
    timeW = wfa.trials{numTrialsIndW(i)}.time;
    pOnsetTime = currBMat.trials{numTrialsIndB(i)}.poleUpOnsetTime;
    answerTime = currBMat.trials{numTrialsIndB(i)}.answerPeriodTime(1);
    [~, PoleOnsetTime(i)] = min(abs(timeW-pOnsetTime));
    [~, AnswerPeriodOpening(i)] = min(abs(timeW-answerTime)); 
    
    
    bbt = currBMat.trials{numTrialsIndB(i)}.beamBreakTimes ;
    postAnswerLickFrames = bbt(bbt>answerTime);
    
    if ~isempty(postAnswerLickFrames)
          [~,decisionLick(i)] = min(abs(timeW-min(postAnswerLickFrames)));        
    end
% 
%     hold on; scatter(bbtInFrames,ones(length(bbtInFrames),1)*i,5,'m','filled')
end



%Fill trials w/ no answer licks with median decision lick time. This lets
%us look at features before "decision" to see what influenced mice to
%lick/notlick
decisionLick(isnan(decisionLick)) = nanmedian(decisionLick);

%Building a lick mask of 1s and NaNs. This'll be useful to find which
%preDecision features are gathered
lickMask = nan(5000,length(numTrialsIndB));
for i = 1:length(numTrialsIndB)
    lickMask(1:decisionLick(i),i) = 1;
end

%Plotting to visualize distribution of licks and mean sampling/answer
%period times
% set(gca,'xlim',[0 320])
% hold on; plot([mean(PoleOnsetTime) mean(PoleOnsetTime)],[0 length(numTrialsIndB)],'-.k','linewidth',2)
% hold on; plot([mean(AnswerPeriodOpening) mean(AnswerPeriodOpening)],[0 length(numTrialsIndB)],'-.g','linewidth',2)
% %Plotting to visualize distribution of decisionLicks
% figure(580);subplot(3,1,3)
% histogram(decisionLick,0:10:max(decisionLick))
% set(gca,'xlim',[0 320])

% figure(581);clf
% imagesc(lickMask')

