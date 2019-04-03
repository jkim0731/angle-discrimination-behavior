function [DmatXIT, DmatXDT, fieldsList] = designMatrixBuilder(it,dt)

%Design matrix AT TOUCH
featTitles = fields(it);
DmatXIT = nan(size(it.touchTheta,2),length(featTitles));
for b = 1:length(featTitles)
    DmatXIT(:,b) = nanmean(it.(featTitles{b}),1);
end

% Design matrix DURING TOUCH
%DmatX builder
dtpdMask = dt.mask.pdTouches;
allF = fields(dt.features);
DmatXDT = nan(size(dt.features.(allF{1}),2),length(allF));
for b = 1:length(allF)
    currFeat = dt.features.(allF{b});
    pdfeat = cellfun(@(x,y) nanmean(x(y)),currFeat,dtpdMask);
    
    allFeats = sort(pdfeat);
    allFeats = allFeats(~isnan(allFeats));
    lowerB = allFeats(round(length(allFeats).*.005));
    upperB = allFeats(round(length(allFeats).*.995));
      
    pdfeat(pdfeat>upperB) = upperB;
    pdfeat(pdfeat<lowerB) = lowerB;

    DmatXDT(:,b) = pdfeat;
end

fieldsList = [featTitles;allF];