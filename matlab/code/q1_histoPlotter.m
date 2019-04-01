
mdlName = 'mdlNaive';
load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])
%%

clearvars -except groupMdl
yOut = 'choice';
standardization = 'yes';

for i = 1:6
    
    it = groupMdl{i}.it;
    outcomes = groupMdl{i}.outcomes;
    featTitles = fields(it);
    figure(4400);clf
    
    if strcmp(yOut,'ttype')
        class1 = find(outcomes.matrix(1,:)==1);
        class2 = find(outcomes.matrix(2,:)==1);
        colors = {'b','r'};
    elseif strcmp(yOut,'choice')
        class1 = find(outcomes.matrix(3,:)==1);
        class2 = find(outcomes.matrix(4,:)==1);
        colors = {'c','m'};
    end
    
    
    numBins = 15;
    for k = 1:length(featTitles)
        subplot(4,2,k)
        
        %bounds based on individual mouse
        %         allFeats = it.(featTitles{k})(:);
        %         allFeats = sort(allFeats(~isnan(allFeats)));
        %         lowerB = allFeats(round(length(allFeats).*.02));
        %         upperB = allFeats(round(length(allFeats).*.98));
        %         indivBounds = [linspace(lowerB,upperB,numBins)];
        
        %bounds based on population
        featsRaw = cellfun(@(y) nanmean(y.it.(featTitles{k}),1),groupMdl,'uniformoutput',false);
        if strcmp(standardization,'yes')
            featsRaw = cellfun(@(x) (x-nanmean(x))./nanstd(x),featsRaw,'uniformoutput',false); %STANDARDIZED
        end
        
        boundFeats = cell2mat(featsRaw') ;
        feats = sort(boundFeats(~isnan(boundFeats)));
        lowerB = feats(round(length(feats).*.02));
        upperB = feats(round(length(feats).*.98));
        popBounds = [linspace(lowerB,upperB,numBins)];
        
        bounds = popBounds;
        
        feat1  = featsRaw{i}(class1);
        feat1 = feat1(~isnan(feat1));
        feat2 = featsRaw{i}(class2);
        feat2 = feat2(~isnan(feat2));
        ih1TMP = histogram(feat1(:),bounds,'FaceColor',colors{1},'normalization','probability','facealpha',.7);
        hold on; ih2TMP =histogram(feat2(:),bounds,'FaceColor',colors{2},'normalization','probability','facealpha',.7);
        title(featTitles{k});
        
        itHistoY{k}(i,:) = [ih1TMP.Values  ih2TMP.Values];

        itHistoX{k} = linspace(mean(popBounds(1:2)),popBounds(end) - (popBounds(2)-popBounds(1)),numBins-1);
        
    end
    
    
    suptitle(['INSTANT - mouse:' outcomes.mouseNumber ' session:' outcomes.sessionNumber])
    
    %%
    dt = groupMdl{i}.dt;
    dtmask = dt.mask.pdTouches;
    
    allF = fields(dt.features);
    numBins = 15;
    figure(234);clf
    %HISTOGRAM PLOT OF MEAN TOUCHES
    for b = 1:length(allF)
        
        subplot(3,5,b)
        currFeat = dt.features.(allF{b});

        
        %bounds based on individual mouse
        %         allFeats = sort(pdfeat);
        %         allFeats = allFeats(~isnan(allFeats));
        %         lowerB = allFeats(round(length(allFeats).*.05));
        %         upperB = allFeats(round(length(allFeats).*.95));
        %         indivBounds = [linspace(lowerB,upperB,numBins)];
        
        %bounds based on population
        featsRaw= cellfun(@(y) cellfun(@(x) nanmean(x),y.dt.features.(allF{b})) , groupMdl,'uniformoutput',false);
        
        for u = 1:length(featsRaw)
            featsRaw{u}(isinf(featsRaw{u}))=nan;
        end
        
        if strcmp(standardization,'yes')
            featsRaw = cellfun(@(x) (x-nanmean(x))./nanstd(x),featsRaw,'uniformoutput',false); %STANDARDIZED
        end
        
           
        boundFeats = cell2mat(featsRaw') ;
        feats = sort(boundFeats(~isnan(boundFeats)));
        lowerB = feats(round(length(feats).*.02));
        upperB = feats(round(length(feats).*.98));
        popBounds = [linspace(lowerB,upperB,numBins)];
        
        
        bounds = popBounds;
        
        feat1 = [featsRaw{i}(class1)];
        feat2 = [featsRaw{i}(class2)];
        
        dh1TMP = histogram(feat1,bounds,'FaceColor',colors{1},'normalization','probability','facealpha',.7);
        hold on; dh2TMP = histogram(feat2,bounds,'FaceColor',colors{2},'normalization','probability','facealpha',.7);
        set(gca,'xlim',[popBounds(1) popBounds(end)])
        title(allF{b});
        
        dtHistoY{b}(i,:) = [dh1TMP.Values  dh2TMP.Values];
        dtHistoX{b} = linspace(mean(popBounds(1:2)),popBounds(end) - (popBounds(2)-popBounds(1)),numBins-1);
    end
    
    
    suptitle(['DURING - mouse:' outcomes.mouseNumber ' session:' outcomes.sessionNumber])
end

%% POPULATION HISTOGRAM

dtFields = fields(groupMdl{1}.dt.features);
figure(45800);clf
for k = 1:length(dtHistoY)
    
    currFeat = mean(dtHistoY{k});
    f1 = currFeat(1:size(dtHistoY{k},2)/2);
    f2 = currFeat(size(dtHistoY{k},2)/2+1:end);
    
    subplot(3,5,k)
    bar(dtHistoX{k},f1,colors{1},'facealpha',.7)
    hold on; bar(dtHistoX{k},f2,colors{2},'r','facealpha',.7);
    title(dtFields{k})
end
suptitle(['DURING TOUCH : POPULATION'])



itFields = fields(groupMdl{1}.it);
figure(45300);clf
for k = 1:length(itHistoY)
    
    currFeat = mean(itHistoY{k});
    f1 = currFeat(1:size(itHistoY{k},2)/2);
    f2 = currFeat(size(itHistoY{k},2)/2+1:end);
    
    subplot(4,2,k)
    bar(itHistoX{k},f1,colors{1},'facealpha',.7)
    hold on; bar(itHistoX{k},f2,colors{2},'r','facealpha',.7);
    title(itFields{k})
end
suptitle(['INSTANT TOUCH : POPULATION'])







