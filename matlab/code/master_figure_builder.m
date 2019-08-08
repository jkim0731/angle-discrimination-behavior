%This script it used to take built models from main_builder and build out
%figures for data and results visualization. 

%Script is broken down into questions asked and plots used to answer. 

%% Q1 which touch features best discriminate angles (45 vs 135)
%population distribution of features
mdlName = 'mdlNaiveTType'; %can use mdlExpertTType or mdlRadialChoice
yOut = 'choice'; %can set to 'ttype' or 'choice' 
numBins = 15; %bins for histogram plot
population_histogram(mdlName,yOut,numBins);
%%
%MCC comparison of ttype prediction 
mdlName = {'mdlNaiveTType','mdlExpertTType'};
gof_comparator(mdlName,'mcc');
%%
%which feature is most important in ttype discrimination
mdlName ='mdlExpertTType';
heaviestCoefficients(mdlName);

%what reduced model will have ttype discrimination closest to full model
mdlName = {'mdlExpertTTypeRadialD','mdlExpertTTypeTouchTheta','mdlExpertTTypeDKappaV','mdlExpertTTypeDPhi','mdlExpertTTypeTopTwo','mdlExpertTTypeTopThree','mdlExpertTTypeTopFour','mdlExpertTType'};
gof_comparator(mdlName,'mcc');

%% Q2 which touch features best decode choice 

%population distribution of features
% mdlName = 'mdlExpertChoice'; %can use mdlNaiveChoice or mdlExpertChoice
mdlName = 'mdlDiscreteExpertChoice';
yOut = 'choice'; %can set to 'ttype' or 'choice' 
% numBins = 15; %bins for histogram plot
% population_histogram(mdlName,yOut,numBins);

%MCC comparison of choice prediction 
% mdlName = {'mdlNaiveChoice','mdlExpertChoice'};
mdlName = {'mdlDiscreteNaiveChoice','mdlDiscreteExpertChoice'};
gof_comparator(mdlName,'mcc');

%which feature is most important in choice discrimination
% mdlName ='mdlExpertChoice';
mdlName ='mdlDiscreteNaiveMeanTouch';
% mdlName ='mdlDiscreteExpertChoice_during';
heaviestCoefficients(mdlName)

%what reduced model will have choice discrimination closest to full model
mdlName = {'mdlExpertKappaV','mdlExpertDKappaH','mdlExpertDPhi','mdlExpertDKappaV','mdlExpertTopTwo','mdlExpertTopThree','mdlExpertTopFour','mdlExpert'};
mdlName = {'mdlDiscreteNaiveChoice_during','mdlDiscreteExpertChoice_during'};

% gof_comparator(mdlName,'modelAccuracy');
gof = gof_comparator(mdlName,'mcc');

%% Q3 what happens to choice discrimination in the presence of a distractor?

%MCC comparison of choice prediction 
mdlName = {'mdlNaiveChoice','mdlExpertChoice','mdlRadialChoice'};
gof_comparator(mdlName,'mcc');

%which feature is most important in choice discrimination
mdlName ='mdlRadialChoice';
heaviestCoefficients(mdlName)

%what reduced model will have choice discrimination closest to full model
mdlName = {'mdlRadialChoiceKappaV','mdlRadialChoiceDPhi','mdlRadialChoiceDKappaV','mdlRadialChoiceTopTwo','mdlRadialChoiceTopThree','mdlRadialChoice'};
gof_comparator(mdlName,'mcc');

%% Q4 which features at touch are most important for discriminating fine angles?

%Scatter of the mean of each feature for each mouse (open circles) or the
%population (filled) at each distinct angle from 45(blue) to 135 (red). 
% -features are standardized. 
mdlName = 'mdlDiscreteExpertMeanTouch'; 
% mdlName = 'mdlDiscreteNaiveIndivTouch'
fine_angle_cmatPlot(mdlName)
%identify top features and plot 3d scatter of top 3 feats
topFeats = heaviestCoefficients_fineAngle(mdlName);
%%
%using topFeats find a reduced model that can do as well as the full model 
mdlNames = {'mdlDiscreteExpertMeanTouch_Theta','mdlDiscreteExpertMeanTouch_dPhi','mdlDiscreteExpertMeanTouch_dKappaH','mdlDiscreteExpertMeanTouch_slideDistance', ...
    'mdlDiscreteExpertMeanTouch_dKappaV','mdlDiscreteExpertMeanTouch_Top2','mdlDiscreteExpertMeanTouch_Top3','mdlDiscreteExpertMeanTouch_Top4', ...
    'mdlDiscreteExpertMeanTouch_Top5', 'mdlDiscreteExpertMeanTouch'};
