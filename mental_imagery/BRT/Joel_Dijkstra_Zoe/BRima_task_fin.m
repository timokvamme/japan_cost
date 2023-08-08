function BRima_task_fin(P)
%% ---------- Description ----------
% runs experiment

% author: Youngzie Lee, UCLA
% last edited: 09.23.2020

%% ---------- Program history ----------


%% ---------- START ----------
% oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
% oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
% Prevents MATLAB from reprinting the source code when the program runs.
echo off

PsychDefaultSetup(2);

%KbName('UnifyKeyNames');
% RestrictKeysForKbCheck([]); % reenable all keys for KbCheck
% 
% % Prevent spilling of keystrokes into console:
ListenChar(-1);

%% ---------- TRY ----------
try
    % Find out how many screens and use largest screen number.
    Screen('Preference','SkipSyncTests', 1) % RRadd
    
    screenid = max(Screen('Screens'));    
    PsychImaging('PrepareConfiguration');
%     PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

    deviceIndex = [];
%     Screen('Preference', 'SkipSyncTests', 2)
    % ---------- Window Setup ----------
    % Opens a window, fill it with background color (black)

    [wPtr, rect] = PsychImaging('OpenWindow', screenid, P.backgroundColor, [0 0 1900 1050]); % 6 is for stereomode
%     
%     [wPtr, rect] = Screen('OpenWindow', screenid, P.backgroundColor, P.resolution);
    
%     [wPtr, rect] = PsychImaging('OpenWindow', screenid, P.backgroundColor);
%     [w, h] = RectSize(rect);
     
%     SetAnaglyphStereoParameters('LeftGains', wPtr,  [1.0 0.0 0.0]);
%     SetAnaglyphStereoParameters('RightGains', wPtr, [0.0 0.6 0.0]);

    [xCenter, yCenter] = RectCenter(rect); % center of screen
    
    % Enable alpha blending
    Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
