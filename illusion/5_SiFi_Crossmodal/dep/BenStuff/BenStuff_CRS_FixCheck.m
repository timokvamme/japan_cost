function [ Fixated, ProportionValid ] = BenStuff_CRS_FixCheck( CritSamples, CritEccMM, FixCoordMM )
%[ Fixated, ProportionValid ] = BenStuff_CRS_FixCheck( CritSamples, CritEccMM, [FixCoordMM] ) 
% function to check fixation compliance using CRS eyetracker - will not
% empty buffer and can be used for gaze contingent displays
%
%
%   CritSamples:    define the number of most recent samples to check 
%                   (i.e. width of sliding window, typically we track at 200 Hz, so 20 samples translate to 100 ms)
%
%   CritEccMM:      eccentricity threshold in mm sreen space (mean of tracked CritSamples will be compared to that)
%
%   FixCoordMM:     expected fixation location in mm screen space (defaults to
%                   center [0,0]), CritEccMM will be calculated relative to this point
%
%
%   Fixation:       0: gaze direction outside CritEccMM (mean across tracked CritSamples)
%                   1: gaze direction within  CritEccMM
%                   2: no tracked samples (due to eg blinks, i.e. ProportionValid=0)
%                   3: number of available samples in buffer (incl untracked ones) < CritSamples
%
%   ProportionValid: proportion of tracked samples among CritSamples (NaN if Fixation=3)
%
%
% found a bug? please let me know!
% benjamindehaas@gmail.com 3/2015
%



if nargin<3
    FixCoordMM=[0,0];%default fixation point is at [0,0] (defined CRS style -> mm screen space)
end

CurrEye=vetGetBufferedEyePositions(false);%don't empty buffer, only read out

if  size(CurrEye.mmPositions,1)>=CritSamples%check that eyetracker has recorded at least the number of critical samples
    
    CurrMM=CurrEye.mmPositions(end-CritSamples+1:end,:);%trimming to desired number of samples
    CurrMM=CurrMM(logical(CurrEye.tracked(end-CritSamples+1:end)),:);%pruning dropped frames
    
    CurrEccMM=sqrt((CurrMM(:,1)-FixCoordMM(1)).^2+(CurrMM(:,2)-FixCoordMM(2)).^2);%transform x and y values to eccentricity relative to defined fixation point
    
    ProportionValid=mean(CurrEye.tracked(end-CritSamples+1:end));
    
    if ProportionValid>0
        if mean(CurrEccMM)>CritEccMM
            Fixated=0;%broke fixation
        else
            Fixated=1;%fixated
        end
    else
        Fixated=2;%all samples untracked
    end
else
    Fixated=3;%not enough samples in buffer
    ProportionValid=NaN;
end% if size ...>EyeCritSamples

                   

end

