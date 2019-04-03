function fine_angle_cmatPlot(mdlName)
% confusion matrix of prediction accuracies

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

figure;
for g = 1:length(groupMdl)
    cmatNorm = groupMdl{g}.gof.confusionMatrix ./ sum( groupMdl{g}.gof.confusionMatrix);
    subplot(2,3,g)
    imagesc(cmatNorm);
    axis square
    caxis([0 max(max(cmatNorm))])
    colorbar
    title(['% correct = ' num2str(mean(groupMdl{g}.gof.modelAccuracy)*100)])
    set(gca,'xtick',[1 4 7],'xticklabel',{'45','90','135'})
    set(gca,'ytick',[1 4 7],'yticklabel',{'45','90','135'})
    ylabel('true');xlabel('predicted')
end