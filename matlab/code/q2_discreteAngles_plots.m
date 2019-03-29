mdlName = 'mdlDiscrete';
load(['Y:\Whiskernas\JK\Data analysis\Jon\' mdlName])

%% confusion matrix of prediction accuracies

for g = 1:length(groupMdl)
    cmatNorm = groupMdl{g}.gof.confusionMatrix ./ sum( groupMdl{g}.gof.confusionMatrix);
    figure(5480);subplot(2,3,g)
    imagesc(cmatNorm);
    axis square 
    caxis([0 max(max(cmatNorm))])
    colorbar
    title(['% correct = ' num2str(mean(groupMdl{g}.gof.modelAccuracy)*100)])
    set(gca,'xtick',[1 4 7],'xticklabel',{'45','90','135'})
    set(gca,'ytick',[1 4 7],'yticklabel',{'45','90','135'})
    ylabel('true');xlabel('predicted')
end

%% plot distribution of angle presentations
mouseNum =5; 
DmatY = groupMdl{mouseNum}.io.Y;

figure(9);clf
[C,~,ic] = unique(DmatY);
a_counts = accumarray(ic,1);
bar(1:length(a_counts),a_counts./sum(a_counts))
set(gca,'xticklabel',num2str(C))
xlabel('servoAngle');ylabel('proportion of trials')

[~,idx] = sort(DmatY);

%% plot distribution of features sorted by angles
% plot params specification

mouseNum =5; 
featNum = [13 11 12];


DmatY = groupMdl{mouseNum}.io.Y;
DmatX = groupMdl{mouseNum}.io.X; 

[~,ia,ic] = unique(DmatY);
a_counts = accumarray(ic,1);
starts = [1 ; cumsum(a_counts(1:end-1))+1];
ends = cumsum(a_counts);
colors = jet(numel(ia));

figure(580);clf
for k = 1:length(featNum)
    subplot(1,3,k)
    for d = 1:length(ia)
        hold on; scatter(starts(d):ends(d),DmatX(ic==d,featNum(k)),'markeredgecolor',colors(d,:))
    end
    set(gca,'xtick',[])
    title(groupMdl{1}.fitCoeffsFields{featNum(k)})
end
legend(num2str((45:15:135)'))



figure(532);clf
for d = 1:length(ia)
% hold on; scatter3(DmatX(ic==d,featNum(1)),DmatX(ic==d,featNum(2)),DmatX(ic==d,featNum(3)))
hold on; scatter3(mean(DmatX(ic==d,featNum(1))),mean(DmatX(ic==d,featNum(2))),mean(DmatX(ic==d,featNum(3))),200,'filled','markerfacecolor',colors(d,:))
end
xlabel(groupMdl{1}.fitCoeffsFields{featNum(1)})
ylabel(groupMdl{1}.fitCoeffsFields{featNum(2)})
zlabel(groupMdl{1}.fitCoeffsFields{featNum(3)})

%% plot correlation between selected features
corrFeats = [13 11 12];

for g = 1:6
mouseNum = g; 
it = groupMdl{mouseNum}.it;
dt = groupMdl{mouseNum}.dt; 
    [DmatXIT, DmatXDT, fieldsList] = designMatrixBuilder(it,dt);

    DmatX = [DmatXIT DmatXDT];
    %removing nan values
    [rowsNAN, ~] = find(isnan(DmatX));
    [rowsINF, ~] = find(isinf(DmatX));
%     DmatY(unique([rowsNAN ; rowsINF]),:)=[];
    DmatX(unique([rowsNAN ; rowsINF]),:)=[];

    cf{g} = corr(DmatX(:,corrFeats));
end