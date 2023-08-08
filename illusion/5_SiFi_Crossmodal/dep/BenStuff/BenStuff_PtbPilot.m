function BenStuff_PtbPilot(func)

% this is a generic function for piloting stuff in ptb
% you can provide a function handle as input argument
%
% the handle should be for a function that displays one trial according to
% 'Parameters' struct - this in turn has a 'Condition' and a 'free' field.
% The first specifies a 'condition' (i.e. your function should branch
% accordingly) and the second the value of a free parameter (could be e.g.
% luminance contrast of a gabor...) 
%
% the function should further provide an output argument struct with an 
% keystroke-dependent updated version of 'Parameters' as first subfield and  
% a second subfiled 'NoAbort' which should be false if escape was pressed 
% during the preceding trial 
%
% in short: this will run any valid functionprovided  ad infinitum and 
% update Parameters online - so you can play around optimizing them



%% Household tasks

%clear all;
warning('off','MATLAB:dispatcher:InexactMatch');% get rid of inexact case matching warnigs:
clc;
close all;

%% generic Parameter Settings

%ISI

ISI=.5; %inter-stimulus interval in seconds

%which screen?
Parameters.whichScreen=0;

%prioritylevel of PTB code
PriorityLevel=2;
Parameters.AudioPriority=1;

PsychJavaTrouble; %temporary fix for Java troubles, eventually adopt permanent solution (folder must be rooted or something)   
InitializePsychSound; %well, does what it says... needed for PsychPortAudio


% % determine center of window
% [Parameters.window_width, Parameters.window_height]=Screen('windowsize', window); % give me the size of the window
% Parameters.window_centerCoord=[window_width/2, window_height/2];% store the centervalues in variables
% Parameters.window_centerX=window_centerCoord(1);
% Parameters.window_centerY=window_centerCoord(2);
%      

% %display calibration
% Parameters.screen_width=383; % 290 for laptop;
% Parameters.ViewingDistance=650; %input('distance from screen (mm)?')
% 
% [disp.WidthMM, disp.HeightMM]=Screen('DisplaySize', window); %get various infos to create PTB scalefactor
% screenNumber=Screen('WindowScreenNumber', window);
% disp.Resolution=Screen('Resolution', screenNumber);
% disp.Hz=1/Screen('GetFlipInterval', window);
% disp.PixPerMM=disp.Resolution.width/disp.WidthMM;
% disp.PixPerMMSanityCheck=disp.Resolution.height/disp.HeightMM;
% 
% disp.ViewingDistance=ViewingDistance;
% disp.DegVisAngPerMM=2*atand(.001/(2*disp.ViewingDistance/1000));%values in m!
% disp.DegVisAngPerPix=2*atand((.001/disp.PixPerMM)/(2*disp.ViewingDistance/1000));
% disp.PixPerDegVisAng=1/disp.DegVisAngPerPix;
% disp.Scale=disp.PixPerDegVisAng;

%% Parameters

Parameters.free=1;
Parameters.Condition=1;
Parameters.NoAbort=1;

%Parameters.disp=disp;
Parameters.ISI=ISI;
Parameters.Background=[127 127 127];


% Initialize PTB
[Win Rect] = Screen('OpenWindow', Parameters.whichScreen, Parameters.Background); 
Screen('BlendFunction', Win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;
RefreshDur = Screen('GetFlipInterval',Win);
Frames_per_Sec = 1 / RefreshDur;
Slack = RefreshDur / 2;
%Screen('ColorRange', Win , 256);%scale to 0-1 (if it wasn't that before you need to adjust background (which will be black rather then grey))
 

%global Win Rect;
 Parameters.Rect=Rect;
 Parameters.Win=Win;

%% Welcome

text_dur=.5;

InitialInstr={'Welcome to the Ptb_Pilot'; 'Use Number keys to change condition...'; '...and up/down arrows to vary free parameter'; 'Press any key to start'};  
for i=1:length(InitialInstr)
    DrawFormattedText(Win, char(InitialInstr(i)), 'center', 'center', [0 0 0]); %display string
    Screen(Win,'Flip');
    waitsecs(text_dur);
end
KbWait;

NoAbort=1;
%% Here is where shit happens
OutArg=func(Parameters); %trigger trial with these params
    
Parameters=OutArg;
   


%% Bye Bye
Screen('Flip', Win);
DrawFormattedText(Win, 'Thank you! Escaping now...', 'center', 'center', [0 0 0]);
Screen('Flip', Win);
waitsecs(1);

sca;


end