%     HideCursor;
    refreshDur = Screen('GetFlipInterval',wPtr);
    slack = refreshDur / 2;
    
    % ---------- Set Text Style ----------
    Screen('TextStyle', wPtr, 1)
    Screen('Preference', 'DefaultFontSize', P.fontSize);
    Screen('Preference', 'DefaultFontName', P.fontName);
    Screen('TextSize', wPtr, P.fontSize);
    Screen('TextFont', wPtr, P.fontName);
    
    
    %% ---------- Set Keys ----------
 
    %enabledKeys = [KbName(P.escapeKey), KbName(P.leftKey), KbName(P.rightKey), KbName(P.keys)];
    %RestrictKeysForKbCheck(enabledKeys); % this speeds up KbCheck
    
    KbName('UnifyKeyNames');
    KbQueueCreate();
    KbQueueStart(); 
    
    %% ------ Fixation Cross ------
    fix_xCoords = [-P.fixCrossDimPix P.fixCrossDimPix 0 0];
    fix_yCoords = [0 0 -P.fixCrossDimPix P.fixCrossDimPix];
    fix_allCoords = [fix_xCoords; fix_yCoords];
    
    %% ------ Create Stimuli ------

    %% make grating texture (stimulus)
    stimRect    = [0 0 P.stimSizeInPix(1) P.stimSizeInPix(2)];
    gabortex = CreateProceduralGabor(wPtr, P.tw, P.th, 1);
    stim = gabortex;
    
    % Initialize matrix with spec for gabor patches:
    mypars_red = repmat([P.phase+180, P.freq, P.edge, P.redContrast, P.aspectRatio, 0, 0, 0]', 1, 2);
    mypars_green = repmat([P.phase+180, P.freq, P.edge, P.greenContrast, P.aspectRatio, 0, 0, 0]', 1, 2);

    % draw once
    Screen('DrawTexture', wPtr, gabortex, [], [], [], [], [], [], [],...
    kPsychDontDoRotation, [P.phase, P.freq, P.edge, P.contrast, P.aspectRatio, 0, 0, 0]);
   
    
    %% make mock stimulus % need to revise this to adapt to new gabor patch. look up literature.
    mock_red=stim';
    mock_blue=stim;
    amp=27;
%     EE=smooth((smooth(amp*randn(1, P.stimSizeInPix(1)), 30))+round(P.stimSizeInPix(1)/2)); % was 100 at the end
    EE=(amp*randn(1, P.stimSizeInPix(1), 30))+round(P.stimSizeInPix(1)/2);
    EE=round(EE);

    for loop=1:P.stimSizeInPix(1)

        mock_red(1:(EE(loop)), loop)=0;
        mock_blue((EE(loop)):P.stimSizeInPix(1), loop)=0;

    end

    redmockTexture = Screen('MakeTexture',wPtr,mock_red);
    bluemockTexture = Screen('MakeTexture',wPtr,mock_blue);

%     redContrast  = P.redContrast;
%     greenContrast = P.greenContrast;
    
    %% ------ Create Vividness Rating Stimuli ------
    nScales = 10; % number of tickpoints
    ticklength = P.lineLengthPix/nScales*2;
    
    % horizontal line coordinates
    line_Coords = [-P.lineLengthPix P.lineLengthPix; 0 0];
    
    % vertical line coordinates
    vertLine_xCoords = sort(repmat([-P.lineLengthPix:ticklength:P.lineLengthPix], 1, 2));
    vertLine_yCoords = repmat([-P.vertLineLengthPix/2 P.vertLineLengthPix/2], 1, nScales+1);
    vertLine_allCoords = [vertLine_xCoords; vertLine_yCoords];

    % slider oval
    spotRadius = 10;
    spotDiameter = spotRadius * 2;
    spotRect = [0 0 spotDiameter spotDiameter];
    centeredspotRect = CenterRect(spotRect, rect); % Center the spot.
    

    %% ------ Standby ------
%     keysOfInterest=zeros(1,256);
%     keysOfInterest(KbName('j'))=1;
%     KbQueueCreate(deviceIndex, keysOfInterest);
   
    message = 'Press left key to start';
    
    stimCenter = CenterRect(stimRect,rect);
    Screen('FillRect', wPtr, P.backgroundColour, rect);
    
    % red
    Screen('DrawTexture', wPtr, gabortex, [], [stimCenter(1)/2 stimCenter(2)+P.stimSizeInPix(1) stimCenter(1)/2+P.stimSizeInPix(1) stimCenter(4)+P.stimSizeInPix(1) ], 45, [], [], [1 0 0], [], kPsychDontDoRotation, mypars_red);
    % green
    Screen('DrawTexture', wPtr, gabortex, [], [stimCenter(1)+stimCenter(1)/2 stimCenter(2)+P.stimSizeInPix(1) stimCenter(1)+stimCenter(1)/2+P.stimSizeInPix(1) stimCenter(4)+P.stimSizeInPix(1) ], 135, [], [], [0 1 0], [], kPsychDontDoRotation, mypars_green);

    DrawFormattedText(wPtr, P.retroCueID{1}, P.midX-(stimCenter(1)-stimCenter(1)/2), P.midY-P.stimSizeInPix(1)/2+P.stimSizeInPix(1)*2.5, [255 255 255], [], [], [], 1.5);
    DrawFormattedText(wPtr, P.retroCueID{2}, P.midX+(stimCenter(1)-stimCenter(1)/2), P.midY-P.stimSizeInPix(1)/2+P.stimSizeInPix(1)*2.5, [255 255 255], [], [], [], 1.5);
    DrawFormattedText(wPtr, message, 'center', 'center', [255 255 255], [], [], [], 1.5);
    
    Screen('Flip', wPtr);
    
    % Wait for input (left key press 'j')
%     KbQueueStart(deviceIndex);
%     KbWait([],2);
    KbQueueWait(); %KbName('j')

    % define start of the experiment
    T.startTime = GetSecs;
%     KbQueueRelease(deviceIndex);

    
    %% ------ Fixation block ------
    if P.fix > 0
        Screen('FillRect', wPtr, P.backgroundColour, rect);
        Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);
        Screen('Flip', wPtr);
        WaitSecs(P.fix-2*slack);
    end
    
    
    %% ------ Timing calculation ------
    flipmisscount = 0;

    T.timings = zeros(P.nTrialsPerRun,11);
    T.realtimings = zeros(P.nTrialsPerRun,11);

    trialOnset     = 1;
    cueOnset       = 2;
    imageryOnset   = 3;
    confOnset      = 4;
    BRstimOnset    = 5;
    responseOnset  = 6;
    responseOffset = 7;
    
    
    %% ------ initiation of some variables  ------
    triggers = zeros(3000,2);
    triggerCount = 1;

    B = zeros(P.nTrialsPerRun,8); % behavioural data
    responseConf = 1;
    confStartTime = 2;
    confEndTime = 3; 
    confReverse = 4; % scale reversed?
    trialResponse = 5;
    trialRT = 6;

    
    %% ------ Set Keys again ------
    keysOfInterest=zeros(1,256);
    keysOfInterest(P.rightKey)=1;
    keysOfInterest(P.leftKey)=1;
    keysOfInterest(P.escapeKey)=1;
    keysOfInterest(P.redKey)=1;
    keysOfInterest(P.greenKey)=1;
    keysOfInterest(P.mixedKey)=1;

    %% ------ Trials ------
    
    for iTrial = 1:P.nTrialsPerRun
   
    %% Determine timings
        if iTrial == 1
            T.timings(iTrial,trialOnset) = T.startTime + P.fix;
        else
            T.timings(iTrial,trialOnset) = T.timings(iTrial-1,responseOffset) + (P.ITIrange(1) + (P.ITIrange(2)-P.ITIrange(1)).*rand(1));
        end
    
        T.timings(iTrial,cueOnset) = T.timings(iTrial,trialOnset) + P.startDur + P.postStartDur;

        T.timings(iTrial,imageryOnset) = T.timings(iTrial,cueOnset) + P.cueDur;

        T.timings(iTrial,confOnset) = T.timings(iTrial,imageryOnset) + P.imageryDur;

        T.timings(iTrial,BRstimOnset) = T.timings(iTrial,confOnset) + P.confDur;

        T.timings(iTrial,responseOnset) = T.timings(iTrial,BRstimOnset) + P.BRstimDur;
    
        %% Fixation
        Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);
