function topFeats = heaviestCoefficients_fineAngle(mdlName)

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

blankSlate = zeros(size(groupMdl{1}.fitCoeffs{1}));

for g = 1:length(groupMdl)
    
    for b = 1:length(groupMdl{g}.fitCoeffs)
        blankSlate = blankSlate + groupMdl{g}.fitCoeffs{b};
    end
    
    [~,idx] = sort(abs(blankSlate(2:end,:)./length(groupMdl{g}.fitCoeffs)));
    
    rankWeights(:,g) = abs(mean(blankSlate(2:end,:),2)) ./ sum(abs(mean(blankSlate(2:end,:),2)) ); 
    
    for k = 1:length(unique(idx))
        [rs,~] = find(idx==k);
        rankScores(g,k) = sum(rs);
    end
    
end

[wt,idx] = sort(mean(rankWeights,2)); %ranking of features based on the mean of all features 
err = std(rankWeights,[],2)./sqrt(size(rankWeights,2)); 
topFeats = flipud(groupMdl{1}.fitCoeffsFields(idx));

figure(480)
barwitherr(err(idx),wt,'facecolor',[.7 .7 .7]);
set(gca,'xtick',[])
 ylabel('abs coeffs weight');
 xlabel('sorted features');
 title('population feature weight')
 set(gca,'ylim',[0 .6])


% [~,bfs] = sort(sum(rankScores)); %ranking of features based on a system
% of points based on feature importance in predicting each angle type

topFeats = flipud(groupMdl{1}.fitCoeffsFields(idx))

%% 3D scatter of heaviest coefficients 
figure;
featNum = idx(end-2:end);
mouseNum =5;
DmatY = groupMdl{mouseNum}.io.Y;
DmatX = groupMdl{mouseNum}.io.X;
[~,ia,ic] = unique(DmatY);
colors = jet(numel(ia));

for d = 1:length(ia)
    hold on; scatter3(DmatX(ic==d,featNum(1)),DmatX(ic==d,featNum(2)),DmatX(ic==d,featNum(3)),'markeredgecolor',colors(d,:))
    hold on; scatter3(mean(DmatX(ic==d,featNum(1))),mean(DmatX(ic==d,featNum(2))),mean(DmatX(ic==d,featNum(3))),200,'filled','markerfacecolor',colors(d,:))
end
xlabel(groupMdl{1}.fitCoeffsFields{featNum(1)})
ylabel(groupMdl{1}.fitCoeffsFields{featNum(2)})
zlabel(groupMdl{1}.fitCoeffsFields{featNum(3)})
title(['3d scatter of three best features for mouse num ' num2str(mouseNum)])

