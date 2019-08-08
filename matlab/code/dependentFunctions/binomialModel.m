function mdl = binomialModel(mdl,DmatX,DmatY,glmnetOpt)   

    mdl.fitCoeffs = nan(size(DmatX,2)+1,glmnetOpt.numIterations);
    TTangles = mdl.outcomes.matrix(6,logical(mdl.outcomes.matrix(7,:)));
    mdl.io.XYYhat = [];
    trainIdx = cell(glmnetOpt.numIterations,1);
    testIdx = cell(glmnetOpt.numIterations,1);
    for h = 1:glmnetOpt.numIterations
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
        cv = cvglmnet(trainDmatX, trainDmatY, 'binomial', glmnetOpt, [], glmnetOpt.xfoldCV);
        fitLambda = cv.lambda_1se;
        iLambda = find(cv.lambda == cv.lambda_1se);
        mdl.fitCoeffs(:,h) = [cv.glmnet_fit.a0(iLambda);cv.glmnet_fit.beta(:,iLambda)];
        
        %Test set
        predicts = cvglmnetPredict(cv,testDmatX,fitLambda); %output as X*weights
        probability =  1 ./ (1+exp(predicts*-1)); %convert to probability by using mean function (for binomial, it is the sigmoid f(x) 1/1+exp(-predicts))
        
        %hard set of probability >.5 = predict class 1
        pred = probability>.5;
        true = testDmatY;
        
        %goodness of fit metrics
        %calculation of MCC (see wiki for full equation) + model accuracy 
        cmat = confusionmat(true,pred);
        TP = cmat(1); FP = cmat(3);
        TN = cmat(4); FN = cmat(2);
        mdl.gof.mcc(h) = (TP*TN - FP*FN) ./ (sqrt( (TP+FP) * (TP+FN) * (TN+FP) * (TN+FN)));
        if isnan(mdl.gof.mcc(h))
            mdl.gof.mcc(h) = 0;
        end
        mdl.gof.modelAccuracy(h) = mean(testDmatY == (pred));
        mdl.io.XYYhat = [mdl.io.XYYhat ; [TTangles(testIdx{h})' testDmatY probability]]; 
        
    end
    
    mdl.trainIdx = trainIdx;
    mdl.testIdx = testIdx;