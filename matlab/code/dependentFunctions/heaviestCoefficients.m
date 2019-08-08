function topFeats = heaviestCoefficients(mdlName)

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

populationWt = nan(numel(groupMdl{1}.fitCoeffsFields),length(groupMdl));

for b = 1:length(groupMdl)
tmpWt = abs(mean(groupMdl{b}.fitCoeffs(2:end,:),2));
populationWt(:,b) = tmpWt./sum(tmpWt);
end

[wt,idx] = sort(nanmean(populationWt,2));
err = std(populationWt,[],2)./sqrt(size(populationWt,2)); 
topFeats = flipud(groupMdl{1}.fitCoeffsFields(idx));

figure;
barwitherr(err(idx),wt,'facecolor',[.7 .7 .7]);
set(gca,'xtick',[])
 ylabel('abs coeffs weight');
 xlabel('sorted features');
 title('population feature weight')
 set(gca,'ylim',[0 .6])