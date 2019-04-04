%This script it used to take built models from main_builder and build out
%figures for data and results visualization. 

%Script is broken down into questions asked and plots used to answer. 

%% Q1 which touch features best discriminate angles (45 vs 135)
%population distribution of features
mdlName = 'mdlExpertTType'; %can use mdlExpertTType or mdlRadialChoice
yOut = 'ttype'; %can set to 'ttype' or 'choice' 
numBins = 15; %bins for histogram plot
population_histogram(mdlName,yOut,numBins);

%MCC comparison of ttype prediction 
mdlName = {'mdlNaiveTType','mdlExpertTType'};
gof_comparator(mdlName,'mcc');

%which feature is most important in ttype discrimination
mdlName ='mdlExpertTType';
heaviestCoefficients(mdlName);

%what reduced model will have ttype discrimination closest to full model
mdlName = {'mdlExpertTTypeRadialD','mdlExpertTTypeTouchTheta','mdlExpertTTypeDKappaV','mdlExpertTTypeDPhi','mdlExpertTTypeTopTwo','mdlExpertTTypeTopThree','mdlExpertTTypeTopFour','mdlExpertTType'};
gof_comparator(mdlName,'mcc');

%% Q2 which touch features best decode choice 

%population distribution of features
mdlName = 'mdlExpertChoice'; %can use mdlNaiveChoice or mdlExpertChoice
yOut = 'choice'; %can set to 'ttype' or 'choice' 
numBins = 15; %bins for histogram plot
population_histogram(mdlName,yOut,numBins);

%MCC comparison of choice prediction 
mdlName = {'mdlNaiveChoice','mdlExpertChoice'};
gof_comparator(mdlName,'mcc');

%which feature is most important in choice discrimination
mdlName ='mdlExpertChoice';
heaviestCoefficients(mdlName);

%what reduced model will have choice discrimination closest to full model
mdlName = {'mdlExpertKappaV','mdlExpertDKappaH','mdlExpertDPhi','mdlExpertDKappaV','mdlExpertTopTwo','mdlExpertTopThree','mdlExpertTopFour','mdlExpert'};
gof_comparator(mdlName,'mcc');

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
mdlName = 'mdlDiscrete'; 
population_angle_feature_scatter(mdlName)
fine_angle_cmatPlot(mdlName)

%identify top features and plot 3d scatter of top 3 feats
heaviestCoefficients_fineAngle(mdlName);

%using topFeats find a reduced model that can do as well as the full model 
mdlName = {'mdlDiscreteDPhi','mdlDiscreteDKappaH','mdlDiscreteSlideDistance','mdlDiscreteDKappaV','mdlDiscreteTopTwo','mdlDiscreteTopThree','mdlDiscreteTopFour','mdlDiscrete'};

% mdlName = {'mdlDiscreteExpertTouchTheta','mdlDiscreteExpertDKappaV','mdlDiscreteExpertDKappaH','mdlDiscreteExpertSlideDistance','mdlDiscreteExpertTopTwo','mdlDiscreteExpertTopThree','mdlDiscreteExpertTopFour','mdlDiscrete'};
gof = gof_comparator(mdlName,'modelAccuracy');

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

