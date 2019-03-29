%% MCC PLOTTING 
% mdlName = {'mdlExpertKappaV','mdlExpertDKappaH','mdlExpertDPhi','mdlExpertDKappaV','mdlExpertTopTwo','mdlExpertTopThree','mdlExpertTopFour','mdlExpert'};
mdlName = {'mdlExpertTTypeRadialD','mdlExpertTTypeTouchTheta','mdlExpertTTypeDKappaV','mdlExpertTTypeDPhi','mdlExpertTTypeTopTwo','mdlExpertTTypeTopThree','mdlExpertTTypeTopFour','mdlExpertTType'};
% mdlName = {'mdlNaiveTType','mdlExpertTType'}
mcc = nan(length(mdlName),6); 
numVars = nan(1,length(mdlName)); 
for p = 1:length(mdlName)
    load(['Y:\Whiskernas\JK\Data analysis\Jon\' mdlName{p}])
    numVars(p) = size(groupMdl{1}.io.X,2);
    for k = 1:length(groupMdl)
        mcc(p,k) = nanmean(groupMdl{k}.gof.mcc);
    end
    
end

figure(390);clf
plot(mcc,'ko-')
hold on; plot([.5 length(mdlName)+.5],[0 0],'-.k')
% set(gca,'xlim',[.5 length(mdlName)+.5],'ylim',[-.2 1],'xtick',[1:length(mdlName)],'xticklabel',mdlName,'ytick',0:.25:1)
set(gca,'xlim',[.5 length(mdlName)+.5],'ylim',[-.2 1],'xtick',[1:length(mdlName)],'xticklabel',{'4','3','2','1','2+1','3+2+1','4+3+2+1','full'},'ytick',0:.25:1)
ylabel('mcc')
title('2 angle ttype prediction') 

%% Feature plotting

mdlName = 'mdlNaiveTType';
load(['Y:\Whiskernas\JK\Data analysis\Jon\' mdlName])

for b = 1:length(groupMdl)
[wt,idx] = sort(abs(mean(groupMdl{b}.fitCoeffs(2:end,:),2)));


tmpWt = abs(mean(groupMdl{b}.fitCoeffs(2:end,:),2));
finalWt(:,b) = tmpWt./sum(tmpWt);

% selIdx(b) = find(cumsum(flipud(wt./sum(wt)))>.9,1,'first');
% 
% propWt(:,b) = wt./sum(wt);
% propIdx(:,b) = idx;
end

[wt,idx] = sort(mean(finalWt,2));
err = std(finalWt,[],2)./sqrt(size(finalWt,2)); 

threshValue = .9;
threshIdx = find(cumsum(flipud(wt))>.9,1,'first');
selFeatures = idx(end-threshIdx:end);
topFeats = flipud(groupMdl{1}.fitCoeffsFields(selFeatures))

% figure(439);clf
% imagesc(corr(DmatX(:,selFeatures)))
% set(gca,'xtick',[],'ytick',[])
% ylabel('worst -> best feat')
% xlabel('worst -> best feat')
% axis square
% title('corr between selected features') 

figure(480);clf
barwitherr(err(idx),wt,'facecolor',[.7 .7 .7]);
set(gca,'xtick',[])
 ylabel('abs coeffs weight');
 xlabel('sorted features');
 title('population feature weight')
 set(gca,'ylim',[0 .6])
 
 
 
 