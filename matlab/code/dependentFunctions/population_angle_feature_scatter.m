function population_angle_feature_scatter(mdlName)

load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName])

YVals  = unique(groupMdl{1}.io.Y);
% numMice = length(groupMdl);
numMice = 4;
starts = 1:numMice:numMice*length(YVals);
ends = numMice:numMice:numMice*length(YVals);
colors = jet(length(YVals));

figure(349);clf
sortedYs = cell(1,length(YVals));

graphSorting = [1,5,2,3,6,7,10,11,12,13,9,8];
for g = 1:length(YVals)
%     sortedYs{g} = cell2mat(cellfun(@(x) nanmean( x.io.X((x.io.Y==YVals(g)) , :),1) ,groupMdl,'uniformoutput',false));
    sortedYs{g} = cell2mat(cellfun(@(x) nanmean( x.io.X((x.io.Y==YVals(g)) , :),1) ,groupMdl(1:4),'uniformoutput',false));
    
%     for k = 1:size(sortedYs{g},2)
%         figure(348);subplot(3,7,k)
    for kk = 1 : length(graphSorting)
        k = graphSorting(kk);
        figure(349); subplot(2,6,kk)
        
        scatter(starts(g):ends(g),sortedYs{g}(:,k),'markeredgecolor',colors(g,:));
        hold on;
        scatter(mean(starts(g):ends(g)),mean(sortedYs{g}(:,k)),100,'filled','markerfacecolor',colors(g,:))
        title(groupMdl{1}.fitCoeffsFields{k})
        set(gca,'xtick',[])
    end
    
end

suptitle('Population scatter of features discriminating angle')