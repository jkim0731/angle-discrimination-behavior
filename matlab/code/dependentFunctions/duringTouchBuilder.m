function dt = duringTouchBuilder(behavioralStruct,wfa,whiskDir,touchOrder)

%whiskDir can be protraction or ALL
if strcmp(whiskDir,'protraction')
    tfchunks = 'protractionTFchunksByWhisking'; % this is only the protraction whisk of protraciton touches; can also set as protractionTFchunks whic hare pro+ret whisks on protraciton touches
    selTDur = 'protractionTouchDurationByWhisking';
    selTSlide = 'protractionSlideByWhisking';
elseif strcmp(whiskDir,'all')
    tfchunks = 'protractionTFchunks'; 
    selTDur = 'protractionTouchDuration';
    selTSlide = 'protractionSlide';
end


fieldsToCheck = {'theta','phi','kappaH','kappaV','arcLength'};
for t = 1:length(fieldsToCheck)
    nanOnset =  cellfun(@(x) cellfun(@(y) isnan(x.(fieldsToCheck{t})(y(1))) ,x.(tfchunks)),wfa.trials,'uniformoutput',false);
    for g = 1:length(nanOnset)
        wfa.trials{g}.(tfchunks) = wfa.trials{g}.(tfchunks)(~nanOnset{g});
        wfa.trials{g}.(selTDur) = wfa.trials{g}.(selTDur)(~nanOnset{g});
        wfa.trials{g}.(selTSlide) = wfa.trials{g}.(selTSlide)(~nanOnset{g});
    end
end


%during touch features - predecision mask
pdm = predecision_mask(behavioralStruct,wfa);
touchOnsetFrame = cellfun(@(y) cellfun(@(x)  x(1) ,y.(tfchunks)),wfa.trials,'uniformoutput',false);
firstDIdx = cell(1,size(touchOnsetFrame,2));
for i = 1:numel(touchOnsetFrame)
    firstDIdx{i} = find(pdm(:,i)==1,1,'last');
end

if strcmp(touchOrder,'first')
    dt.mask.pdTouches = cellfun(@(x,y) find(x<y),touchOnsetFrame,firstDIdx,'uniformoutput',false);
    dt.mask.pdTouches = cellfun(@(x) find(x==1) , dt.mask.pdTouches,'uniformoutput',false);
elseif strcmp(touchOrder,'all')
    dt.mask.pdTouches = cellfun(@(x,y) find(x<y),touchOnsetFrame,firstDIdx,'uniformoutput',false);
else
    error('need to select touch direction "all" or "first" ')
end


% dt.features.maxDtheta = cellfun(@(y) cellfun(@(x) y.theta(x(find(abs(y.theta(x) - y.theta(x(1))) == max(abs(y.theta(x) - y.theta(x(1)))) ) ) ) - y.theta(x(1)), ...
%     y.(tfchunks),'uniformoutput',false), wfa.trials, 'uniformoutput', false); % max DeltaTheta from touchOnset Theta

%Minor fix for nan values - interpolate using two points around nan values 
% for g=1:length(wfa.trials)
%     fieldsToCheck = {'theta','phi','kappaH','kappaV','arcLength'};
%     for u = 1:length(fieldsToCheck)
%         nanIdx = find(isnan(wfa.trials{g}.(fieldsToCheck{u})));
%         nanIdx = nanIdx(nanIdx<length(wfa.trials{g}.(fieldsToCheck{u})));
%         if sum(diff(nanIdx)==1)<1 %This is to only interp for indices that are not consecutive
%             if ~isempty(nanIdx)
%                 fillers = mean([wfa.trials{g}.(fieldsToCheck{u})(nanIdx-1) wfa.trials{g}.(fieldsToCheck{u})(nanIdx+1)],2);
%                 wfa.trials{g}.(fieldsToCheck{u})(nanIdx) = fillers;
%             end
%         end
%     end
% end


%during touch features
dt.features.touchDuration = cellfun(@(x) x.(selTDur), wfa.trials, 'uniformoutput', false);

dt.features.maxSlideDistance = cellfun(@(y) cellfun(@max, y.(selTSlide)), wfa.trials, 'uniformoutput', false);

