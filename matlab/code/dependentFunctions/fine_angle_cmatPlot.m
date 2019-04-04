function fine_angle_cmatPlot(mdlName)
% confusion matrix of prediction accuracies

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

cmatBlank = zeros(size(groupMdl{1}.gof.confusionMatrix));
figure;
for g = 1:length(groupMdl)
    cmatNorm = groupMdl{g}.gof.confusionMatrix ./ sum( groupMdl{g}.gof.confusionMatrix);
    cmatBlank = cmatBlank + cmatNorm; 
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

figure;
colormap(jet)
imagesc(cmatBlank./length(groupMdl))
axis square
    set(gca,'xtick',[1 4 7],'xticklabel',{'45','90','135'})
    set(gca,'ytick',[1 4 7],'yticklabel',{'45','90','135'})
title('population prediction') 
caxis([0 max(max(cmatBlank./length(groupMdl)))])
colorbar
