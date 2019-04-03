function gof = gof_comparator(mdlName,gofType)

gof = nan(length(mdlName),6); 
numVars = nan(1,length(mdlName)); 
for p = 1:length(mdlName)
    load(['C:\Users\shires\Documents\GitHub\AngleDiscrimBehavior\matlab\datastructs\' mdlName{p}])
    numVars(p) = size(groupMdl{1}.io.X,2);
    for k = 1:length(groupMdl)
        gof(p,k) = nanmean(groupMdl{k}.gof.(gofType));
    end
    
end

figure;plot(gof,'ko-')
if numel(mdlName)==6
    set(gca,'xtick',[1:length(mdlName)],'xticklabel',{'3','2','1','2+1','3+2+1','full'},'xlim',[.5 length(mdlName)+.5])
elseif numel(mdlName)==8
    set(gca,'xtick',[1:length(mdlName)],'xticklabel',{'4','3','2','1','2+1','3+2+1','4+3+2+1','full'},'xlim',[.5 length(mdlName)+.5])
else 
    set(gca,'xtick',[1:length(mdlName)],'xticklabel',mdlName,'xlim',[.5 length(mdlName)+.5])
end
if strcmp(gofType,'mcc')
    set(gca,'ylim',[-.2 1],'ytick',0:.25:1)
    hold on; plot([.5 length(mdlName)+.5],[0 0],'-.k')
elseif strcmp(gofType,'modelAccuracy')
    set(gca,'ylim',[0 1],'ytick',0:.25:1)
    chance = 1/length(unique(groupMdl{1}.io.Y));
    
    hold on; plot([.5 length(mdlName)+.5],[chance chance],'-.k')
end

ylabel('gof metric')

