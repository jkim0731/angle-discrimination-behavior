mdlName = 'mdlDiscreteReduced';
load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

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

%% plot distribution of features sorted by angles for individual mouse 
% plot params specification

mouseNum =5;
featNum = [1:21];


DmatY = groupMdl{mouseNum}.io.Y;
DmatX = groupMdl{mouseNum}.io.X;

[~,ia,ic] = unique(DmatY);
a_counts = accumarray(ic,1);
starts = [1 ; cumsum(a_counts(1:end-1))+1];
ends = cumsum(a_counts);
colors = jet(numel(ia));

figure(580);clf
for k = 1:length(featNum)
    subplot(3,7,k)
    for d = 1:length(ia)
        hold on; scatter(starts(d):ends(d),DmatX(ic==d,featNum(k)),'markeredgecolor',colors(d,:))
    end
    set(gca,'xtick',[])
    title(groupMdl{1}.fitCoeffsFields{featNum(k)})
end
legend(num2str((45:15:135)'))

%% feature distribution population
YVals  = unique(groupMdl{1}.io.Y);
numMice = length(groupMdl);
starts = 1:numMice:numMice*length(YVals);
ends = numMice:numMice:numMice*length(YVals);
colors = jet(length(YVals));

figure(348);clf
sortedYs = cell(1,length(YVals));
for g = 1:length(YVals)
    sortedYs{g} = cell2mat(cellfun(@(x) nanmean( x.io.X((x.io.Y==YVals(g)) , :),1) ,groupMdl,'uniformoutput',false));
    
    for k = 1:size(sortedYs{g},2)
    figure(348);subplot(3,7,k)
    scatter(starts(g):ends(g),sortedYs{g}(:,k),'markeredgecolor',colors(g,:));
    hold on;
    scatter(mean(starts(g):ends(g)),mean(sortedYs{g}(:,k)),100,'filled','markerfacecolor',colors(g,:))
    title(groupMdl{1}.fitCoeffsFields{k})
    set(gca,'xtick',[])
    end
    
end

suptitle('Population scatter of features discriminating angle')

%% plot 3d scatter of feats
figure(532);clf
featNum = [9 19 13];
mouseNum =2;
for d = 1:length(ia)
    hold on; scatter3(DmatX(ic==d,featNum(1)),DmatX(ic==d,featNum(2)),DmatX(ic==d,featNum(3)),'markeredgecolor',colors(d,:))
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

%% which features are most important?


blankSlate = zeros(size(groupMdl{1}.fitCoeffs{1}));

for g = 1:length(groupMdl)
    
    for b = 1:length(groupMdl{g}.fitCoeffs)
        blankSlate = blankSlate + groupMdl{g}.fitCoeffs{b};
    end
    
    [~,idx] = sort(abs(blankSlate(2:end,:)./length(groupMdl{g}.fitCoeffs)));
    
    for k = 1:length(unique(idx))
        [rs,~] = find(idx==k);
        rankScores(g,k) = sum(rs);
    end
    
end

[~,bfs] = sort(sum(rankScores));

%%
mouseNum = 5;

% DmatX = groupMdl{mouseNum}.io.X; 
DmatY = groupMdl{mouseNum}.outcomes.matrix(6,:);


[~,ia,ic] = unique(DmatY);
a_counts = accumarray(ic,1);
starts = [1 ; cumsum(a_counts(1:end-1))+1];
ends = cumsum(a_counts);
colors = jet(numel(ia));


x=groupMdl{mouseNum}.it.touchKappaV;
val = nan(size(x,2),1);
for g= 1:size(x,2)
    tmp  = find(~isnan(x(:,g)),1,'first');
    if ~isempty(tmp)
        val(g) = x(tmp,g);
    end
end


val2 = nanmean(x);
% val2 = DmatX(:,3)

figure(80);clf
subplot(3,1,1)
for d = 1:length(ia)
    hold on; scatter(starts(d):ends(d),val(ic==d),'markeredgecolor',colors(d,:))
end
set(gca,'xtick',[])
hold on;
subplot(3,1,2);
for d = 1:length(ia)
    hold on; scatter(starts(d):ends(d),val2(ic==d),'markeredgecolor',colors(d,:))
end
stdVal2 = (val2-nanmean(val2)) ./ nanstd(val2);
subplot(3,1,3);
for d = 1:length(ia)
    hold on; scatter(starts(d):ends(d),stdVal2(ic==d),'markeredgecolor',colors(d,:))
end
