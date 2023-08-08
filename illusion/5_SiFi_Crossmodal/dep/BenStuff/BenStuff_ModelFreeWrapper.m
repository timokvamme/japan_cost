function [ xFit, pFit, BandWidth ] = BenStuff_ModelFreeWrapper( StimLevels, NumCorrect, NumTrials, NumXfit)
%[ xFit, pFit, BandWidth ] = BenStuff_ModelFreeWrapper( StimLevels, NumCorrect, NumTrials, [NumXfit])
%   Convenience wrapper for modelfree1.1, code nicked from
%   www.modelfree.liv.ac.uk/demonstration.html, see there for details
%
%   found a bug? please let me know, benjamindehaas@gmail.com

if nargin<4
    NumXfit=999;%number of sample defaults to 10^3
else
    NumXfit=NumXfit-1;
end

BandWidth=BenStuff_BwdSelecter(StimLevels, NumCorrect, NumTrials);

xFit=[min(StimLevels):(max(StimLevels-min(StimLevels)))/NumXfit:max(StimLevels)];
    
pFit=locglmfit(xFit',NumCorrect,NumTrials,StimLevels,BandWidth);

end

