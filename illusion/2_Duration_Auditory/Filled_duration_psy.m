function Filled_duration_psy(sbj, screen, monitor, key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2020.09.03 fix filled, change empty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
try
    % use for test
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
        screen.ifi = Screen('GetFlipInterval', screen.window);
        screen.resolution = [screen.rect(3) screen.rect(4)]; % 如果是左右眼分开的话，那就是单眼的分辨率
        % Get the nominal framerate of the monitor (for timer).
        screen.nominalFrameRate = Screen('NominalFrameRate', screen.window);
        %if screen.nominalFrameRate ~= 100
        %    error('fresh rate is not 100 !');
        %end
        [w_mm, h_mm] = Screen('DisplaySize', screen.window);
        monitor.size(1) = w_mm / 10;
        monitor.size(2) = h_mm / 10;

        % Keys
        KbName('UnifyKeyNames');
        key.start = KbName('SPACE');
        key.esc = KbName('ESCAPE');
        key.resp1 = KbName('1');
        key.resp2 = KbName('2');
        key.next = KbName('n');

        HideCursor;
    end

    filename = sprintf('%s/%s_Filled_duration_psy_%s.mat', sbj.res_path, sbj.id, string(datetime('today', 'Format', 'yyyyMMdd')));

    [Xc, Yc] = RectCenter(screen.rect);
    % Get the nominal framerate of the monitor (for timer).
    presSecs = sort(repmat(1:3, 1, screen.nominalFrameRate*0.5), 'descend');

    %% Sound prepare
    fs = 48000;
    player = CHToolbox_SOUND_Initialize(fs);

    Exp.ISI = [500, 1000]; % ms
    Exp.ITI = [500, 1000]; % ms
    if strcmp(sbj.id, '9999')
        if sbj.exp_type == 1
            Exp.trial_num = 10;
        else
            Exp.trial_num = 30;
        end
    else
        if sbj.exp_type == 1
            Exp.trial_num = 30;
        else
            Exp.trial_num = 80;
        end
    end

    text_color = 255;

    %% Stimulus setup
    
    % fixation
    fixation.size = 0.12; % degree
    fixation.lumin = 0; % cd/cm^2
    [~, fixation.size_pixel] = CHToolbox_BASIC_TransDVA2Pixel(fixation.size, monitor, screen);
    newm = zeros(fixation.size_pixel,fixation.size_pixel,4);
    fixation.texture = Screen('MakeTexture', screen.window, uint8(newm));
    fixation.rect = Screen('Rect', fixation.texture);
    [FixCenter(1), FixCenter(2)]=RectCenter(fixation.rect);
    Screen('DrawLine',fixation.texture,fixation.lumin,FixCenter(1)-fixation.size_pixel,FixCenter(2),FixCenter(1)+fixation.size_pixel,FixCenter(2),2);
    Screen('DrawLine',fixation.texture,fixation.lumin,FixCenter(1),FixCenter(2)-fixation.size_pixel,FixCenter(1),FixCenter(2)+fixation.size_pixel,2);
    fixation.rect = CenterRect(fixation.rect, screen.rect);

    % reference
    % ref_duration = 0.9; % s
    Exp.filled_duration = 0.6;
    Exp.empty_durations = linspace(0.4, 1.3, 21);
    %--------------------------

    %% ExpInfo
    Exp.ISI = [500, 1000]; % ms
    Exp.ITI = [500, 1000]; % ms

    A = zeros(Exp.trial_num, 5); % duration, condition, stimulus order, selected key(left1,right2), judge the reference as longer or not(1, 0)
    A(:, 2) = 1; % condition 1, filled
    A(1:ceil(Exp.trial_num/2), 3) = 1; % reference stimulus firstly or secondly to show
    A(ceil(Exp.trial_num/2)+1:end, 3) = 2;
    % B = A;
    % B(:, 2) = 2; % condition 2, control

    % all = [A; B];
    all = A;

    r = randperm(size(all, 1));
    Design = all(r, :);

    %% staircase setup
    marginalize = [4];

    % Lengthy consecutive placements at high intensities may be avoided,
    % by temporarily using a fixed lapse rate (as in original Psi-method)
    % after a high intensity trial. Do this?
    AvoidConsecutive = 1;

    % After a high intensity trial, the method will assume a fixed
    % lapse rate for a random number of trials. This wait time
    % will be drawn from an exponential mass function in order to
    % maintain constant "hazard". Enter average wait time (in number of
    % trials), e.g., 4.
    WaitTime = 4;

    % Number of trials.
    NumTrials = Exp.trial_num;

    grain = 101;

    % PF = @PAL_Gumbel;
    % PF = @PAL_Weibull;
    PF = @PAL_Logistic;
    % PF = @PAL_HyperbolicSecant;
    % PF = @PAL_Quick;
    % PF = @PAL_logQuick;
    % PF = @PAL_CumulativeNormal;
    % paramsGen = [0 1 gamma lambda];

    %Stimulus values the method can select from
    stimRange = Exp.empty_durations;

    priorAlphaRange = linspace(min(stimRange), max(stimRange), grain);
    priorBetaRange =  linspace(log10(.0625), log10(80), grain);
    priorGammaRange = 0.5; % generating guess rate - ignored becase 'gammaEQlambda' set to 1.
    priorLambdaRange = (0:.01:.1);

    PM1 = PAL_AMPM_setupPM;
    % PM2 = PAL_AMPM_setupPM;

    PM1.condition = 'Filled Duration';
    PM1.ref_intensity = Exp.filled_duration;
    PM1.xlabel = 'Duration of empty interval (s)';
    PM1.ylabel = 'Proportion of empty interval perceived longer';

    %Initialize PM structure (use of single() cuts down on memory load)
    PM1 = PAL_AMPM_setupPM(PM1, 'priorAlphaRange',single(priorAlphaRange),...
        'priorBetaRange',single(priorBetaRange),'priorGammaRange',single(priorGammaRange),...
        'priorLambdaRange',single(priorLambdaRange), 'numtrials',NumTrials, 'PF' , PF,...
        'stimRange',single(stimRange), 'gammaEQlambda', 1, 'marginalize',marginalize);

    %% Welcome/intro text
    textStr = 'This experiment is a DURATION discrimination experiment.\n In each trial, you will hear two sonic stimuli in turn.\n One is continuous tone and another is presented by two clicks.\n The task is to judge whether the duration of the continuous tone is longer,\n or the interval between two clicks is longer.\n Press SPACE key to continue.';
    DrawFormattedText(screen.window, textStr, 'center', 'center', 255, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);

    textStr = 'IMPORTANT: Please base your response on your impression of time (how long it felt)\n and avoid using a strategy (for example counting) to solve the task.\n Press SPACE key to continue.';
    DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    WaitSecs(.5);
    
    if sbj.exp_type == 1
        %% Training
        textStr = 'Welcome to the training phase. Press SPACE key to start.';    
    else
        textStr = 'The formal experiment is about to start. Press SPACE key to proceed.';
    end
    DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    WaitSecs(.5);

    %% Formal experiment
    suspend1 = 0;
    k = 1;
    skip = false; % skip this phase
    while ~PM1.stop
        if skip
            break;
        end
    
        condition = Design(k, 2);
        ord = Design(k, 3);
        if condition == 1
            % fix filled duration, variate empty duration
            empty_duration = PM1.xCurrent;
        end

        % rest every 30 trials
        if mod(k, 40)==1 && k~=1
            textStr = 'Now you may take a short break. Press SPACE key to start again.';
            DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            KbStrokeWait(-1);
            WaitSecs(2);
        end

        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        if condition == 1
            if ord == 1
                generateEmpty(empty_duration, player);
                ISI = randi([Exp.ISI(1), Exp.ISI(2)]) / 1000;
                WaitSecs('UntilTime', GetSecs + ISI);
                generateFilled(Exp.filled_duration, player);
            else
                generateFilled(Exp.filled_duration, player);
                ISI = randi([Exp.ISI(1), Exp.ISI(2)]) / 1000;
                WaitSecs('UntilTime', GetSecs + ISI);
                generateEmpty(empty_duration, player);
            end
        end
        WaitSecs(0.3);

        textStr = 'Which one lasts longer? \n (FIRST one: `1`. SECOND one: `2`)';
        DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [],2, [], [0 0 Xc*2 Yc]);
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        % Response
        while true
            [press, ~, keycode] = KbCheck(-1);
            if press
                if keycode(key.esc)
                    PsychPortAudio('Close');
                    return;
                elseif keycode(key.resp1)
                    the_key = 1;
                    % if empty is selected, then response=1
                    if ord == 1
                        response = 1;
                    else
                        response = 0;
                    end
                    break;
                elseif keycode(key.resp2)
                    the_key = 2;
                    if ord == 2
                        response = 1;
                    else
                        response = 0;
                    end
                    break;
                elseif keycode(KbName('s'))
                    skip = true;
                    break;
                end
            end
        end
        % update
        if condition == 1
            % evaluates the response and updates the staircase struct.
            %Decide whether to suspend psi-marginal temporarily. Strategy effectively
            %draws WaitTime from exponential mass function resulting in constant
            %'hazard' (i.e., when in suspended mode, there is a constant probability
            %(equal to 1/WaitTime) of returning to psi-marginal mode on each trial).
            if PM1.xCurrent == max(single(stimRange)) && AvoidConsecutive
                suspend1 = 1;
            end
            if suspend1 == 1
                suspend1 = rand(1) > 1./WaitTime;
            end
            PM1 = PAL_AMPM_updatePM(PM1, response, 'fixLapse', suspend1);
        end
        Design(k, 1) = empty_duration;
        Design(k, 4) = the_key; % judge the target was longer or not
        Design(k, 5) = response;
        % Blank
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        ITI = randi([Exp.ITI(1), Exp.ITI(2)]) / 1000;
        WaitSecs('UntilTime', GetSecs + ITI);

        k = k + 1;
    end
    WaitSecs('UntilTime', GetSecs + 0.5);

    %% Save Data
    if sbj.exp_type == 2
        if exist(sbj.res_path, 'dir') == 0
            mkdir(sbj.res_path);
        end
        data.sbj = sbj;
        PMs(1) = CHToolbox_PMF_RemoveNonsenseData(PM1);
        data.Design = Design;
        data.PMs = PMs;
        save(filename, 'data', 'monitor', 'screen', 'Exp');
    end
    PsychPortAudio('Close');
catch
    sca;
    PsychPortAudio('Close');
    if exist('Design', 'var') == 1
        assignin('base', 'Design', Design);
    end
    if exist('data', 'var') == 1
        assignin('base', 'data', data);
    end
    %Throw the more rect PTB error into the matlab command window. Useful
    %for debugging.
    psychrethrow(psychlasterror);
end
toc
end