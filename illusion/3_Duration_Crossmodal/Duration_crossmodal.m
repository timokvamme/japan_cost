function Duration_crossmodal(sbj, screen, monitor, key)
%%%%%%
% set fresh rate to 100Hz
%%%%%%
tic 
try
    % use for test
    if nargin < 1
        sbj.id = input('Subject ID: ');
        sbj.name = input('Subject Name: ', 's');
        sbj.exp_type = input('Practice(1) or Main Exp(2)? ');
        sbj.res_path = sprintf('../results/Sub_%s', sbj.id);

        monitor.num = max(Screen('Screens'));
        monitor.resolution = Screen('Resolution', monitor.num);
        monitor.distance = 0.6; % m

        %% Screen Parameters and keys
        Screen('Preference', 'SkipSyncTests', 1);
        [screen.window, screen.rect] = PsychImaging('OpenWindow', monitor.num, 128);
        Screen('BlendFunction', screen.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % 透明需要
        screen.ifi = Screen('GetFlipInterval', screen.window);
        screen.resolution = [screen.rect(3) screen.rect(4)]; % 如果是左右眼分开的话，那就是单眼的分辨率
        % Get the nominal framerate of the monitor (for timer).
        screen.nominalFrameRate = Screen('NominalFrameRate', screen.window);
        %if screen.nominalFrameRate ~= 100
            % error('fresh rate is not 100 !');
        %end
        [w_mm, h_mm] = Screen('DisplaySize', screen.window);
        monitor.size(1) = w_mm / 1000;
        monitor.size(2) = h_mm / 1000;

        % Keys
        KbName('UnifyKeyNames');
        key.start = KbName('SPACE');
        key.esc = KbName('ESCAPE');
        key.resp1 = KbName('1');
        key.resp2 = KbName('2');
        key.next = KbName('n');

        HideCursor;
    end

    filename = sprintf('%s/%s_Duration_crossmodal_%s.mat', sbj.res_path, sbj.id, string(datetime('today', 'Format', 'yyyyMMdd')));

    %% Sound prepare
    fs = 48000;
    player = CHToolbox_SOUND_Initialize(fs);

    [Xc, Yc] = RectCenter(screen.rect);

    %% ExpInfo
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
    auditory.durations = 0.3;
    visual.exp_durations = linspace(0.1, 0.9, 21);

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

    % visual stimulus
    visual.lumin = 200;
    visual.frame_num = round(visual.exp_durations / screen.ifi);
    visual.real_durations = visual.frame_num * screen.ifi;
    visual.size_dva = 5;
    [visual.size_pixel(1), visual.size_pixel(2)] = CHToolbox_BASIC_TransDVA2Pixel(visual.size_dva, monitor, screen);
    visual.rect = [0 0 visual.size_pixel(1) visual.size_pixel(2)];
    visual.rect = CenterRect(visual.rect, screen.rect);

    % auditory stimulus
    auditory.fade_duration = 0.03; % fade in/out
    auditory.amp = 0.5;
    auditory.wgns = containers.Map('KeyType', 'single', 'ValueType', 'any');
    for i = 1: length(auditory.durations)
        auditory.sound_length = ceil(auditory.durations(i)*player.fs);
        auditory.fade_num = ceil(auditory.fade_duration*player.fs);
        wgn_tmp = wgn(1, auditory.sound_length, 0) * auditory.amp;
        % add fade in/out
        wgn_tmp = CHToolbox_SOUND_fade(player.fs, wgn_tmp, auditory.fade_duration);
        auditory.wgns(auditory.durations(i)) = [wgn_tmp; wgn_tmp];
    end
    PsychPortAudio('FillBuffer', player.pahandle, auditory.wgns(auditory.durations));

    %--------------------------
    % shuffle
    A = zeros(Exp.trial_num, 4); % duration, order, selected key(1,2), judge the visual stimulus as longer or not(1, 0)
    A(:, 2) = 1; % auditory stimulus always on the first
    r = randperm(size(A, 1));
    Design = A(r, :);

    %% staircase setup
    marginalize = [];
    AvoidConsecutive = 1;
    WaitTime = 4;
    NumTrials = Exp.trial_num;
    grain = 101;
    PF = @PAL_Logistic;

    stimRange = visual.exp_durations;
    priorAlphaRange = linspace(min(stimRange), max(stimRange), grain);
    priorBetaRange =  linspace(log10(.0625), log10(80), grain);
    priorGammaRange = 0.5; % generating guess rate - ignored becase 'gammaEQlambda' set to 1.
    priorLambdaRange = (0:.01:.1);
    PM = PAL_AMPM_setupPM;
    PM.condition = 'Auditory - Visual match';
    PM.ref_intensity = auditory.durations;
    PM.xlabel = 'Duration of visual stimulus(s)';
    PM.ylabel = 'Proportion of visual stimulus perceived longer';
    %Initialize PM structure (use of single() cuts down on memory load)
    PM = PAL_AMPM_setupPM(PM, 'priorAlphaRange',single(priorAlphaRange),'priorBetaRange',single(priorBetaRange),'priorGammaRange',single(priorGammaRange),'priorLambdaRange',single(priorLambdaRange), 'numtrials',NumTrials, 'PF' , PF,'stimRange',single(stimRange), 'gammaEQlambda', 1, 'marginalize',marginalize);
    
    HideCursor;
    % Screen('FillRect', screen.window, 128);

    %% Welcome/intro text
    textStr = 'This experiment is a DURATION discrimination experiment.\n The task is to judge which stimulus lasted LONGER.\n If the FIRST one is showed LONGER, press the `1` button.\n If the SECOND oen is showed LONGER, press the `2` button.\n Try your best to keep your eyes on the FIXATION at the center of the screen during the experiment.\n Press SPACE key to continue.';
    DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);

    textStr = 'IMPORTANT: Please base your response on your impression of time (how long it felt)\n and avoid using a strategy (for example counting) to solve the task.\n Press SPACE key to continue.';
    DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    WaitSecs(.5);

    %% Formal experiment
    suspend = 0;
    suspend_count = 0;
    k = 1;
    while PM.stop ~= 1
        ord = Design(k, 2);
        the_duration = PM.xCurrent;
        d = find(single(stimRange)==the_duration);

        if mod(k, 40) == 1
            if k == 1
                if sbj.exp_type == 1
                    %% Training
                    textStr = 'Welcome to the training phase. Press SPACE key to start.';    
                else
                    textStr = 'The formal experiment is about to start. Press SPACE key to proceed.';
                end
            else
                textStr = 'You may now take a short break. Press SPACE key to start again.';
            end
            DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc]);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            KbStrokeWait(-1);
            WaitSecs('UntilTime', GetSecs + 1);
        end

        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);

        if ord == 1
            % auditory stimulus
            % Start audio playback for 'repetitions' repetitions of the sound data,
            % start it immediately (0) and wait for the playback to start, return onset
            % timestamp.
            t1 = PsychPortAudio('Start', player.pahandle, 1, 0, 1); % 最后一个1表示等播放开始了再运行后面的
            % Wait for end of playback, then stop:
            PsychPortAudio('Stop', player.pahandle, 1);

            ISI = randi([Exp.ISI(1), Exp.ISI(2)]) / 1000;
            WaitSecs('UntilTime', GetSecs + ISI);

            % visual stimulus
            cf = 1;
            while cf <= visual.frame_num(d)
                Screen('FillOval', screen.window, visual.lumin, visual.rect)
                Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end
        else
            % visual stimulus
            cf = 1;
            while cf <= visual.frame_num(d)
                Screen('FillOval', screen.window, visual.lumin, visual.rect)
                Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end

            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            ISI = randi([Exp.ISI(1), Exp.ISI(2)]) / 1000;
            WaitSecs('UntilTime', GetSecs + ISI);

            % auditory stimulus
            % Start audio playback for 'repetitions' repetitions of the sound data,
            % start it immediately (0) and wait for the playback to start, return onset
            % timestamp.
            t1 = PsychPortAudio('Start', player.pahandle, 1, 0, 1); % 最后一个1表示等播放开始了再运行后面的
            % Wait for end of playback, then stop:
            PsychPortAudio('Stop', player.pahandle, 1);
        end

        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        WaitSecs('UntilTime', GetSecs + 0.5);

        textStr = 'Which stimulus lasted longer? \n (FIRST: press `1`. SECOND: press `2`)';
        DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [],2, [], [0 0 Xc*2 Yc]);
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
    
        % Response
        while true
            [press, press_time, keycode] = KbCheck(-1);
            if press
                if keycode(key.esc)
                    PsychPortAudio('Close');
                    return;
                elseif keycode(key.resp1)
                    the_key = 1;
                    response = 0;
                    break;
                elseif keycode(key.resp2)
                    the_key = 2;
                    response = 1;
                    break;
                end
            end
        end

        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);

        if PM.xCurrent == max(single(stimRange)) && AvoidConsecutive
            suspend = 1;
            suspend_count = suspend_count + 1;
        else
            if suspend_count >= 1
                suspend_count = suspend_count - 1;
            end
        end
        % 如果刺激最大还连续错2次以上，则重复做，不计入次数
        if suspend && suspend_count > 2 && ~response
            WaitSecs('UntilTime', GetSecs + ITI);
            continue;
        end
        % 表示做错了肯定是因为按错了
        if suspend == 1
            suspend = rand(1) > 1./WaitTime;
        end
        PM = PAL_AMPM_updatePM(PM, response, 'fixLapse', suspend);

        Design(k, 1) = the_duration;
        Design(k, 3) = the_key;
        Design(k, 4) = response;
        k = k + 1;

        % ITI
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        ITI = randi([Exp.ITI(1), Exp.ITI(2)]) / 1000;
        WaitSecs('UntilTime', GetSecs + ITI);
    end
    WaitSecs('UntilTime', GetSecs + 0.5);

    %% Save Data
    if sbj.exp_type == 2
        if exist(sbj.res_path, 'dir') == 0
            mkdir(sbj.res_path);
        end
        PMs(1) = CHToolbox_PMF_RemoveNonsenseData(PM);
        data.sbj = sbj;
        data.Design = Design;
        data.PMs = PMs;
        save(filename, 'data', 'monitor', 'screen', 'Exp');
    end
    PsychPortAudio('Close');
catch
    sca;
    PsychPortAudio('Close');
    if exist('Exp', 'var') == 1
        assignin('base', 'Exp', Exp);
    end
    if exist('PMs', 'var') == 1
        assignin('base', 'PMs', PMs);
    end
    if exist('Design', 'var') == 1
        assignin('base', 'Design', Design);
    end
    %Throw the more rect PTB error into the matlab command window. Useful
    %for debugging.
    psychrethrow(psychlasterror);
end
toc
end