%         currTime = Screen('Flip', wPtr, T.timings(iTrial,trialOnset)-slack);
        currTime = Screen('Flip', wPtr);
        WaitSecs('YieldSecs', 1);
        T.realtimings(iTrial,trialOnset) = currTime - T.startTime;
    
        %% Present cue
        DrawFormattedText(wPtr, P.retroCueID{P.trialMatrix(iTrial,1)}, 'center', 'center', P.retroCueColour);
        %currTime = Screen('Flip', wPtr, T.timings(iTrial,cueOnset)-slack);
        currTime = Screen('Flip', wPtr);
        WaitSecs('YieldSecs', 1);
        T.realtimings(iTrial,cueOnset) = currTime - T.startTime;
        %Screen('Flip', wPtr, T.timings(iTrial,cueOnset)+P.cueDur-slack);

        %% Imagery
        Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);
        Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);
        %currTime = Screen('Flip', wPtr, T.timings(iTrial,imageryOnset)-slack);
        currTime = Screen('Flip', wPtr);
        WaitSecs('YieldSecs', 1);
        T.realtimings(iTrial,imageryOnset) = currTime - T.startTime;    
    
    
        %% Vividness rating
      
        Reverse = 0;%randi(2)-1; % reverse scale or not?
        if ~Reverse
            message = sprintf('How vivid was your imagery? \n Not vivid \t \t \t \t \t Very vivid');
        elseif Reverse
            message = sprintf('How vivid was your imagery? \n Very vivid \t \t \t \t \t Not vivid');
        end
        
        nTickPress = 0; % number of tick presses
