function [results] = CHToolbox_PMF_Analysis(data, showOption)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% used to fit psychometric function and calculate threshold
% must contain PMs, ref_intensity and condition name of each PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

PMs = data.PMs;
for i = 1:length(PMs)
    PM = PMs(i);

    [SL_raw, NP, OON] = PAL_PFML_GroupTrialsbyX(PM.x(1:length(PM.x)-1),PM.response,ones(size(PM.response)));
    disp('before normalizing: ');
    [SL_raw; NP; OON; NP./OON]

    % SL_normalized = normalize(SL_raw, 'range');
    SL_normalized = CHToolbox_BASIC_Normalize(SL_raw, [PM.stimRange(1), PM.stimRange(end)]);
    disp('after normalizing: ');
    [SL_normalized; NP; OON; NP./OON]

    % searchGrid.alpha = PM.priorAlphaRange;
    searchGrid.alpha = CHToolbox_BASIC_Normalize(PM.priorAlphaRange, [PM.stimRange(1), PM.stimRange(end)]);
    searchGrid.beta = PM.priorBetaRange;
    searchGrid.gamma =  PM.priorGammaRange;
    searchGrid.lambda = PM.priorLambdaRange;

    PF = PM.PF;
    % PF = @PAL_Gumbel;
    % PF = @PAL_Weibull;
    % PF = @PAL_Logistic;
    % PF = @PAL_HyperbolicSecant;
    % PF = @PAL_Quick;
    % PF = @PAL_logQuick;
    % PF = @PAL_CumulativeNormal;

    options = PAL_minimize('options');
    options.MaxIter = 5000;
    options.MaxFunEvals = 5000;
    %  options.TolX = 10^-9;
    %  options.TolFun = 10^-9;

    if isfield(PM, 'gammaEQlambda')
        gammaEQlambda = PM.gammaEQlambda;
    else
        gammaEQlambda = 1;
    end

    if isfield(PM, 'paramsFree')
        paramsFree = PM.paramsFree;
    else
        paramsFree = [1 1 0 1];
    end


    [paramsValues, LL, exitflag] = PAL_PFML_Fit(SL_normalized, NP, OON, searchGrid, paramsFree, PF, 'searchOptions',options, 'gammaEQlambda', 1, 'lapselimits', [0 .1], 'lapsefit', 'nAPLE');
    results(i).paramsValues = paramsValues;
    threshold = PF(results(i).paramsValues, 0.5, 'inverse');
    results(i).threshold_normalized = threshold;
    % results(i).threshold = min(SL_raw) + (max(SL_raw)-min(SL_raw)) * threshold;
    results(i).threshold = PM.stimRange(1) + (PM.stimRange(end)-PM.stimRange(1)) * threshold;
    results(i).slope = PF(results(i).paramsValues, threshold, 'derivative');
    results(i).stimRange = PM.stimRange;
    results(i).LL = LL;

    %% residuals
    ProportionCorrectObserved = NP./OON; 
    y_estimation = PF(paramsValues, SL_normalized);
    results(i).residuals = sum(NP .* abs(ProportionCorrectObserved - y_estimation));

    if showOption
        figure; plot(PM.x); hold on; plot(PM.threshold)
        xlabel('Trial No.');
        ylabel('Stimulus Intensity');
    
        figure; plot(SL_raw, NP./OON)

        % StimLevelsFineGrain_raw = [min(SL_raw):0.01:max(SL_raw)];
        StimLevelsFineGrain_raw = [PM.stimRange(1):0.01:PM.stimRange(end)];
        % StimLevelsFineGrain_normalized = normalize(StimLevelsFineGrain_raw, 'range');
        StimLevelsFineGrain_normalized = CHToolbox_BASIC_Normalize(StimLevelsFineGrain_raw, [PM.stimRange(1), PM.stimRange(end)]);
        ProportionCorrectModel = PF(paramsValues, StimLevelsFineGrain_normalized);

        figure('name','Psychometric Function Fitting');
        axes
        hold on
        plot(StimLevelsFineGrain_normalized, ProportionCorrectModel, '-', 'color', [0 0 0.7],'linewidth',2);
        set(gca, 'XTick', round(StimLevelsFineGrain_normalized(round(linspace(1,length(StimLevelsFineGrain_raw),7))), 2));
        set(gca, 'XTickLabel', round(StimLevelsFineGrain_raw(round(linspace(1,length(StimLevelsFineGrain_raw),7))), 2));

        for SR = 1:length(SL_normalized(OON~=0))
            plot(SL_normalized(SR),ProportionCorrectObserved(SR),'ko','markerfacecolor','k','markersize',20*sqrt(OON(SR)./sum(OON)));
        end

        set(gca, 'fontsize', 16);
        title(PM.condition);
        xlabel(PM.xlabel);
        set(gca, 'fontsize', 12);
        ylabel(PM.ylabel);
        hold on, plot(linspace(min(StimLevelsFineGrain_normalized),max(StimLevelsFineGrain_normalized),10), repmat(.5,[1 10]), '--k')
        hold on, plot(repmat(threshold,[1 10]),linspace(0,1,10), '--k')
        if isfield(PM, 'ref_intensity')
            ref_intensity = (PM.ref_intensity - min(StimLevelsFineGrain_raw)) / (max(StimLevelsFineGrain_raw) - min(StimLevelsFineGrain_raw));
            hold on, plot(repmat(ref_intensity,[1 10]),linspace(0,1,10), '--k')
        end

        fprintf('Threshold of raw %s: %.3f\n', PM.condition, results(i).threshold);
        fprintf('Slope of normalized %s: %.3f\n', PM.condition, results(i).slope);
        fprintf('Residuals of %s: %.3f\n', PM.condition, results(i).residuals);
    end
end

toc
end