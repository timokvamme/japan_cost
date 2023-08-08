function [SD, Verticalness_Horizontal, Verticalness_Vertical]=BenStuff_EyeAnalyser( ResultsFiles, Figures, ConversionFactor )
%[SD, Verticalness_Horizontal, Verticalness_Vertical]=BenStuff_EyeAnalyser( ResultsFiles, [Figure], [ConversionFactor] )
%   Basic analysis of EyeLink output acquired with PTB toolbox, will loop
%   through all files provided 
%
%   found a bug? please let me know! benjamindehaas@gmail.com
%   
%   ResultsFiles: cell containing resultsfiles (.mat), these should contain
%                 - a n-by-1 'Results' struct including an 'Eye' field 
%                   (n=numbers of trials)
%                 - a 'Parameters' struct, including an Eye_tracker field 
%                   indicating whether the ET was used and a 'Conditions' 
%                   field indicating sweep directions for each trial
%
%   Figures: set to 0 to suppress plotting
%   
%   ConversionFactor: how many pix per degree visual angle? defaults to 43 
%
%   SD: average standard deviation of eye position across all sweeps for x
%   and y dimensions
%
%
%   Verticalness_Horizontal: average eye position SD in y dimension minus 
%                            average eye position SD in x dimension for 
%                            trials with horizontal sweep direction  
%
%   Verticalness_Vertical: average eye position SD in y dimension minus 
%                            average eye position SD in x dimension for 
%                            trials with vertical sweep direction
%
%   
%   The latter two output variables are useful if you want to check
%   whether ppts eye movements were related to sweep stimuli in a 
%   systematic way. Is the variance in eye position greater along the axis 
%   of the current sweep direction? 
%
%   The function also outputs a scatter plot of eye position. This is based
%   on median-centering data of each trial, which implements drift
%   correction and a 0-center calibration at the same time.
%
% One way of using this function is to include it in a script looping
% through all ppts and providing it with the files of one ppt in each
% iteration. The accumulated outputs could then be used for 2nd level stats
%
%

if nargin<2
    Figures=1;
end

if nargin<3
    ConversionFactor=1/43;%43 pix per degree visual angle
end
%% Let's go


%initialise variables
SDs=[];
SDs_Vertical=[];
SDs_Horizontal=[];
MedianCentred=[];
Vertical_MedianCentred=[];
Horizontal_MedianCentred=[];

% go through data
for RunNo=1:length(ResultsFiles)
    RunData=ResultsFiles{RunNo};
    load(RunData, 'Results', 'Parameters');
        
    if Parameters.Eye_tracker %only if we actually have data
         for TrialNo=1:length(Parameters.Conditions)
             
             SDs=[SDs; std((Results(TrialNo).Eye(:,2:3)))]; %first store away trial wise SDs
             MedianCentred=[MedianCentred; bsxfun(@minus,Results(TrialNo).Eye(:,2:3),median(Results(TrialNo).Eye(:,2:3)))];%...and median centred eye positions
             
              if Parameters.Conditions(TrialNo)==0 || Parameters.Conditions(TrialNo)==180 %also do it split according to sweep direction
                    Vertical_MedianCentred=[Vertical_MedianCentred; bsxfun(@minus,Results(TrialNo).Eye(:,2:3),median(Results(TrialNo).Eye(:,2:3)))];
                    SDs_Vertical=[SDs_Vertical; std((Results(TrialNo).Eye(:,2:3)))];
              elseif Parameters.Conditions(TrialNo)==90 || Parameters.Conditions(TrialNo)==270
                    Horizontal_MedianCentred=[Horizontal_MedianCentred; bsxfun(@minus,Results(TrialNo).Eye(:,2:3),median(Results(TrialNo).Eye(:,2:3)))];
                    SDs_Horizontal=[SDs_Vertical; std((Results(TrialNo).Eye(:,2:3)))];
              end
             
         end 
    end
end

SD=mean(SDs)*ConversionFactor;
SD_Vertical=mean(SDs_Vertical*ConversionFactor);
SD_Horizontal=mean(SDs_Horizontal)*ConversionFactor;
Verticalness_Horizontal=SD_Horizontal(2)-SD_Horizontal(1);
Verticalness_Vertical=SD_Vertical(2)-SD_Vertical(1);

Horizontal_MedianCentred=Horizontal_MedianCentred*ConversionFactor;
Vertical_MedianCentred=Vertical_MedianCentred*ConversionFactor;

%% draw figures
if Figures
    
    %scatterplot of drift corrected eyepositions across trials
    figure; hold on;
    title('Eye positions -> ALL trials');
    scatter(Horizontal_MedianCentred(:,1), Horizontal_MedianCentred(:,2),1, 'b');
    scatter(Vertical_MedianCentred(:,1), Vertical_MedianCentred(:,2),1, 'r');
    legend('horizontal sweeps', 'vertical sweeps');
    xlabel('Eye position [deg]');
    ylabel('Eye position [deg]');
    axis equal;
    hold off;
    
    %scatterplot of drift corrected eyepositions for horizontal sweep direction
    figure; hold on;
    title('Eye positions -> HORIZONTAL trials');
    scatter(Horizontal_MedianCentred(:,1), Horizontal_MedianCentred(:,2),1, 'b');
    xlabel('Eye position [deg]');
    ylabel('Eye position [deg]');
    axis equal;
    hold off;
    
    %scatterplot of drift corrected eyepositions for vertical sweep direction
    figure; hold on;
    title('Eye positions -> VERTICAL trials');
    scatter(Vertical_MedianCentred(:,1), Vertical_MedianCentred(:,2),1, 'r');
    xlabel('Eye position [deg]');
    ylabel('Eye position [deg]');
    axis equal;
    hold off;
end







end
 