% mdlNames = {'mdlDiscreteNaiveMeanTouch_KappaV','mdlDiscreteNaiveMeanTouch_dPhi','mdlDiscreteNaiveMeanTouch_dKappaH','mdlDiscreteNaiveMeanTouch_dKappaV', ...
%     'mdlDiscreteNaiveMeanTouch_slideDistance','mdlDiscreteNaiveMeanTouch_Top2','mdlDiscreteNaiveMeanTouch_Top3','mdlDiscreteNaiveMeanTouch_Top4', ...
%     'mdlDiscreteNaiveMeanTouch_Top5', 'mdlDiscreteNaiveMeanTouch'};
% mdlNames = {'mdlDiscreteExpertIndivTouch_dPhi','mdlDiscreteExpertIndivTouch_dKappaH','mdlDiscreteExpertIndivTouch_theta','mdlDiscreteExpertIndivTouch_dKappaV', ...
%     'mdlDiscreteExpertIndivTouch_slideDistance','mdlDiscreteExpertIndivTouch_Top2','mdlDiscreteExpertIndivTouch_Top3','mdlDiscreteExpertIndivTouch_Top4', ...
%     'mdlDiscreteExpertIndivTouch_Top5', 'mdlDiscreteExpertIndivTouch'};
% mdlNames = {'mdlDiscreteNaiveIndivTouch_dPhi','mdlDiscreteNaiveIndivTouch_dKappaH','mdlDiscreteNaiveIndivTouch_kappaV','mdlDiscreteNaiveIndivTouch_slideDistance', ...
%     'mdlDiscreteNaiveIndivTouch_dKappaV','mdlDiscreteNaiveIndivTouch_Top2','mdlDiscreteNaiveIndivTouch_Top3','mdlDiscreteNaiveIndivTouch_Top4', ...
%     'mdlDiscreteNaiveIndivTouch_Top5', 'mdlDiscreteNaiveIndivTouch'};

% mdlName = {'mdlDiscreteExpertTouchTheta','mdlDiscreteExpertDKappaV','mdlDiscreteExpertDKappaH','mdlDiscreteExpertSlideDistance','mdlDiscreteExpertTopTwo','mdlDiscreteExpertTopThree','mdlDiscreteExpertTopFour','mdlDiscrete'};

%%
mdlNames = {'mdlDiscreteNaiveMeanTouch','mdlDiscreteNaiveMeanTouch_Top5ridge'};
gof = gof_comparator(mdlNames,'modelAccuracy');

pvalues = zeros(size(gof,1)-1,1);
for pi = 1 : length(pvalues)
    [~, pvalues(pi)] = ttest(gof(pi,:), gof(end,:));
end

%% figures for comparing naive and expert fine angles multinomial glm
figure('units', 'normalized', 'outerposition', [0.1 0.1 0.2 0.4]),
hold on
for j = 1 : 6
    plot([1,2], [gof(1,j), gof(2,j)], 'k-', 'linewidth', 1)
end
scatter(ones(6,1), gof(1,:), 'b', 'filled')
scatter(ones(6,1)*2, gof(2,:), 'r', 'filled')
xlim([0.5 2.5])
xticks([1,2])
xticklabels({'Naive', 'Expert'})
set(gca, 'linewidth', 1, 'fontsize', 14)
ylabel('Performance')
yticks(0.4:0.1:0.9)


%%
%running the above but for each individual touch and not the mean of
%touches
heaviestCoefficients_fineAngle('mdlDiscreteIndivTouch');
%%


%% Q5 Which feature at touch are most important for discriminating choice at fine angles?
mdlName = 'mdlDiscreteChoice'; 
psychogofAll = psychometric_curves_builder(mdlName);
heaviestCoefficients(mdlName)

%Aside: building choice prediction using first touches only 
mdlName = 'mdlDiscreteExpertChoiceFT'; 
psychogofFT = psychometric_curves_builder(mdlName);
heaviestCoefficients(mdlName);

%comparing RMSE between first and all touch model 
figure;clf
plot([psychogofFT.RMSE ;psychogofAll.RMSE],'ko-')
set(gca,'xlim',[.5 2.5],'xtick',[1 2],'ylim',[.2 .6],'ytick',[0:.2:.6],'xticklabel',{'first touch','all touches'})

%using top feats to find a reduced model 
mdlName = {'mdlDiscreteChoicePhi','mdlDiscreteChoiceKappaV','mdlDiscreteChoiceDKappaV','mdlDiscreteChoiceTopTwo','mdlDiscreteChoiceTopThree','mdlDiscreteChoice'};
gof = gof_comparator(mdlName,'mcc');

