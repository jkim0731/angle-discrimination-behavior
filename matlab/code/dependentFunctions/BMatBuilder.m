function outcomes = BMatBuilder(currBMat,wfa)

numTrials= intersect(wfa.trialNums, currBMat.trialNums);
numTrialsIndB = find(ismember(currBMat.trialNums, numTrials));

tCorrect = nan(1,length(numTrialsIndB));
ttype = nan(1,length(numTrialsIndB));
servoAngles = nan(1,length(numTrialsIndB)); 
for b = 1:length(numTrialsIndB)
    type = currBMat.trials{numTrialsIndB(b)}.trialType(1);
    servoAngles(b) = currBMat.trials{numTrialsIndB(b)}.servoAngle; 
    tCorrect(b) = currBMat.trials{numTrialsIndB(b)}.trialCorrect;
    if strcmp(type,'r')
        ttype(b) = 1;
    elseif strcmp(type,'l')
        ttype(b) = 0;
    else 
        ttype(b) = nan;
    end
end

rlick = zeros(1,length(numTrialsIndB));
llick = zeros(1,length(numTrialsIndB));

rlick(intersect(find(ttype==1),find(tCorrect==1))) = 1;
rlick(intersect(find(ttype==0),find(tCorrect==0))) = 1;
llick(intersect(find(ttype==0),find(tCorrect==1))) = 1; 
llick(intersect(find(ttype==1),find(tCorrect==0))) = 1; 

% ** TOUCH TRIALS NEED TO BE POPULATED BY DESIGN MATRIX ** %
outcomes.labels = {'R trials','L trials','R lick','L lick','trialCorrect','servoAngles','touchTrials'};
outcomes.matrix = [ttype ==1 ; ttype == 0; rlick ; llick ; tCorrect ; servoAngles ; ones(1,length(servoAngles))];
