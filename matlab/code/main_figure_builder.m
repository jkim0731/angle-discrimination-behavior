saveLoc = 'C:\Users\shires\Dropbox\Object Angle Coding in vS1\Figures\AngleDiscrimBehavior\' ;

%% FIG A: modeled choice prediction
mdlName = {'mdlNaiveChoice','mdlDiscreteNaiveChoice','mdlExpertChoice','mdlDiscreteChoice','mdlRadialChoice'};
gof_comparator(mdlName,'mcc');
set(gcf, 'Position',  [100, 100, 400, 500])
print([saveLoc 'figA'],'-depsc')

%% FIG B: Comparison of the top feature in choice (DKappaV) for naive vs expert
yOut = 'ttype'; %can set to 'ttype' or 'choice' 
if strcmp(yOut,'ttype')
    colors = {'r','b'};
elseif strcmp(yOut,'choice')
    colors = {'m','c'};
end

numBins = 15; %bins for histogram plot
naiveHisto = population_histogram('mdlNaiveChoice',yOut,numBins);
expertHisto = population_histogram('mdlExpertChoice',yOut,numBins);

featureNumber = 13; 
naiveY = nanmean(naiveHisto.Y{featureNumber}); 
naiveYerr = nanstd(naiveHisto.Y{featureNumber}) ./ sqrt(size(naiveHisto,1));
naiveX = naiveHisto.X{featureNumber};

expertY = nanmean(expertHisto.Y{featureNumber}); 
expertYerr = nanstd(expertHisto.Y{featureNumber}) ./ sqrt(size(expertHisto,1));
expertX = expertHisto.X{featureNumber};

figure(5);clf
subplot(2,1,1)
shadedErrorBar(naiveX,naiveY(1:length(naiveX)),naiveYerr(1:length(naiveX)),'lineprops',[colors{1} '-.'])
hold on; shadedErrorBar(naiveX,naiveY(length(naiveX)+1:end),naiveYerr(length(naiveX)+1:end),'lineprops',[colors{2} '-.'])
set(gca,'xtick',[-2:1:2],'ytick',0:.1:1,'ylim',[0 .25])
title(['Naive ' naiveHisto.fields{featureNumber}])
legend('R','L')
subplot(2,1,2)
shadedErrorBar(expertX,expertY(1:length(expertX)),expertYerr(1:length(expertX)),'lineprops',[colors{1} '-.'])
hold on; shadedErrorBar(expertX,expertY(length(expertX)+1:end),expertYerr(length(expertX)+1:end),'lineprops',[colors{2} '-.'])
set(gca,'xtick',[-2:1:2],'ytick',0:.1:1,'ylim',[0 .25])
title(['Expert ' naiveHisto.fields{featureNumber}])

set(gcf, 'Position',  [100, 100, 400, 600])
print([saveLoc 'figB1'],'-depsc')

%% FIG C: Psychometric curve building using top feature (DKappaV) in fine angle discrimination 
psychoFull = psychometric_curves_builder('mdlDiscreteChoice');
psychoDK = psychometric_curves_builder('mdlDiscreteChoiceDKappaV');

mouseNum = [1 5];
figure(6);clf
for i = 1:length(mouseNum) 
subplot(2,1,i); 
shadedErrorBar(45:15:135, psychoFull.plot.raw{mouseNum(i)}(:,1), psychoFull.plot.raw{mouseNum(i)}(:,2),'lineprops','r');
hold on;shadedErrorBar(45:15:135, psychoFull.plot.modeled{mouseNum(i)}(:,1), psychoFull.plot.modeled{mouseNum(i)}(:,2),'lineprops','k');
hold on;shadedErrorBar(45:15:135, psychoDK.plot.modeled{mouseNum(i)}(:,1), psychoDK.plot.modeled{mouseNum(i)}(:,2),'lineprops','k-.');
set(gca,'xtick',[45 90 135],'ytick',0:.25:1)
end
set(gcf, 'Position',  [100, 100, 300, 600])
legend('mouse','full model','DKappaV')
ylabel('P(lick right)')

print([saveLoc 'figC'],'-depsc')

%supFig C
psychoTopTwo = psychometric_curves_builder('mdlDiscreteChoiceTopTwo');
psychoKappaV = psychometric_curves_builder('mdlDiscreteChoiceKappaV');

figure(7);clf
plot([psychoKappaV.gof.RMSE ; psychoDK.gof.RMSE; psychoTopTwo.gof.RMSE; psychoFull.gof.RMSE],'ko-')
set(gca,'xtick',[1:4],'xlim',[.5 4.5],'xticklabel',{'Touch KappaV','DKappaV','TopTwo','Full'})
ylabel('RMSE from raw')
[~,p] = ttest(psychoFull.gof.RMSE,psychoDK.gof.RMSE)

%% FIG D: Heat map of fine angle discrimination 
fine_angle_cmatPlot('mdlDiscrete')
print([saveLoc 'figD'],'-depsc')
%% FIG E: Slide distance adds significnatly to fine angle discrimination 

%identify top features and plot 3d scatter of top 3 feats
heaviestCoefficients_fineAngle('mdlDiscrete');
print([saveLoc 'figE'],'-depsc')
%using topFeats find a reduced model that can do as well as the full model 
mdlName = {'mdlDiscreteDPhi','mdlDiscreteDKappaH','mdlDiscreteSlideDistance','mdlDiscreteDKappaV','mdlDiscreteTopTwo','mdlDiscreteTopThree','mdlDiscreteTopFour','mdlDiscrete'};
gof = gof_comparator(mdlName,'modelAccuracy');
set(gcf, 'Position',  [100, 100, 400, 500])
print([saveLoc 'figF'],'-depsc')

[~,p] = ttest(gof(end,:),gof(7,:))