%         KbQueueCreate(deviceIndex, keysOfInterest);
%         KbQueueStart(deviceIndex);
            
        DrawFormattedText(wPtr, message, 'center', P.midY-P.yOffset, [255 255 255], [], [], [], 1.5);        
        % draw horizontal line
        Screen('DrawLines', wPtr, line_Coords, P.lineDiamPix, [255 255 255], [xCenter yCenter]);
        % draw vertical lines, i.e. ticks
        Screen('DrawLines', wPtr, vertLine_allCoords, P.lineDiamPix, [255 255 255], [xCenter yCenter]);

        xOffset = 60 * nTickPress; % x-axis offset value
        yOffset = 0; % y-axis offset value
        % OffsetRect offsets  the passed rect matrix by the horizontal (x) and vertical (y) shift given
        offsetCenteredspotRect = OffsetRect(centeredspotRect, xOffset, yOffset);

        Screen('FillOval', wPtr, [0 0 255], offsetCenteredspotRect);

%         lastFlip = Screen('Flip', wPtr,T.timings(iTrial,confOnset)-slack);
        lastFlip = Screen('Flip', wPtr);
        %WaitSecs('YieldSecs', 1);
        T.realtimings(iTrial,confOnset) = lastFlip - T.startTime;

        startResponse = lastFlip;
        T.trials(iTrial,2) = startResponse - T.startTime;

        nextFlip = lastFlip + 1/P.frameHz; % update every frame
        timeStamp = lastFlip;

%         lateralMovement = 0;
%         prevLoc = 0;
%         firstKeyPress = true;
%         keyPress = false;
%         keyPressStart = 0;
%         keyPressKey = 0;

        B(iTrial,confStartTime) = NaN;
        B(iTrial,confEndTime) = NaN;
        B(iTrial,confReverse) = Reverse;

        
        % Set up the timer.
%         startTime = now;
%         durationInSeconds = P.confDur;
%         numberOfSecondsRemaining = durationInSeconds;
        
%         FlushEvents('KeyDown');
        
      % while numberOfSecondsRemaining > 0
   
        % OR  
        % sca();   % screen close all
        
        while 1 % i.e., until break
            [~,pressed_1] = KbQueueCheck();
            if any(pressed_1(KbName('SPACE'))) % or a list of allowedkeys
                break
            elseif pressed_1(KbName('ESCAPE'))
                sca(); 
                error('Escape key pressed.');
            end  
            WaitSecs('YieldSecs', 0.040);
        end

        while nextFlip < (startResponse + P.confDur)
           while timeStamp < nextFlip - slack
                
            disp(nextFlip)
            disp((startResponse + P.confDur))
            disp(timeStamp)
            disp((nextFlip - slack))
%                 numberOfSecondsElapsed = round((now - startTime) * 10 ^ 5);
%                 numberOfSecondsRemaining = durationInSeconds - numberOfSecondsElapsed;

            % slider offset value
            xOffset = 60 * nTickPress; % x-axis offset value
%                 yOffset = 0; % y-axis offset value
            % OffsetRect offsets  the passed rect matrix by the horizontal (x) and vertical (y) shift given
            offsetCenteredspotRect = OffsetRect(centeredspotRect, xOffset, yOffset);
            % draw slider oval
            Screen('FillOval', wPtr, [0 0 255], offsetCenteredspotRect);
            Screen('Flip', wPtr);

            [ keyIsDown, keyCode ] = KbQueueCheck(deviceIndex);

            if keyIsDown
%                     if keyCode(P.rightKey)
                if strcmp(KbName(keyCode), P.rightKey)
                    if offsetCenteredspotRect(1) < rect(3)/2 - spotRadius
                        nTickPress = nTickPress + 1;
                    end
