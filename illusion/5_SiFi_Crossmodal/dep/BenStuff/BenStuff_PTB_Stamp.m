function Stamp = BenStuff_PTB_Stamp( Win )
%Stamp = BenStuff_PTB_Stamp( Win )
%   gather all the (screen, version, computer) information you can in one PTB struct 
%
%   Win: window pointer of window openend in psychtoolbox
%        this input argument is optional - if ommited will only query
%        machine and PTB version info
%
%
%   Stamp: struct saving contianing the following fields
%      
%             Stamp.Version
%             Stamp.WhichMachine
%             Stamp.Win.Kind
%             Stamp.Win.isOffscreen
%             Stamp.Win.FrameRate
%             Stamp.Win.NominalFrameRate
%             Stamp.Win.FlipInterval
%             Stamp.Win.nrValidSamples 
%             Stamp.Win.FlipSD 
%             Stamp.Win.ScreenNumber
%             Stamp.Win.Rect
%             Stamp.Win.PixelDepth
%             Stamp.Win.Width
%             Stamp.Win.Height
%             Stamp.Win.DispWidth
%             Stamp.Win.DispHeight
%             Stamp.Win.Oldmaximumvalue 
%             Stamp.Win.Oldclampcolors
%             Stamp.Win.LowLevelInfo 
%             Stamp.Win.Resolution
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 10/2014
%

%% systems info
Stamp.Version=Screen('Version');
Stamp.WhichMachine=Screen('Computer');

%% window or screen information
if nargin>0
    Stamp.Win.Kind=Screen(Win, 'WindowKind');
    Stamp.Win.isOffscreen=Screen(Win,'IsOffscreen');
    Stamp.Win.FrameRate=Screen('FrameRate', Win);
    Stamp.Win.NominalFrameRate=Screen('NominalFrameRate', Win);
    [ Stamp.Win.FlipInterval, Stamp.Win.nrValidSamples, Stamp.Win.FlipSD ]=Screen('GetFlipInterval', Win);
    Stamp.Win.ScreenNumber=Screen('WindowScreenNumber', Win);
    Stamp.Win.Rect=Screen('Rect', Win);
    Stamp.Win.PixelDepth=Screen('PixelSize', Win);
    [Stamp.Win.Width, Stamp.Win.Height]=Screen('WindowSize', Win);
    [Stamp.Win.DispWidth, Stamp.Win.DispHeight]=Screen('DisplaySize', Win);
    [Stamp.Win.Oldmaximumvalue, Stamp.Win.Oldclampcolors] = Screen('ColorRange', Win);
    Stamp.Win.LowLevelInfo = Screen('GetWindowInfo', Win);
    Stamp.Win.Resolution=Screen('Resolution', Win);
end


end

