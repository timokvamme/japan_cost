function PPV = BenStuff_PPV( Prior, Power, Alpha )
%PPV = BenStuff_PPV( Prior, Power, Alpha ) positive predictive value of a significant result
%   Estimates chance of a significant result reflecting a true rather than
%   a false positive
%   Depending on what you're interested in and in order to get realistic results, you might want to correct
%   the alpha (or p-value) used for stuff like pot-hoc hypothesis fishing,
%   publication bias etc., etc. 
%   cf. Ioannidis, 2005 plos medicine
%   
%   Prior - estimated prior probability of hypothesis being true (or proportion of true hypothesis tested in a field etc.)
%   Power: 1-Beta in classical frequentist stats (1-false negative risk)
%   Alpha: false positive ratio - for specific results you migt want to use
%   p value (but cf above)
%
%
%   demo illustrating relationship between power and PPV for different priors:
%     Linewidth=1.5;
% 
%     Alpha=.05;
%     Power=[0:.01:1];
% 
%     PPV_Priorp2=BenStuff_PPV(.2, Power, Alpha);
%     PPV_Priorp5=BenStuff_PPV(.5, Power, Alpha);
%     PPV_Priorp7=BenStuff_PPV(.7, Power, Alpha);
% 
%     figure; hold on;
%     plot(Power, PPV_Priorp2, 'r', 'linewidth', Linewidth);
%     plot(Power, PPV_Priorp5, 'y', 'linewidth', Linewidth);
%     plot(Power, PPV_Priorp7, 'g', 'linewidth', Linewidth);
%     legend('Prior: .2', 'Prior: .5', 'Prior: .7', 'Location', 'Southeast');
%     set(gca, 'Fontsize', 14);
%     xlabel(['Power (1-Beta)/[Alpha always ' num2str(Alpha) ']']);
%     ylabel('Positive predictive power');
%   

PPV=Prior.*Power./((Power.*Prior)+Alpha.*(1-Prior));



end

