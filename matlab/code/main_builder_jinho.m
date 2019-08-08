%% Define mouse, session numbers, and model building parameters
% clear


mns = [{'JK025'},{'JK027'},{'JK030'},{'JK036'},{'JK039'},{'JK052'}];
% mns = [{'JK025'},{'JK027'},{'JK030'},{'JK036'},{'JK037'},{'JK038'},{'JK039'},{'JK041'},{'JK052'},{'JK053'},{'JK054'},{'JK056'}];

snsGroup = {[5,2,4,2,2,5], ... % naive
    [18,7,20,16,21,20], ... % expert
    [4,3,3,1,1,3], ... % naive
    [19,10,21,17,23,21], ... % expert
    [22,14,22,18,24,26]}; % radial distance
% sns = [{'S05'},{'S02'},{'S04'},{'S02'},{'S02'},{'S05'}]; %naive
% % sns = [{'S18'},{'S07'},{'S20'},{'S16'},{'S21'},{'S20'}]; %expert
% % sns = [{'S04'},{'S03'},{'S03'},{'S01'},{'S01'},{'S03'}]; %naive discreteAngles
% % sns = [{'S19'},{'S10'},{'S21'},{'S17'},{'S23'},{'S21'}]; %expert discreteAngles
% % sns = [{'S22'},{'S14'},{'S22'},{'S18'},{'S24'},{'S26'}]; %radial distance
sessionGroupNames = {'TwoNaive', 'TwoExpert', 'DiscreteNaive', 'DiscreteExpert', 'RadialDistance'};
% mdlName = 'mdlTwoNaiveTouch_12features_lick';
whiskDir = 'protraction'; % 'protraction' or 'all' to choose which touches to use
touchOrder = 'all'; % 'first' or 'all' to choose which touches pre-decision
% decisionPoint = 'lick'; % 'answer' or 'lick', added 2019/07/29 JK, for using touches before the first lick (within
% the answer period) or the answer lick
% yOut = 'Ttype'; % can be 'ttype' (45 vs 135), 'discrete' (45:15:135) or 'choice' (lick right probability)
Xhow = 'Individual'; %can be 'mean' or 'individual' so each touch is counted 


if strcmpi(touchOrder,'first') || strcmpi(Xhow,'individual')
    DmatSelect = 1:11; %tossing touch counts since it is all ones
else
    DmatSelect = 1:12; %feats from 1:12
end

% DmatSelect = [8:13];

% GLM model parameters
glmnetOpt = glmnetSet;
glmnetOpt.standardize = 0; %set to 0 b/c already standardized
glmnetOpt.alpha = 0.95;
glmnetOpt.xfoldCV = 5;
glmnetOpt.numIterations = 10;

saveDir = 'C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\';

%%
for sgni = 1 : length(sessionGroupNames)
    for decisionLickPoint = 1 : 2 % answer lick or first lick
        if decisionLickPoint == 1
            decisionPoint = 'answer';
        else
            decisionPoint = 'lick';
        end
        for targetType = 1 : 2 % touch or choice
            if targetType == 1
                if sgni == 1 || sgni == 2 || sgni == 5
                    yOut = 'Ttype';
                else
                    yOut = 'Discrete';
                end
                yOutForName = 'Touch';
            else
                yOut = 'Choice';
                yOutForName = 'Choice';
            end
            mdlName = ['mdl', sessionGroupNames{sgni}, Xhow, yOutForName, '_12features_', decisionPoint];
            
            groupMdl = cell(length(mns),1); 
            for d = 1:length(mns)
            % for d = 5
                mouseNumber = mns{d};
                sessionNumber = sprintf('S%02d',snsGroup{sgni}(d));

                %% Load necessary files
                behaviorFolder = 'Y:\Whiskernas\JK\SoloData';
                cd([behaviorFolder filesep mouseNumber]);
                load(['behavior_' mouseNumber '.mat']);

                whiskerFolder = ['Y:\Whiskernas\JK\whisker\tracked' filesep mouseNumber sessionNumber];

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
                %during touch features
                 dt = duringTouchBuilder(behavioralStruct,wfa,whiskDir,touchOrder,decisionPoint);
                %instantaneous touch features
                 it = instantTouchBuilder(behavioralStruct,wfa,whiskDir,touchOrder,decisionPoint);

                %% Plotting of instantaneous and during touch features
                %can set 'yOut' to build feature distribution based on 'ttype' or 'choice'
            %     featurePlotter(it,dt,outcomes,yOut)

                %% Design matrix construction
                [DmatXDT, DmatXIT, tnums, fieldsList] = designMatrixBuilder(it,dt,Xhow);

                DmatX = [DmatXDT DmatXIT];

                DmatX = DmatX(:,DmatSelect);
                fieldsList = fieldsList(DmatSelect);

                % Dmat Y builder
                if strcmpi(Xhow,'mean')
                    if strcmpi(yOut,'ttype')
                        DmatY = (outcomes.matrix(1,:)==1)';
                    elseif strcmpi(yOut,'choice')
                        DmatY = (outcomes.matrix(3,:)==1)';
                    elseif strcmpi(yOut,'discrete')
                        DmatY = (outcomes.matrix(6,:))';
                    end
                    missY = outcomes.matrix(5,:) == -1;
                elseif strcmpi(Xhow,'individual')
                    if strcmpi(yOut,'ttype')
                        tmpY = (outcomes.matrix(1,:)==1)';
                    elseif strcmpi(yOut,'choice')
                        tmpY = (outcomes.matrix(3,:)==1)';
                    elseif strcmpi(yOut,'discrete')
                        tmpY = (outcomes.matrix(6,:))';
                    end
                    misstmp = outcomes.matrix(5,:) == -1;
                    missY = misstmp(tnums);
                    DmatY = tmpY(tnums); 
                else
                    error('need to define "Xhow" as "mean" or "individual"') 
                end


                %removing nan(non-touch) values and miss
                missTrials = find(missY == 1)';
                [rowsNAN, ~] = find(isnan(DmatX));
                [rowsINF, ~] = find(isinf(DmatX));
                DmatY(unique([rowsNAN ; rowsINF ; missTrials]),:)=[];
                DmatX(unique([rowsNAN ; rowsINF ; missTrials]),:)=[];

                if strcmpi(Xhow,'mean')
                outcomes.matrix(7,unique([rowsNAN ; rowsINF ; missTrials])) = 0; %indexing non-touch and miss trials
                end

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

            end

            info.mice = mns;
            info.sessions = snsGroup{sgni};
            info.whiskDir = whiskDir;
            info.touchOrder = touchOrder;
            info.decisionPoint = decisionPoint;
            info.yOut = yOut;
            info.Xhow = Xhow;

            save([saveDir mdlName],'groupMdl', 'info')
        end
    end
end

cd(saveDir)