function population_angle_feature_scatter(mdlName)

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

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