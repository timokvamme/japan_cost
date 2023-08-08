function BandWidth=BenStuff_BwdSelecter(StimLevels, NoSuccess, NoTrials)
%BandWidth=BenStuff_BwdSelecter(StimLevels, NoSuccess, NoTrials)
%   Convenience wrapper for choice of bandwidth for use with modefree1.1
%   toolbox for psychometric curve fitting; code nicked from example at
%   www.modelfree.liv.ac.uk/demonatration.html

MinBwd=min(diff(StimLevels));
MaxBwd=max(StimLevels)-min(StimLevels);
bwd=bandwidth_cross_validation(NoSuccess,NoTrials,StimLevels,[MinBwd, MaxBwd]);
BandWidth=bwd(3);

end

