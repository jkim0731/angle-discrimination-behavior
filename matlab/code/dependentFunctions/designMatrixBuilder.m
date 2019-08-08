function [DmatXDT, DmatXIT, tnums, fieldsList] = designMatrixBuilder(it,dt,Xhow)

if strcmpi(Xhow,'mean')
    %% Design matrix for mean of all touches
    %Design matrix AT TOUCH
    featTitles = fields(it);
    DmatXIT = nan(size(it.touchTheta,2),length(featTitles));
    for b = 1:length(featTitles)
        DmatXIT(:,b) = nanmean(it.(featTitles{b}),1);
    end
    
    % Design matrix DURING TOUCH
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
    
    fieldsList = [allF;featTitles];
    tnums = 1:length(DmatXIT);
    
elseif strcmpi(Xhow,'individual')
    %% Design matrix for individual touches
    %Design matrix AT TOUCH\
    featTitles = fields(it);
    DmatXIT = [];
%     idx2Keep =  find(~isnan(it.touchTheta .* it.touchKappaH .* it.touchKappaV .* it.touchKappaVH .* it.touchPhi));
    idx2Keep =  find(~isnan(it.touchTheta .* it.touchKappaH .* it.touchKappaV .* it.touchPhi));
    tnumsIT = ceil(idx2Keep ./ 5000);
    for b = 1:length(featTitles)
        if b == 6
            DmatXIT(:,b) = nan(length(tnumsIT),1);
        elseif b ==5 %Index up because of radial distance at touch 
            DmatXIT(:,b) = it.(featTitles{b})(idx2Keep+1);
        else
            DmatXIT(:,b) = it.(featTitles{b})(idx2Keep);
        end
    end
    
    % Design matrix DURING TOUCH
    dtpdMask = dt.mask.pdTouches;
    allF = fields(dt.features);
    DmatXDT = [];
    tnumsDT = []; 
    for b = 1:length(allF)
        currFeat = dt.features.(allF{b});
        pdfeat = cellfun(@(x,y) x(y),currFeat,dtpdMask,'uniformoutput',false);
        
        tnumsDTTMP = [];
        numTouches = cellfun(@numel, pdfeat);
        for k = 1:length(pdfeat)
            tnumsDTTMP = [tnumsDTTMP; repmat(k,numTouches(k),1)];
        end
        tnumsDT(:,b) = tnumsDTTMP;
        
        pdfeat = cell2mat(pdfeat);
        allFeats = sort(pdfeat);
        allFeats = allFeats(~isnan(allFeats));
        lowerB = allFeats(round(length(allFeats).*.005));
        upperB = allFeats(round(length(allFeats).*.995));
        
        pdfeat(pdfeat>upperB) = upperB;
        pdfeat(pdfeat<lowerB) = lowerB;
        
        DmatXDT(:,b) = pdfeat;
    end
    
    % first, find tnums that are both in DT and IT (sometimes it is 1 vs 0)
    tempuDT = unique(tnumsDT(:,1));
    tempuIT = unique(tnumsIT);
    uT = intersect(tempuDT, tempuIT);
    tempTossDT = find(1-ismember(tnumsDT(:,1), uT));
    tempTossIT = find(1-ismember(tnumsIT, uT));
    tnumsDT(tempTossDT,:) = [];
    tnumsIT(tempTossIT) = [];
    DmatXDT(tempTossDT,:) = [];
    DmatXIT(tempTossIT,:) = [];
    
    [uDT,~,c] = unique(tnumsDT(:,1));
    tmpDT = accumarray(c,1);
    [uIT,~,c] = unique(tnumsIT);
    tmpIT = accumarray(c,1);
    trialsToToss = uIT(find(~((tmpIT-tmpDT)==0)));
    
    
    %removing trials with unequal number of touches between IT and DT
    [tossIT ] = ismember(tnumsIT,trialsToToss);
    [tossDT ] = ismember(tnumsDT(:,1),trialsToToss);

    DmatXIT(tossIT,:) = [];
    DmatXDT(tossDT,:) = [];
    
    tnumsDT(tossDT,:) = [];
    tnumsIT(tossIT,:) = [];
    check = find(sum([tnumsIT tnumsDT] - mean([tnumsIT tnumsDT],2),2)>0);
    
    if ~isempty(check)
        error('misalignment between tnums of IT and DT')
    end
    
    fieldsList = [allF;featTitles];
    tnums = tnumsIT(:,1);
    
else
    error('Xhow must be defined as "mean" or "individual"');
end





