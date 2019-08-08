function mdl = multinomialModel(mdl,DmatX,DmatY,glmnetOpt)   

    mdl.fitCoeffs = cell(1,glmnetOpt.numIterations);
    mdl.gof.confusionMatrix = zeros(numel(unique(DmatY)));
    trainIdx = cell(glmnetOpt.numIterations,1);
    testIdx = cell(glmnetOpt.numIterations,1);
    for h = 1:glmnetOpt.numIterations
        display(['running multinomial model iteration ' num2str(h) '/' num2str(glmnetOpt.numIterations)])
        
        %% stratified distribution of classes for test and train sets
        diffClasses = unique(DmatY);
        
        trainIdx{h} = [];
        testIdx{h} = [];
        for i = 1:length(diffClasses)
            classIdx = find(DmatY == diffClasses(i));
            shuffCI = classIdx(randperm(length(classIdx)));
            seventy = 1:round(numel(classIdx)*.7);
            thirty  = round(numel(classIdx)*.7)+1:length(classIdx);
            
            trainIdx{h} = [trainIdx{h} ; shuffCI(seventy)];
            testIdx{h} = [testIdx{h}; shuffCI(thirty)];
        end
        
        trainDmatX = DmatX(trainIdx{h},:);
        trainDmatY = DmatY(trainIdx{h},:);
        testDmatX = DmatX(testIdx{h},:);
        testDmatY = DmatY(testIdx{h},:);
        
      
        
        %% GLM model fitting
        %xFold CV to find optimal lambda for regularization
        cv = cvglmnet(trainDmatX, trainDmatY, 'multinomial', glmnetOpt, [], glmnetOpt.xfoldCV);
        fitLambda = cv.lambda_1se;
        iLambda = find(cv.lambda == cv.lambda_1se);
        mdl.fitCoeffs{h} = [cv.glmnet_fit.a0(:,iLambda)' ; cell2mat(cellfun(@(x) x(:,iLambda),cv.glmnet_fit.beta,'uniformoutput',false))];
        
        %Test set
        predicts = cvglmnetPredict(cv,testDmatX,fitLambda); %output as X*weights
        probability =  1 ./ (1+exp(predicts*-1)); %convert to probability by using mean function (for binomial, it is the sigmoid f(x) 1/1+exp(-predicts))
        
        %hard set of probability >.5 = predict class 1
        [~,pred] = max(probability,[],2);
        [~,~,true] = unique(testDmatY);
        
        %goodness of fit metrics
        %calculation of MCC (see wiki for full equation) + model accuracy 
        cmat = confusionmat(true,pred);
        mdl.gof.confusionMatrix = mdl.gof.confusionMatrix + cmat;
        mdl.gof.modelAccuracy(h) = mean(true == (pred));

    end
    mdl.trainIdx = trainIdx;
    mdl.testIdx = testIdx;