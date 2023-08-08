function Results = FlashBeep(sbj, screen, monitor)
%function Results = FlashBeep(Subject)
% function to test sound induced flash illusion
%
% Subject: subject ID as string (e.g. FlashBeep('BdH'))
%
% found a bug? please let me know!
% benjamindehaas@gmail.com 8/2017
%
% bdh: updated to standard disk stimuli for Kristian 3/2020
%
%

%% Household tasks
% clc;
warning('off','MATLAB:dispatcher:InexactMatch');% get rid of inexact case matching warnings:
Screen('Preference', 'SkipSyncTests', 1);

if nargin < 1
    sbj.id = num2str(input('Subject ID: '));
    sbj.name = input('Subject Name: ', 's');
    sbj.exp_type = input('Practice(1) or Main Exp(2)? ');
    sbj.res_path = sprintf('../results/Sub_%s', sbj.id);

    % !!need to modify if use new device
    monitor.num = max(Screen('Screens'));
    monitor.resolution = Screen('Resolution', monitor.num);
    monitor.distance = 0.6; % m

    %% Screen Parameters and keys
    Screen('Preference', 'SkipSyncTests', 0);
    [screen.window, screen.rect] = PsychImaging('OpenWindow', monitor.num, 0);
    Screen('BlendFunction', screen.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % 透明需要
    screen.nominalFrameRate = Screen('NominalFrameRate', screen.window);
    %if screen.nominalFrameRate ~= 100
    %    error('fresh rate is not 100 !');
    %end

    HideCursor;
end
Subject = sbj.id;
Results.Subject = Subject;
addpath(genpath([pwd filesep 'dep' filesep]));% add dependencies folder

text_color = 255;

%% query demographics
% if ~strcmp(Subject, 'Demo')
%     Results = EnquireDemographics( Results );
% end

%% Paths
filename = sprintf('%s/%s_SIFI_%s.mat', sbj.res_path, sbj.id, string(datetime('today', 'Format', 'yyyyMMdd')));
% [ ResDir, ResFileName ] = CheckResDir( Subject );

%% Parameter Settings
Params.ViewingDistance = monitor.distance * 1000;%in mm

%prioritylevel of PTB code
Params.PriorityLevel=2;
Params.AudioPriority=1;

%stimuls
Params.FixCol = [0 0 0];
Params.StimCol = [1 1 1].*.56;

Params.BackGr = [.5 .5 .5];
Params.StimEcc = 5;%8;%stimulus centered at what eccentricity -> pilot at 6 deg, if no SIFI move back out to 8

Params.FixSize = .15;%radius in d.v.a.
Params.StimSize = 1;%radius of stimulus in degrees

%sound
Params.Volume=0;
Params.SoundDur=20;%(ms)
% Params.SoundSampleFreq = 44100;
Params.SoundSampleFreq = 48000;
Params.SoundFreq = 3500;%

%Workflow
Params.FlashDur = 20; %duration in ms (closest number of frames will be chosen)
Params.ISI = 32; %inter stimulus interval
% Params.ISI = 16; %inter stimulus interval
Params.RefractoryPeriod = 500;%refractory period after key press

Params.TrialsPerBlock = 102;

if sbj.exp_type == 1 || strcmp(sbj.id, '9999')
    Params.NumBlocks = 1;
else
    Params.NumBlocks = 2;
end

%instructions
Params.TextDur = 1000;%text duration for instructions
Params.InitialInstr={'Welcome to the experiment!\n In each trial you will see small discs presented either on the upper side\n or on the lower side of the fixation.\n Please press `1` if you think you saw one flash \n and `2` if you think you saw two flashes.\n Please try to be as quick and accurate as possible. You can ignore the beeps.\n Please fixate on the dot at the middle of the screen at all times.\n Press SPACE key to start'};   

%Randomisation
Params.NumTrialTypes = 6;%1F1B, 1F2B, 2F1B, 2F2B, 1F0B, 2F0B
Params.TrialTypes = 1:Params.NumTrialTypes;
Params.TrialTypeNames = {'1F1B', '1F2B', '2F1B', '2F2B', '1F0B', '2F0B'};
Params.NumFlashes = [1, 1, 2, 2, 1, 2];%number of flashes
Params.NumBeeps = [1, 2, 1, 2, 0, 0];%number of beeps

UnshuffledTrialOrder = repmat(Params.TrialTypes, 1, Params.TrialsPerBlock./length(Params.TrialTypes));
UnshuffledUp =  [ones(1, Params.TrialsPerBlock/2), zeros(1, Params.TrialsPerBlock/2)];%position of flash

for iBlock = 1:Params.NumBlocks
    CurrShuffle = Shuffle(1:Params.TrialsPerBlock);
    Params.TrialTypeOrder(iBlock, :) = UnshuffledTrialOrder(CurrShuffle);
    Params.Up(iBlock, :) = UnshuffledUp(CurrShuffle);
end%for iBlock

Results.TrialTypeOrder = Params.TrialTypeOrder;%copy for convenience
Results.Up = Params.Up;

%% prepare PTB
% PsychJavaTrouble; %temporary fix for Java troubles, eventually adopt permanent solution (folder must be rooted or something)   
InitializePsychSound; %well, does what it says... needed for PsychPortAudio
Priority(Params.PriorityLevel);

% screen.window=Screen('OpenWindow', Params.WhichScreen, round(Params.BackGr*255));%, [background_r background_g background_b]);
Screen('FillRect', screen.window, round(Params.BackGr*255));
Screen('ColorRange', screen.window , 1.0);%scale to 0-1 (if it wasn't that before you need to adjust background (which will be black rather then grey))
%HideCursor;

Disp = BenStuff_PtbGetDisp(screen.window, Params.ViewingDistance);
Params.disp = Disp;

Results.Params = Params;

%% Textures
disp('preparing textures...');
[ FixTex, UpTex, DownTex ] = PrepareTextures( Params, screen.window);
EmptyTex = Screen('OpenOffScreenWindow', screen.window, Params.BackGr);

%% sound 
disp('preparing sounds...');
[ SoundData AudioHandle ] = PrepareSound( Params );
disp('done');

%% Welcome screen
if ~strcmp(Subject, 'Demo')
    for iStr = 1:length(Params.InitialInstr)
        DrawFormattedText(screen.window, char(Params.InitialInstr(iStr)), 'center', 'center', text_color); %display string
        Screen(screen.window,'Flip');
        WaitSecs(Params.TextDur/1000);
    end
end

KbPressWait;

%% Background & Testbeep
Screen('DrawTexture', screen.window, FixTex);
Screen('Flip', screen.window);
PsychPortAudio('FillBuffer', AudioHandle, SoundData);
PsychPortAudio('Start', AudioHandle);

%% Main experiment Loop including trial workflows
for iBlock = 1 : Params.NumBlocks
    
    Screen('Flip', screen.window);
    DrawFormattedText(screen.window, ['Block ' num2str(iBlock) ' of ' num2str(Params.NumBlocks) '. Press SPACE key to start'] , 'center', 'center', text_color);
    Screen('Flip', screen.window);
    KbPressWait;
    
    Screen('DrawTexture', screen.window, FixTex);
    Screen('Flip', screen.window);
    WaitSecs(2);
    
    for iTrial = 1 : size(Params.TrialTypeOrder, 2) 

        %% determine trial type
        TType =  Params.TrialTypeOrder(iBlock, iTrial);
        Up = Params.Up(iBlock, iTrial);
        
        NumFlashes = Params.NumFlashes(TType); 
        NumBeeps = Params.NumBeeps(TType);
        
        %% timing
        tStart = GetSecs;
        
        %% first beep?
        if NumBeeps > 1
            PsychPortAudio('Start', AudioHandle);
        end

        %% first flash
        if Up == 1
            Screen('DrawTexture', screen.window, UpTex);
        else
            Screen('DrawTexture', screen.window, DownTex);
        end%if Up
            
        Screen('Flip', screen.window);
        WaitSecs(Params.FlashDur/1000);

        %% ISI      
        Screen('DrawTexture', screen.window, FixTex);
        Screen('Flip', screen.window);
        WaitSecs(Params.ISI/1000);

        %% second sound?
        if NumBeeps > 0
            PsychPortAudio('Start', AudioHandle);
        end

        %% second flash?
        if NumFlashes > 1
            if Up == 1
                Screen('DrawTexture', screen.window, UpTex);
            else
                Screen('DrawTexture', screen.window, DownTex);
            end%if Up
            Screen('Flip', screen.window);
            WaitSecs(Params.FlashDur/1000);
        end
        
        %% ITI
        Screen('DrawTexture', screen.window, FixTex);    
        Screen('Flip', screen.window);
        
        RTstart = GetSecs;%start stopwatch for 

        %respone and logging
        AnswerKey = [];
        NoValidKey = 1;
        while NoValidKey
            [KeyTime, KeyCode] = KbPressWait;
            AnswerKey = KbName(find(KeyCode));
            
            if length(find(KeyCode)) == 1
                NoValidKey = ~strcmp(AnswerKey, 'esc') && ~strcmp(AnswerKey, 'ESCAPE') && ~strncmp('1', AnswerKey, 1) && ~strncmp('2', AnswerKey, 1);  
            end
        end
        
        if strcmp(AnswerKey, 'esc') == 1 || strcmp(AnswerKey, 'ESCAPE') == 1 
            Results.ABORTED = 1;
            % save([ResDir ResFileName], 'Results');
            % ShowCursor;
            ListenChar(0);
            % sca;
            return;
        end
        
        if strncmp('1', AnswerKey, 1)

            Results.Answers(iBlock, iTrial) = 1;
        elseif  strncmp('2', AnswerKey, 1)
            sprintf('answerkey down')
            sprintf('%s',AnswerKey)
            sprintf('answerkey up')
            Results.Answers(iBlock, iTrial) = 2;
        else
            Results.Answers(iBlock, iTrial) = NaN;
        end
        
        Results.AnswerKeyCodes(iBlock, iTrial, :) = KeyCode;
        Results.AnswerKeys{iBlock, iTrial} =  AnswerKey; 
        Results.RT(iBlock, iTrial) = KeyTime - RTstart;
        
        WaitSecs(Params.RefractoryPeriod./1000);
    end%for iTrial
end%for iBlock
Screen('Flip', screen.window);
DrawFormattedText(screen.window, 'Thank you!', 'center', 'center', text_color);
Screen('Flip', screen.window);
WaitSecs(1);
 
Priority(0);

%% Bye Bye
if sbj.exp_type == 2
    save(filename, 'Results');
end
return;
% save([ResDir ResFileName], 'Results');
% ShowCursor;
ListenChar(0);
% sca;





