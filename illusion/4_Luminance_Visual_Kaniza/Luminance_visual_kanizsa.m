function Luminance_visual_kanizsa(sbj, screen, monitor, key)
tic
try
    %% Setup some basic psychotoolbox settings.
    
    %If no arguments are provided, assume work station setup. These values are
    %only for scripting purposes and should never be assumed to apply to your
    %experimental setup.
    if nargin < 1
        sbj.id = num2str(input('Subject ID: '));
        sbj.name = input('Subject Name: ', 's');
        sbj.exp_type = input('Practice(1) or Main Exp(2)? ');
        sbj.res_path = sprintf('../results/Sub_%s', sbj.id);

        % !!need to modify if use new device
        monitor.num = max(Screen('Screens'));
        monitor.resolution = Screen('Resolution', monitor.num);
        monitor.distance = 60; %cm

        %% Screen Parameters and keys
        Screen('Preference', 'SkipSyncTests', 0);
        [screen.window, screen.rect] = PsychImaging('OpenWindow', monitor.num, 0);
        Screen('BlendFunction', screen.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % 透明�?�?
        screen.ifi = Screen('GetFlipInterval', screen.window);
        screen.resolution = [screen.rect(3) screen.rect(4)]; % 如果是左右眼分开的话，那就是单眼的分辨率
        % Get the nominal framerate of the monitor (for timer).
        screen.nominalFrameRate = Screen('NominalFrameRate', screen.window);
        %if screen.nominalFrameRate ~= 100
        %    error('fresh rate is not 100 !');
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
    grey = 128;

    filename = sprintf('%s/%s_Luminance_visual_kanizsa_%s.mat', sbj.res_path, sbj.id, string(datetime('today', 'Format', 'yyyyMMdd')));

    % Screen('FillRect', screen.window, 255);

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
    Exp.ISI = 0.2; % S
    Exp.ITI = 0.5; % s

    text_color = 255;

    A = zeros(Exp.trial_num, 5); % size, condition, stimulus order, selected key(left1,right2), judge the target as longer or not(1, 0)
    A(:, 2) = 1; % condition 1, kanizsa
    A(1:ceil(Exp.trial_num/2), 3) = 1; % target stimulus on left or right hemifield
    A(ceil(Exp.trial_num/2)+1:end, 3) = 2;
    B = A;
    B(:, 2) = 2; % condition 2, control
    all = [A; B];
    r = randperm(size(all, 1));
    Design = all(r, :);
    
    % Get the centre coordinate of the window e.g. xc = 960, yc = 540.
    [Xc, Yc] = RectCenter(screen.rect);
    
    %% BUILD STIMULI 
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

    sIntensity = 40; % base on this intensity

    stimulus.size_dva = 4; % degree
    stimulus.duration = 0.3; % s
    stimulus.ref_intensity = grey + sIntensity;
    [stimulus.size_pixel(1), stimulus.size_pixel(2)] = CHToolbox_BASIC_TransDVA2Pixel(stimulus.size_dva, monitor, screen);
    stimulus.rect = [0 0 stimulus.size_pixel(1) stimulus.size_pixel(2)];
    stimulus.rect = CenterRect(stimulus.rect, screen.rect);
    
    inducer.size_dva = stimulus.size_dva / 2.5;
    [~, inducer.size_pixel] = CHToolbox_BASIC_TransDVA2Pixel(inducer.size_dva, monitor, screen);
    
    inducer.circles(:,1) = [stimulus.rect(1)-inducer.size_pixel stimulus.rect(2)-inducer.size_pixel stimulus.rect(1) + inducer.size_pixel stimulus.rect(2) + inducer.size_pixel];
    inducer.circles(:,2) = [stimulus.rect(3)-inducer.size_pixel stimulus.rect(4)-inducer.size_pixel stimulus.rect(3) + inducer.size_pixel stimulus.rect(4) + inducer.size_pixel];
    inducer.circles(:,3) = [stimulus.rect(1)-inducer.size_pixel stimulus.rect(4)-inducer.size_pixel stimulus.rect(1) + inducer.size_pixel stimulus.rect(4) + inducer.size_pixel];
    inducer.circles(:,4) = [stimulus.rect(3)-inducer.size_pixel stimulus.rect(2)-inducer.size_pixel stimulus.rect(3) + inducer.size_pixel stimulus.rect(2) + inducer.size_pixel];
    
    %% STAIRCASE SETUP
    
    %Original PSI, PSI+ or PSI-MARGINAL?
    marginalize = [];
    
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
    
    % plotGrain = 201; %Allow higher resolution for visualization compared to what Psi-marginal works with
    computeGrain = 101;
    
    suspend = 0;
    % trackSuspend = zeros(1,NumTrials);
    
    % PF = @PAL_Gumbel;
    % PF = @PAL_Weibull;
    PF = @PAL_Logistic;
    % PF = @PAL_HyperbolicSecant;
    % PF = @PAL_Quick;
    % PF = @PAL_logQuick;
    %     PF = @PAL_CumulativeNormal;
    % paramsGen = [0 1 gamma lambda];
    
    %Stimulus values the method can select from
    %     stimRange = linspace(1,2*sIntensity, 21);
    %      stimRange = logspace(-0.3, 0.3, 31)*sIntensity;
    % stimRange = logspace(-1, 0.37, 21)*sIntensity;
    stimRange = linspace(-.7, 0.37, 21);
    
    % priorAlphaRange =  logspace(-1, 0.37, computeGrain)*sIntensity;
    priorAlphaRange =  linspace(-.7, 0.37, computeGrain);
    %     priorBetaRange =  logspace(-1.5, 3, computeGrain);
    priorBetaRange =  linspace(log10(.0625),log10(80),computeGrain);
    priorGammaRange = 0; %generating guess rate - ignored becase 'gammaEQlambda' set to 1.
    priorLambdaRange = (0:.01:.1);

    
    PM1 = PAL_AMPM_setupPM('priorAlphaRange',double(priorAlphaRange),...1
        'priorBetaRange',double(priorBetaRange),'priorGammaRange',double(priorGammaRange),...
        'priorLambdaRange',single(priorLambdaRange), 'numtrials',NumTrials, 'PF' , PF,...
        'stimRange',double(stimRange),'marginalize',marginalize, 'gammaEQlambda', 1);
    
    PM2 = PAL_AMPM_setupPM('priorAlphaRange',double(priorAlphaRange),...
        'priorBetaRange',double(priorBetaRange),'priorGammaRange',double(priorGammaRange),...
        'priorLambdaRange',double(priorLambdaRange), 'numtrials',NumTrials, 'PF' , PF,...
        'stimRange',double(stimRange),'marginalize',marginalize, 'gammaEQlambda', 1);

    PM1.sIntensity = sIntensity;
    PM1.ref_intensity = 0; % log10(1)=0
    PM1.method = marginalize;
    PM1.PF = PF;
    PM1.condition = 'Kanizsa illusion';
    PM1.xlabel = 'Relative intensity of reference stimulus (log)';
    PM1.ylabel = 'Proportion of reference stimulus perceived brighter';
    
    PM2.sIntensity = sIntensity;
    PM2.ref_intensity = 0; % log10(1)=0
    PM2.method = marginalize;
    PM2.PF = PF;
    PM2.condition = 'Control';
    PM2.xlabel = 'Relative intensity of reference stimulus (log)';
    PM2.ylabel = 'Proportion of reference stimulus perceived brighter';
        
    %% WELCOME TEXT
    textStr = ['In this experiment, your task is to evaluate \n' ...
    'which of the two rectangles is the brightest. \n Press `1` if it was the first or ' ...
    '`2` if it was the second. \n There are objects around the rectangles - ignore these in your decision. \n Before the actual experiment starts, there will be a training round. \n Press SPACE key to proceed.'];
    DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbPressWait;
    
    %% EXPERIMENT LOOP
    suspend1 = 0;
    suspend2 = 0;
    suspend_count1 = 0;
    suspend_count2 = 0;
    k = 1;
    while PM1.stop~=1 || PM2.stop~=1
        condition = Design(k, 2);
        ord = Design(k, 3);
        if condition == 1
            it = 10.^PM1.xCurrent * sIntensity;
        elseif condition == 2
            it = 10.^PM2.xCurrent * sIntensity;
        end
        target_intensity = grey + it;

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
        
        if ord == 1
            % first stimulus (target stimulus)
            cf = 1;
            while cf <= ceil(stimulus.duration/screen.ifi)
                if condition == 1 % kanizsa
                    % draw inducer
                    Screen('FillOval', screen.window, [0 0 0], inducer.circles);
                end
                Screen('FillRect', screen.window, stimulus.ref_intensity, stimulus.rect);
                % Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end
            
            % ISI
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            WaitSecs('UntilTime', GetSecs + Exp.ISI);

            % second stimulus
            cf = 1;
            while cf <= ceil(stimulus.duration/screen.ifi)
                Screen('FillRect', screen.window, target_intensity, stimulus.rect);
                % Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end
        else
            % first stimulus (test stimulus)
            cf = 1;
            while cf <= ceil(stimulus.duration/screen.ifi)
                Screen('FillRect', screen.window, target_intensity, stimulus.rect);
                % Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end

            % ISI
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            WaitSecs('UntilTime', GetSecs + Exp.ISI);

            % second stimulus
            cf = 1;
            while cf <= ceil(stimulus.duration/screen.ifi)
                if condition == 1 % kanizsa
                    % draw inducer
                    Screen('FillOval', screen.window, [0 0 0], inducer.circles);
                end
                Screen('FillRect', screen.window, stimulus.ref_intensity, stimulus.rect);
                % Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end
        end

        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        WaitSecs('UntilTime', GetSecs + 0.2);

        textStr = 'Was the first or the second rectangle brightest? \n First: `1`. Second: `2`.';
        DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [],2, [], [0 0 Xc*2 Yc]);
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);

        % response
        while true
            [press, press_time, keycode] = KbCheck(-1);
            if press
                if keycode(key.esc)
                    return;
                elseif keycode(key.resp1)
                    the_key = 1;
                    if ord == 1
                        response = 0;
                    else
                        response = 1;
                    end
                    break;
                elseif keycode(key.resp2)
                    the_key = 2;
                    if ord == 1
                        response = 1;
                    else
                        response = 0;
                    end
                    break;
                end
            end
        end

        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);

        % update
        if condition == 1
            if PM1.xCurrent == max(single(stimRange)) && AvoidConsecutive
                suspend1 = 1;
                suspend_count1 = suspend_count1 + 1;
            else
                if suspend_count1 >= 1
                    suspend_count1 = suspend_count1 - 1;
                end
            end
            % 如果刺激最大还连续错2次以上，则重复做，不计入次数
            if suspend1 && suspend_count1 > 2 && ~response
                WaitSecs('UntilTime', GetSecs + ITI);
                continue;
            end
            if suspend1 == 1
                suspend1 = rand(1) > 1./WaitTime;
            end
            PM1 = PAL_AMPM_updatePM(PM1, response, 'fixLapse', suspend1);
        elseif condition == 2
            if PM2.xCurrent == max(single(stimRange)) && AvoidConsecutive
                suspend2 = 1;
                suspend_count2 = suspend_count2 + 1;
            else
                if suspend_count2 >= 1
                    suspend_count2 = suspend_count2 - 1;
                end
            end
            % 如果刺激最大还连续错2次以上，则重复做，不计入次数
            if suspend2 && suspend_count2 > 2 && ~response
                WaitSecs('UntilTime', GetSecs + ITI);
                continue;
            end
            if suspend2 == 1
                suspend2 = rand(1) > 1./WaitTime;
            end
            PM2 = PAL_AMPM_updatePM(PM2, response, 'fixLapse', suspend2);
        end
        Design(k, 1) = it;
        Design(k, 4) = the_key; % judge the target was longer or ot
        Design(k, 5) = response;
        k = k + 1;

        % ITI
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        WaitSecs('UntilTime', GetSecs + Exp.ITI);
    end
    WaitSecs('UntilTime', GetSecs + 0.5);

    %% Save Data
    if sbj.exp_type == 2
        if exist(sbj.res_path, 'dir') == 0
            mkdir(sbj.res_path);
        end
        PMs(1) = CHToolbox_PMF_RemoveNonsenseData(PM1);
        PMs(2) = CHToolbox_PMF_RemoveNonsenseData(PM2);
        data.sbj = sbj;
        data.Design = Design;
        data.PMs = PMs;
        save(filename, 'data', 'monitor', 'screen', 'stimulus');
    end
catch
    sca;
    %Force close all PTB windows.
    fclose('all');
    
    if exist('PMS', 'var') == 1
        assignin('base', 'PM1', PM1);
        assignin('base', 'PM2', PM2);
    end   
    WaitSecs(.5);
        
    %Throw the more rect PTB error into the matlab command window. Useful
    %for debugging.
    psychrethrow(psychlasterror);
end
toc
end