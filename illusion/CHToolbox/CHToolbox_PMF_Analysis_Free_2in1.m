function [all_results] = CHToolbox_PMF_Analysis_Free_2in1(data, legends, showOption)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plots data of 2 conditions on the same figure, free version of CHToolbox_PMF_Analysis, self-assembled data
    % used to fit psychometric function and calculate threshold
    % must contain PMs, ref_intensity and condition name of each PM
    % 22/9/21 add comments and save session
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tic
    
    draw_on_the_same_figure = 1;
    if draw_on_the_same_figure == 1 && showOption
        figure('name','Psychometric Function Fitting');
        f_num = length(data.PMss{1}); % how many sub-figures to show
        r_num = ceil(sqrt(f_num)); % row_num
        c_num = round(sqrt(f_num)); % column_num
    end
    
    for j = 1:length(data.PMss)
        PMs = data.PMss{j};
        for i = 1:length(PMs)
            PM = PMs(i);
    
            [SL_raw, NP, OON] = PAL_PFML_GroupTrialsbyX(PM.x(1:length(PM.x)-1),PM.response,ones(size(PM.response)));
            % disp('before normalizing: ');
            % [SL_raw; NP; OON; NP./OON]
    
            % SL_normalized = normalize(SL_raw, 'range');
            SL_normalized = CHToolbox_BASIC_Normalize(SL_raw, [PM.stimRange(1), PM.stimRange(end)]);
            % disp('after normalizing: ');
            % [SL_normalized; NP; OON; NP./OON]
    
            % grain = 101;
            % searchGrid.alpha = linspace(min(SL_raw), max(SL_raw), grain);
            % searchGrid.beta = linspace(log10(.0625), log10(80), grain);
            % searchGrid.gamma =  0;
            % searchGrid.lambda = (0:.002:.1);

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

            [paramsValues, LL, exitflag] = PAL_PFML_Fit(SL_normalized,NP, OON, searchGrid, paramsFree, PF, 'searchOptions',options, 'gammaEQlambda', gammaEQlambda, 'lapselimits', [0 .1], 'lapsefit', 'nAPLE');
            results(i).paramsValues = paramsValues;
            threshold = PF(paramsValues, 0.5, 'inverse');
            results(i).threshold_normalized = threshold;
            % results(i).threshold = min(SL_raw) + (max(SL_raw)-min(SL_raw)) * threshold;
            results(i).threshold = PM.stimRange(1) + (PM.stimRange(end)-PM.stimRange(1)) * threshold;
            results(i).slope = PF(paramsValues, threshold, 'derivative');
            results(i).LL = LL;
            results(i).stimRange = PM.stimRange;
            results(i).SL_raw = SL_raw;
            results(i).SL_normalized = SL_normalized;
            results(i).NP = NP;
            results(i).OON = OON;
    
            %% residuals
            ProportionCorrectObserved = NP./OON; 
            y_estimation = PF(paramsValues, SL_normalized);
            results(i).residuals = sum(NP .* abs(ProportionCorrectObserved - y_estimation));
            results(i).ProportionCorrectObserved = ProportionCorrectObserved;
        end
        all_results{j} = results;
    end
    
    if showOption
        for i = 1:length(all_results{1})
            % PF = @PAL_Logistic;
    
            SL_raw1 = all_results{1}(i).SL_raw;
            SL_normalized1 = all_results{1}(i).SL_normalized;
            NP1 = all_results{1}(i).NP;
            OON1 = all_results{1}(i).OON;
            paramsValues1 = all_results{1}(i).paramsValues;
            ProportionCorrectObserved1 = all_results{1}(i).ProportionCorrectObserved;
            threshold1 = all_results{1}(i).threshold_normalized;
    
            SL_raw2 = all_results{2}(i).SL_raw;
            SL_normalized2 = all_results{2}(i).SL_normalized;
            NP2 = all_results{2}(i).NP;
            OON2 = all_results{2}(i).OON;
            paramsValues2 = all_results{2}(i).paramsValues;
            ProportionCorrectObserved2 = all_results{2}(i).ProportionCorrectObserved;
            threshold2 = all_results{2}(i).threshold_normalized;
    
            % 共用一个x范围
            normalize_range = [all_results{1}(i).stimRange(1), all_results{1}(i).stimRange(end)];
            StimLevelsFineGrain_raw = [normalize_range(1):0.01:normalize_range(end)];
            if StimLevelsFineGrain_raw(end) ~= normalize_range(end)
                StimLevelsFineGrain_raw = [StimLevelsFineGrain_raw, normalize_range(end)];
            end

            StimLevelsFineGrain_normalized = CHToolbox_BASIC_Normalize(StimLevelsFineGrain_raw, [normalize_range(1), normalize_range(end)]);

            % StimLevelsFineGrain_raw1 = [min(SL_raw1):0.01:max(SL_raw1)+0.01];
            % StimLevelsFineGrain_normalized1 = normalize(StimLevelsFineGrain_raw1, 'range');
            ProportionCorrectModel1 = PF(paramsValues1, StimLevelsFineGrain_normalized);
    
            % StimLevelsFineGrain_raw2 = [min(SL_raw2):0.01:max(SL_raw2)+0.01];
            % StimLevelsFineGrain_normalized2 = normalize(StimLevelsFineGrain_raw2, 'range');
            ProportionCorrectModel2 = PF(paramsValues2, StimLevelsFineGrain_normalized);
    
            if draw_on_the_same_figure ~= 1
                figure('name','Psychometric Function Fitting');
            end
            axes
            hold on
            if draw_on_the_same_figure == 1
                subplot(r_num, c_num, i);
            end
            p1 = plot(StimLevelsFineGrain_normalized, ProportionCorrectModel1, '-', 'color', [0 0 0.7],'linewidth',2);
            set(gca, 'XLim',[StimLevelsFineGrain_normalized(1) StimLevelsFineGrain_normalized(end)]);
            set(gca, 'XTick', StimLevelsFineGrain_normalized(round(linspace(1,length(StimLevelsFineGrain_raw),7))));
            set(gca, 'XTickLabel', StimLevelsFineGrain_raw(round(linspace(1,length(StimLevelsFineGrain_raw),7))));
            hold on
            % continue;
            % figure;
            p2 = plot(StimLevelsFineGrain_normalized, ProportionCorrectModel2, '-', 'color', [0.7 0 0],'linewidth',2);
            set(gca, 'XLim',[StimLevelsFineGrain_normalized(1) StimLevelsFineGrain_normalized(end)]);
            set(gca, 'XTick', StimLevelsFineGrain_normalized(round(linspace(1,length(StimLevelsFineGrain_raw),7))));
            set(gca, 'XTickLabel', StimLevelsFineGrain_raw(round(linspace(1,length(StimLevelsFineGrain_raw),7))));
    
            hold on
            for SR = 1:length(SL_normalized1(OON1~=0))
                plot(SL_normalized1(SR),ProportionCorrectObserved1(SR),'ko','markerfacecolor',[0,0,1],'markersize',20*sqrt(OON1(SR)./sum(OON1)));
            end
            hold on
            for SR = 1:length(SL_normalized2(OON2~=0))
                plot(SL_normalized2(SR),ProportionCorrectObserved2(SR),'ko','markerfacecolor',[1,0,0],'markersize',20*sqrt(OON2(SR)./sum(OON2)));
            end
            PM = data.PMss{1}(i);
            set(gca, 'fontsize', 16);
            xlabel(PM.xlabel);
            set(gca, 'fontsize', 12);
            ylabel(PM.ylabel);
            hold on, plot(linspace(min(StimLevelsFineGrain_normalized),max(StimLevelsFineGrain_normalized),10), repmat(.5,[1 10]), '--k')
            hold on, plot(repmat(threshold1,[1 10]),linspace(0,1,10), '--b')
            hold on, plot(repmat(threshold2,[1 10]),linspace(0,1,10), '--r')
            if isfield(PM, 'ref_intensity')
                ref_intensity = (PM.ref_intensity - min(StimLevelsFineGrain_raw)) / (max(StimLevelsFineGrain_raw) - min(StimLevelsFineGrain_raw));
                hold on, plot(repmat(ref_intensity,[1 10]),linspace(0,1,10), '--k')
            end
            title(PM.condition);
            % title('Psychometric Function Fitting');
            legend([p1, p2], legends, 'Location', 'northwest');
        end
    end
    
toc
end