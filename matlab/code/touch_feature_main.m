%% Define mouse and session number
clear

mns = [{'JK025'},{'JK027'},{'JK030'},{'JK036'},{'JK039'},{'JK052'}];
% sns = [{'S05'},{'S02'},{'S04'},{'S02'},{'S02'},{'S05'}]; %naive
% sns = [{'S18'},{'S07'},{'S20'},{'S16'},{'S21'},{'S20'}]; %expert
sns = [{'S19'},{'S16'},{'S21'},{'S17'},{'S23'},{'S25'}]; %discreteAngles
mdlName = 'mdlDiscreteExpertChoice';
whiskDir = 'protraction';
yOut = 'choice';
groupMdl = cell(length(mns),1); 
DmatSelect = [1:17]; %feats from 1:21

% GLM model parameters
glmnetOpt = glmnetSet;
glmnetOpt.standardize = 0; %set to 0 b/c already standardized
glmnetOpt.alpha = 0.95;
glmnetOpt.xfoldCV = 5;
glmnetOpt.numIterations = 10;

%%
for d = 1:length(sns)
    mouseNumber = mns{d};
    sessionNumber = sns{d};
    
    %% Load necessary files
    behaviorFolder = 'E:\SoloData';
    cd([behaviorFolder filesep mouseNumber]);
    load(['behavior_' mouseNumber '.mat']);
    
    whiskerFolder = ['E:\WhiskerVideo' filesep mouseNumber sessionNumber];
    
    bSessionNums = cellfun(@(x) x.sessionName, b,'uniformoutput',false);

    %find behavioral data matching session and load bMat
    bMatIdx = find(cell2mat(cellfun(@(x) strcmp(x,sessionNumber),bSessionNums,'uniformoutput',false)));
    behavioralStruct = b{bMatIdx};
    wfa = Whisker.WhiskerFinal_2padArray(whiskerFolder);
    
    %% Choice and ttype builder
    outcomes = BMatBuilder(behavioralStruct,wfa);
    outcomes.sessionNumber = sessionNumber;
    outcomes.mouseNumber = mouseNumber;
    %% Touch feature builder
    %instantaneous touch features
    it = instantTouchBuilder(behavioralStruct,wfa,whiskDir);
    %during touch features
    dt = duringTouchBuilder(behavioralStruct,wfa,whiskDir);
    
    %% Plotting of instantaneous and during touch features
    %can set 'yOut' to build feature distribution based on 'ttype' or 'choice'
%     featurePlotter(it,dt,outcomes,yOut)
    
    %% Design matrix construction
    [DmatXIT, DmatXDT, fieldsList] = designMatrixBuilder(it,dt);

    DmatX = [DmatXIT DmatXDT];

    DmatX = DmatX(:,DmatSelect);
    fieldsList = fieldsList(DmatSelect);

    % Dmat Y builder
    if strcmp(yOut,'ttype')
        DmatY = (outcomes.matrix(1,:)==1)';
    elseif strcmp(yOut,'choice')
        DmatY = (outcomes.matrix(3,:)==1)'; %REMOVE MISS TRIALS
    elseif strcmp(yOut,'discrete')
        DmatY = (outcomes.matrix(6,:))';
    end
    
    %removing nan values
    missTrials = find(outcomes.matrix(5,:) == -1)';
    [rowsNAN, ~] = find(isnan(DmatX));
    [rowsINF, ~] = find(isinf(DmatX));
    DmatY(unique([rowsNAN ; rowsINF ; missTrials]),:)=[];
    DmatX(unique([rowsNAN ; rowsINF ; missTrials]),:)=[];
    outcomes.matrix(7,unique([rowsNAN ; rowsINF ; missTrials])) = 0; %indexing non-touch and miss trials
    
    %standardization
    DmatX = (DmatX-mean(DmatX))./std(DmatX);
    %% Model running
    mdl.fitCoeffsFields = fieldsList;
    mdl.io.X = DmatX;
    mdl.io.Y = DmatY; 
    mdl.it = it;
    mdl.dt = dt; 
    mdl.outcomes = outcomes; 
    
    if numel(unique(DmatY))==2 % BINOMIAL GLM MODEL 
        mdl = binomialModel(mdl,DmatX,DmatY,glmnetOpt);
        mdl.logDist = 'binomial';
        groupMdl{d} = mdl;
        
    else % MULTINOMIAL GLM MODEL 
        mdl = multinomialModel(mdl,DmatX,DmatY,glmnetOpt);
        mdl.logDist = 'multinomial';
        groupMdl{d} = mdl;

    end
    
    save(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName],'groupMdl')
end