%                     elseif keyCode(P.leftKey)
                elseif strcmp(KbName(keyCode), P.leftKey)
                    if offsetCenteredspotRect(3) > rect(3)/2 + spotRadius
                        nTickPress = nTickPress + 1;
                    end
%                     elseif keyCode(P.escapeKey)
                elseif strcmp(KbName(keyCode), P.escapeKey)
                    save(fullfile(P.dataPath, [P.subject '.mat'])); % save everything
                    Screen('FillRect', wPtr, P.backgroundColour, rect);
                    DrawFormattedText(wPtr, 'Experiment was aborted!', 'center', 'center', [255 255 255]);
                    Screen('Flip',wPtr);
                    WaitSecs(0.5);
                    ShowCursor;
                    Screen('CloseAll');
                    disp(' ');
                    disp('Experiment aborted by user!');
                    disp(' ');
                    return
                end
            end       
           end
% %             Screen('DrawingFinished', wPtr);
            lastFlip = Screen('Flip', wPtr);
            if abs(lastFlip - nextFlip) >= 1/P.frameHz, flipmisscount = flipmisscount + 1; end
            nextFlip = lastFlip + 1/P.frameHz;   

        end
        B(iTrial,responseConf) = offsetCenteredspotRect(1)/2 + spotRadius - rect(3)/2 + 5;
%         B(iTrial,responseConf) = round(lateralMovement);      

        %% BR Stimulus Presentation
        
        % Present stimulus frame
        Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);

        if P.trialMatrix(iTrial,2) == 99 % Mock trial        

            % draw the red mock grating   
            Screen('DrawTexture',wPtr,redmockTexture,[], CenterRect(stimRect,rect), 135, [], [], P.red*P.redContrast)

            % draw the green mock grating
            Screen('DrawTexture',wPtr,bluemockTexture,[], CenterRect(stimRect,rect), 135, [], [], P.green*P.greenContrast)

        else
            % vary phase of grating for each trial
            % % % = P.phaseVaried(iTrial);
            
            % update parameters
            mypars_red = repmat([P.phase+180, P.freq, P.edge, P.redContrast, P.aspectRatio, 0, 0, 0]', 1, 2);
            mypars_green = repmat([P.phase+180, P.freq, P.edge, P.greenContrast, P.aspectRatio, 0, 0, 0]', 1, 2);
            
            % display gratings
            % red
            Screen('DrawTexture', wPtr, gabortex, [], CenterRect(stimRect,rect), 45, [], [], [1 0 0], [], kPsychDontDoRotation, mypars_red);
            % green
            Screen('DrawTexture', wPtr, gabortex, [], CenterRect(stimRect,rect), 135, [], [], [0 1 0], [], kPsychDontDoRotation, mypars_green);

            % fixation cross
            Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);

            %currTime = Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)-slack);
            currTime = Screen('Flip', wPtr);
            WaitSecs('YieldSecs', 5);
            T.realtimings(iTrial,BRstimOnset) = currTime - T.startTime;
        end
        
        Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);
        %Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)+P.BRstimDur-slack);
        Screen('Flip', wPtr);
        WaitSecs('YieldSecs', 5);
        %% Response
        % Present the response screen

        message = sprintf('Which image did you see most? \n \n Red [J], perfectly mixed [K] or blue [L]');
        DrawFormattedText(wPtr, message, 'center', P.midY-P.yOffset, [255 255 255], [], [], [], 1.5); 
        %currTime = Screen('Flip', wPtr,T.timings(iTrial,responseOnset)-slack);
        currTime = Screen('Flip', wPtr);
        WaitSecs('YieldSecs', 5);
        T.realtimings(iTrial,responseOnset) = currTime - T.startTime;

        % clear keypress
        keyPressed = 0;
        
        % wait for the response
        while GetSecs < (T.timings(iTrial,responseOnset)+ P.responseDur - slack) && ~keyPressed
        
