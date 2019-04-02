function it = instantTouchBuilder(behavioralStruct,wfa,whiskDir,touchOrder)

[touchOnsetMask, ~] = touchFinderMask(behavioralStruct,wfa,whiskDir,touchOrder);
featureMat = featureBuilder(behavioralStruct,wfa);
preDecisionMask = predecision_mask(behavioralStruct,wfa);


%one frame before touchOnsetMask
ptouchOnsetMask = nan(size(touchOnsetMask));
ptouchOnsetMask(find(touchOnsetMask==1)-1)=1; 


%instantaneous features
it.touchTheta = ptouchOnsetMask .* preDecisionMask .* featureMat.theta;
it.touchKappaH= ptouchOnsetMask .* preDecisionMask .* featureMat.kappaH;
it.touchKappaV = ptouchOnsetMask .* preDecisionMask .* featureMat.kappaV;
it.touchKappaVH = it.touchKappaV./it.touchKappaH;
it.touchPhi = ptouchOnsetMask .* preDecisionMask .* featureMat.phi;
it.touchRadialD = touchOnsetMask .* preDecisionMask .* featureMat.arcLength; 
it.touchCounts = sum(~isnan(it.touchTheta)); 


