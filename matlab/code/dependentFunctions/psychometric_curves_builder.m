function psychogof = psychometric_curves_builder(mdlName)

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

figure(123);clf
for i = 1:length(groupMdl)
    TT = logical(groupMdl{i}.outcomes.matrix(7,:));
    angles = groupMdl{i}.outcomes.matrix(6,TT);
    pRlick = groupMdl{i}.outcomes.matrix(3,TT);
    testAngles = groupMdl{i}.io.XYYhat(:,1);
    testpRlick = groupMdl{i}.io.XYYhat(:,3);
    trueRlick = groupMdl{i}.io.XYYhat(:,2);
    
    tCorrect = groupMdl{i}.outcomes.matrix(5,TT);
    tCorrect(tCorrect==-1) = nan;
    
    [uVals,~,idx] = unique(angles);
    [~,~,idxtest] = unique(testAngles);
    for b = 1:length(uVals)
        rawPsycho(b,:) = [mean(pRlick(idx==b)) std(pRlick(idx==b))./ sqrt(sum(idx==b))]; % SEM
        %         rawPsycho(b,:) = [mean(pRlick(idx==b)) std(pRlick(idx==b))]; %STD
        predPsycho(b,:) = [mean(testpRlick(idxtest==b)) std(testpRlick(idxtest==b))./ sqrt(sum((idxtest==b)))]; %SEM
        %         predPsycho(b,:) = [mean(testpRlick(idxtest==b)) std(testpRlick(idxtest==b))]; %STD
    end
    
    psychogof.correlation(i) = corr(rawPsycho(:,1),predPsycho(:,1));
    %     rawToPredRMSE = sqrt(sum((predPsycho(:,1) - rawPsycho(:,1)).^2) ./ length(uVals)); %RMSE of average model and true
    psychogof.RMSE(i) = sqrt(sum((trueRlick- testpRlick).^2) ./ length(trueRlick)); %RMSE of each individual prediction
    psychogof.MAE(i) = sum(abs((trueRlick- testpRlick))) ./ length(trueRlick); %Mean Absolute Error (MAE)
    
    figure(123)
    subplot(2,3,i)
    shadedErrorBar(uVals,predPsycho(:,1),predPsycho(:,2),'lineprops','k')
    hold on;shadedErrorBar(uVals,rawPsycho(:,1),rawPsycho(:,2),'lineprops','r')
    set(gca,'ytick',[0:.25:1],'ylim',[0 1],'xtick',[45 90 135])
    title(['model to raw RMSE = ' num2str(psychogof.RMSE(i))])
end
suptitle(['population prediction of choice using ' num2str(numel(groupMdl{i}.fitCoeffsFields)) ' features'])