dt.features.maxDtheta = cellfun(@(y) cellfun(@(x) y.theta(x(find(abs(y.theta(x) - y.theta(x(1))) == max(abs(y.theta(x) - y.theta(x(1)))) ) ) ) - y.theta(x(1)), ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); % max DeltaTheta from touchOnset Theta

dt.features.maxDphi = cellfun(@(y) cellfun(@(x) y.phi(x(find(abs(y.phi(x) - y.phi(x(1))) == max(abs(y.phi(x) - y.phi(x(1)))) ) ) ) - y.phi(x(1)), ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); %max DeltaPhi from touchOnset Phi

dt.features.maxDkappaH = cellfun(@(y) cellfun(@(x) y.kappaH(x(find( max(abs(y.kappaH(x)-y.kappaH(x(1)))) == abs(y.kappaH(x)-y.kappaH(x(1))),1,'first'))) -y.kappaH(x(1))  , ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); %TOP DOWN VIEW max kappaH in touch window

dt.features.maxDkappaV = cellfun(@(y) cellfun(@(x) y.kappaV(x(find( max(abs(y.kappaV(x)-y.kappaV(x(1)))) == abs(y.kappaV(x)-y.kappaV(x(1))),1,'first'))) -y.kappaV(x(1))  , ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); %FRONT VIEW max kappaV in touch window


dt.features.maxDkappaVidxHratio = cellfun(@(y) cellfun(@(x) ( y.kappaV(x(find(max(abs(y.kappaV(x)-y.kappaV(x(1)))) == abs(y.kappaV(x)-y.kappaV(x(1))),1,'first')))-y.kappaV(x(1))) ./ (y.kappaH(x(find( max(abs(y.kappaV(x)-y.kappaV(x(1)))) == abs(y.kappaV(x)-y.kappaV(x(1))),1,'first'))) - y.kappaH(x(1))) , ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); %Max FRONTVIEW kap ./ TOPVIEW kap at that kapVIDX
dt.features.maxDkappaVHidxratio = cellfun(@(y) cellfun(@(x) ( y.kappaV(x(find( max(abs(y.kappaH(x)-y.kappaH(x(1)))) == abs(y.kappaH(x)-y.kappaH(x(1))),1,'first')))-y.kappaV(x(1))) ./ (y.kappaH(x(find( max(abs(y.kappaH(x)-y.kappaH(x(1)))) == abs(y.kappaH(x)-y.kappaH(x(1))),1,'first'))) - y.kappaH(x(1))) , ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); %Max FRONTVIEW kap ./ TOPVIEW kap at that kapHIDX
dt.features.maxDphiIdxThetaratio = cellfun(@(y) cellfun(@(x) ( y.phi(x(find( max(abs(y.phi(x)-y.phi(x(1)))) == abs(y.phi(x)-y.phi(x(1))),1,'first')))-y.phi(x(1))) ./ (y.theta(x(find( max(abs(y.phi(x)-y.phi(x(1)))) == abs(y.phi(x)-y.phi(x(1))),1,'first'))) - y.theta(x(1))) , ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); % phiThetaRatio at max phiIdx
dt.features.maxDphiThetaIdxratio = cellfun(@(y) cellfun(@(x) ( y.phi(x(find( max(abs(y.theta(x)-y.theta(x(1)))) == abs(y.theta(x)-y.theta(x(1))),1,'first')))-y.phi(x(1))) ./ (y.theta(x(find( max(abs(y.theta(x)-y.theta(x(1)))) == abs(y.theta(x)-y.theta(x(1))),1,'first'))) - y.theta(x(1))) , ...
    y.(tfchunks)), wfa.trials, 'uniformoutput', false); % phiThetaRatio at max thetaIdx


% FOR CHECKING kappaH @ maxV idx and filtering
% dt.VIDX = cellfun(@(y) cellfun(@(x) ( y.kappaH(x(find(max(abs(y.kappaV(x)-y.kappaV(x(1)))) == abs(y.kappaV(x)-y.kappaV(x(1))),1,'first')))-y.kappaH(x(1))) , ...
%     y.(tfchunks)), wfa.trials, 'uniformoutput', false); %Max FRONTVIEW kap ./ TOPVIEW kap at that kapVIDX
% dt.HIDX = cellfun(@(y) cellfun(@(x) ( y.kappaV(x(find(max(abs(y.kappaH(x)-y.kappaH(x(1)))) == abs(y.kappaH(x)-y.kappaH(x(1))),1,'first')))-y.kappaV(x(1))) , ...
%     y.(tfchunks)), wfa.trials, 'uniformoutput', false); %Max FRONTVIEW kap ./ TOPVIEW kap at that kapVIDX
% VMask = cellfun(@(x) (x)<0,dt.VIDX,'uniformoutput',false);
% 


%INDEX of MAXABS = find(abs(y.phi(x)-y.phi(x(1)))==max(abs(y.phi(x)-y.phi(x(1)))))
dt.features.maxDphiDuration = cellfun(@(y) cellfun(@(x) (y.phi( x(find(abs(y.phi(x)-y.phi(x(1)))==max(abs(y.phi(x)-y.phi(x(1))))) )) - y.phi(x(1)) ) ./ find(abs(y.phi(x)-y.phi(x(1)))==max(abs(y.phi(x)-y.phi(x(1))))), ...
    y.(tfchunks)), wfa.trials,'uniformoutput',false);

dt.features.maxDkappaVDuration = cellfun(@(y) cellfun(@(x) (y.kappaV( x(find(abs(y.kappaV(x)-y.kappaV(x(1)))==max(abs(y.kappaV(x)-y.kappaV(x(1)))),1,'first') )) - y.kappaV(x(1)) ) ./ find(abs(y.kappaV(x)-y.kappaV(x(1)))==max(abs(y.kappaV(x)-y.kappaV(x(1)))),1,...
'first'),y.(tfchunks)), wfa.trials,'uniformoutput',false);

dt.features.maxDphiDistance = cellfun(@(y) cellfun(@(x,z) (y.phi( x(find(abs(y.phi(x)-y.phi(x(1)))==max(abs(y.phi(x)-y.phi(x(1))))) )) - y.phi(x(1)) ) ./ z(find(abs(y.phi(x)-y.phi(x(1)))==max(abs(y.phi(x)-y.phi(x(1)))))) , ...
    y.(tfchunks),y.(selTSlide)), wfa.trials,'uniformoutput',false);

dt.features.maxDkappaVDistance = cellfun(@(y) cellfun(@(x,z) (y.kappaV( x(find(abs(y.kappaV(x)-y.kappaV(x(1)))==max(abs(y.kappaV(x)-y.kappaV(x(1)))),1,'first') )) - y.kappaV(x(1)) ) ./ z(find(abs(y.kappaV(x)-y.kappaV(x(1)))==max(abs(y.kappaV(x)-y.kappaV(x(1)))),1,'first')) , ...
    y.(tfchunks),y.(selTSlide)), wfa.trials,'uniformoutput',false);