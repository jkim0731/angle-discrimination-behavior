function population_histogram(mdlName,yOut,numBins)
load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName]);
standardization = 'yes';

for i = 1:6
    
    it = groupMdl{i}.it;
    outcomes = groupMdl{i}.outcomes;
    featTitles = fields(it);

    if strcmp(yOut,'ttype')
        class1 = find(outcomes.matrix(1,:)==1);
        class2 = find(outcomes.matrix(2,:)==1);
        colors = {'b','r'};
    elseif strcmp(yOut,'choice')
        class1 = find(outcomes.matrix(3,:)==1);
        class2 = find(outcomes.matrix(4,:)==1);
        colors = {'c','m'};
    end
    
 
    for k = 1:length(featTitles)
        
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
        
        itHistoY{k}(i,:) = [histcounts(feat1(:),bounds, 'Normalization', 'probability') histcounts(feat2(:),bounds, 'Normalization', 'probability')];
        itHistoX{k} = linspace(mean(popBounds(1:2)),popBounds(end) - (popBounds(2)-popBounds(1)),numBins-1);
 
    end
    
    dt = groupMdl{i}.dt;
    dtmask = dt.mask.pdTouches;
    
    allF = fields(dt.features);
    

    %HISTOGRAM PLOT OF MEAN TOUCHES
    for b = 1:length(allF)
        currFeat = dt.features.(allF{b});

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
        
        dtHistoY{b}(i,:) = [histcounts(feat1(:),bounds, 'Normalization', 'probability') histcounts(feat2(:),bounds, 'Normalization', 'probability')];
        dtHistoX{b} = linspace(mean(popBounds(1:2)),popBounds(end) - (popBounds(2)-popBounds(1)),numBins-1);

    end
    
end

%% POPULATION HISTOGRAM

dtFields = fields(groupMdl{1}.dt.features);
figure(45800);clf
itFields = fields(groupMdl{1}.it);

for k = 1:length(itHistoY)
    
    currFeat = mean(itHistoY{k});
    f1 = currFeat(1:size(itHistoY{k},2)/2);
    f2 = currFeat(size(itHistoY{k},2)/2+1:end);
    
    subplot(3,7,k)
    bar(itHistoX{k},f1,colors{1},'facealpha',.7)
    hold on; bar(itHistoX{k},f2,colors{2},'r','facealpha',.7);
    title(itFields{k})
end

for k = 1:length(dtHistoY)
    
    currFeat = mean(dtHistoY{k});
    f1 = currFeat(1:size(dtHistoY{k},2)/2);
    f2 = currFeat(size(dtHistoY{k},2)/2+1:end);
    
    subplot(3,7,k+7)
    bar(dtHistoX{k},f1,colors{1},'facealpha',.7)
    hold on; bar(dtHistoX{k},f2,colors{2},'r','facealpha',.7);
    title(dtFields{k})
end
suptitle(['POPULATION FEATURE HISTOGRAM'])