%             KbQueueCreate(deviceIndex, keysOfInterest);
            KbQueueStart(deviceIndex);
            [ keyIsDown, firstPress, keyTime, ~, ~] = KbQueueCheck(deviceIndex);
%             [~, keyTime, keyCode] = KbCheck(-3);
            key = KbName(firstPress);
            
            if ~iscell(key) % only start a keypress if there is only one key being pressed
                if any(strcmp(key, P.keys))
                    
                    response = find(strcmp(key,P.keys));                    
                    
                    % fill in B
                    B(iTrial,trialResponse) = response;
                    B(iTrial,trialRT) = (keyTime-T.startTime) -T.realtimings(iTrial,responseOnset); 
                    
                    % fill in timings
                    T.timings(iTrial,responseOffset) = keyTime; 
                    
                    keyPressed = true;
                    
                    % Send trigger
                    triggerCount = triggerCount + 1;
                    triggerCode = P.triggerResponse+response;
                    triggers(triggerCount,:) = [triggerCode, keyTime-T.startTime];                    
                    
                    
                elseif strcmp(key, 'ESCAPE')
                    
                    Screen('FillRect', wPtr, P.backgroundColour, rect);
                    DrawFormattedText(wPtr, 'Experiment was aborted!', 'center', 'center', [255 255 255]);
                    Screen('Flip',wPtr);
                    WaitSecs(0.5);
                    ShowCursor;
                     
                    Screen('CloseAll');
                    disp(' ');
                    disp('Experiment aborted by user!');
                    disp(' ');
                    save(fullfile(P.dataPath, [P.sessionName '.mat'])); % save everything
                    
                    return
                end
            end
            
            WaitSecs(0.001);
        end
        
        if B(iTrial,trialResponse)==0 % if not in time with key press
            T.timings(iTrial,responseOffset) = T.timings(iTrial,responseOnset)+P.responseDur;
        end

        % show fixation again
        Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);

        % Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
        %currTime = Screen('Flip', wPtr, T.timings(iTrial,responseOffset));
        currTime = Screen('Flip', wPtr);
        WaitSecs('YieldSecs', 5);
        T.realtimings(iTrial,responseOffset) = currTime - T.startTime;
        
        %% Trial end
        T.trialEnd(iTrial) = currTime - T.startTime;

    end % end Trial       
    
    Screen('DrawLines', wPtr, fix_allCoords, P.fixLineWidthPix, [255 255 255], [xCenter yCenter], 2);
    currTime = Screen('Flip', wPtr);
    while (GetSecs - currTime < P.fix - slack)
        WaitSecs(0.001);
    end
    
    %% Save workspace
    save(fullfile(P.dataPath, [P.sessionName '.mat'])); % save everything

    %% Last flip
    T.endTime = Screen('Flip', wPtr);    
    
    %% ---------- Window Cleanup ----------

    % Closes all windows.
    sca;

    % Restores the mouse cursor.
    ShowCursor;
    ListenChar(0);

    disp('Experiment done');
    disp(['Experiment duration: ' num2str([T.endTime]) ' seconds']);

    %% Experiment duration
    exptDuration = T.endTime - T.startTime;
    exptDurMin = floor(exptDuration/60);
    exptDurSec = ceil(mod(exptDuration, 60));
    fprintf('Cycling lasted %d minutes, %d seconds\n', exptDurMin, exptDurSec);
    fprintf(['\nBy my own estimate, Screen(''Flip'') missed the requested screen retrace ', num2str(flipmisscount), ' times\n']);


    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

catch
  % ---------- Error Handling ---------- 
  % If there is an error in our code, we will end up here.
  sca;
  
  ListenChar(0);

  % Restores the mouse cursor.
  ShowCursor;

  % Restore preferences
%   Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%   Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

  % We throw the error again so the user sees the error description.
  psychrethrow(psychlasterror);
end


  
  
