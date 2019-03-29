function featurePlotter(it,dt,outcomes,yOut)
%This function plots the mean of trial features AT touch and DURING touch. 

%% INSTANT FEATURES PLOT
% poleAngles = cellfun(@(x) x.poleAngle,wfa.trials);
% [~,sortIdx ] = sort(poleAngles);
% 
% 
% 
% mid = find(diff(sort(poleAngles))>0); %find first trial from 45-135
% %SCATTER
% figure(4390);clf
% for k = 1:length(featTocheck)
%     subplot(3,2,k)
%     for b = 1:length(sortIdx)
%         idxToPlot = sortIdx(b);
%         feat = featTocheck{k}(~isnan(featTocheck{k}(:,idxToPlot)),idxToPlot);
%         if b>=mid
%             hold on; scatter(ones(length(feat),1).*b,feat,'r.')
%         else
%             hold on; scatter(ones(length(feat),1).*b,feat,'b.')
%         end
%     end
%
%     title(featTitles{k});
%     hold on; plot([mid mid],[min(featTocheck{k}(:)) max(featTocheck{k}(:))],'-.k')
%     set(gca,'xlim',[0 length(sortIdx)],'xtick',[])
% end
% suptitle(['mouse:' mouseNumber ' session:' sessionNumber])


%HISTOGRAM
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
    allFeats = it.(featTitles{k})(:);
    allFeats = sort(allFeats(~isnan(allFeats)));
    lowerB = allFeats(round(length(allFeats).*.02));
    upperB = allFeats(round(length(allFeats).*.98));
    
    bounds = [linspace(lowerB,upperB,numBins)];
    feat1  = nanmean(it.(featTitles{k})(:,class1),1);
    feat1 = feat1(~isnan(feat1));
    feat2 = nanmean(it.(featTitles{k})(:,class2),1);
    feat2 = feat2(~isnan(feat2));
    histogram(feat1(:),bounds,'FaceColor',colors{1},'normalization','probability','facealpha',.7)
    hold on; histogram(feat2(:),bounds,'FaceColor',colors{2},'normalization','probability','facealpha',.7);
    title(featTitles{k});
end
suptitle(['INSTANT - mouse:' outcomes.mouseNumber ' session:' outcomes.sessionNumber])

%% DURING TOUCH FEATURES PLOT

dtmask = dt.mask.pdTouches; 

allF = fields(dt.features);
numBins = 15;

%HISTOGRAM PLOT OF ALL TOUCHES
% figure(123);clf
% check =[];
% for b = 1:length(allF)
%     
%     subplot(4,4,b)
%     currFeat = dt.(allF{b});
% 
% %     check(:,b) = cellfun(@numel,currFeat)'
%     
%     pdfeat = cellfun(@(x,y) x(y), currFeat,dtmask,'uniformoutput',false);
%     
%     allFeats = sort(cell2mat(pdfeat));
%     allFeats = allFeats(~isnan(allFeats));
%     lowerB = allFeats(round(length(allFeats).*.05));
%     upperB = allFeats(round(length(allFeats).*.95));
%     bounds = [linspace(lowerB,upperB,numBins)];
%     
%     feat1 = [pdfeat{class1}];
%     feat2 = [pdfeat{class2}];
%     
%     histogram(feat1,bounds,'FaceColor',colors{1},'normalization','probability','facealpha',.7)
%     hold on; histogram(feat2,bounds,'FaceColor',colors{2},'normalization','probability','facealpha',.7);
%     
%     title(allF{b});
% end
% suptitle('ALL TOUCHES')

figure(234);clf
%HISTOGRAM PLOT OF MEAN TOUCHES
for b = 1:length(allF)
    
    subplot(3,5,b)
    currFeat = dt.features.(allF{b});
    
    pdfeat = cellfun(@(x,y) nanmean(x(y)),currFeat,dtmask);
    
    allFeats = sort(pdfeat);
    allFeats = allFeats(~isnan(allFeats));
    lowerB = allFeats(round(length(allFeats).*.05));
    upperB = allFeats(round(length(allFeats).*.95));
    bounds = [linspace(lowerB,upperB,numBins)];
    
    feat1 = [pdfeat(class1)];
    feat2 = [pdfeat(class2)];
    
    histogram(feat1,bounds,'FaceColor',colors{1},'normalization','probability','facealpha',.7)
    hold on; histogram(feat2,bounds,'FaceColor',colors{2},'normalization','probability','facealpha',.7);
    
    title(allF{b});
end
suptitle(['DURING - mouse:' outcomes.mouseNumber ' session:' outcomes.sessionNumber])