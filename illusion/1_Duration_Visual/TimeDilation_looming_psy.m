function TimeDilation_looming_psy(sbj, screen, monitor, key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2020.09.02 fix the duration of target disc, change the duration of reference
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
try
    % use for test
    if nargin < 1
        sbj.id = num2str(input('Subject ID: '));

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
        if screen.nominalFrameRate ~= 100
            error('fresh rate is not 100 !');
        end
        [w_mm, h_mm] = Screen('DisplaySize', screen.window);
        monitor.size(1) = w_mm / 1000;
        monitor.size(2) = h_mm / 1000;

        HideCursor;
    end

    res_path = sprintf('../results/Sub_%s', sbj.id);
    filename = sprintf('%s/%s_TimeDilation_looming_psy.mat', res_path, sbj.id);

    [Xc, Yc] = RectCenter(screen.rect);

    presSecs = sort(repmat(1:3, 1, screen.nominalFrameRate), 'descend');

    pix_per_dva = 0.5*screen.resolution ./ atand(0.5*monitor.size/monitor.distance);
    pix_per_dva = pix_per_dva(2);
    %% Stimulus setup
    % fixation
    % fix_size = 0.12; % degree
    % fix_width = 2; % pixel
    % fix_light_lumin = 0; % cd/cm^2
    % [~, fix_size_pixel] = CHToolbox_BASIC_TransDVA2Pixel(fix_size, monitor, screen);

    fixation.size = 0.12; % degree
    fixation.lumin = 0; % cd/cm^2
    [~, fixation.size_pixel] = CHToolbox_BASIC_TransDVA2Pixel(fixation.size, monitor, screen);
    newm = zeros(fixation.size_pixel,fixation.size_pixel, 4);
    fixation.texture = Screen('MakeTexture', screen.window, uint8(newm));
    fixation.rect = Screen('Rect', fixation.texture);
    [FixCenter(1), FixCenter(2)]=RectCenter(fixation.rect);
    Screen('DrawLine',fixation.texture,fixation.lumin,FixCenter(1)-fixation.size_pixel,FixCenter(2),FixCenter(1)+fixation.size_pixel,FixCenter(2),2);
    Screen('DrawLine',fixation.texture,fixation.lumin,FixCenter(1),FixCenter(2)-fixation.size_pixel,FixCenter(1),FixCenter(2)+fixation.size_pixel,2);
    fixation.rect = CenterRect(fixation.rect, screen.rect);

    interval = 0.5; % s
    target_duration = 0.5; % s

    % reference
    ref_size = 2.0; % degree
    [~, ref_size_pixel] = CHToolbox_BASIC_TransDVA2Pixel(ref_size, monitor, screen);


    % stimulus--------------
    % lumin = 48;
    lumin = 200;

    % target_size = [ref_size, 5.0]; % degree, smallest-largest
    % largest_size_pixel = target_size(2) * pix_per_dva / 2;
    % dva_changed_every_flip = (target_size(2)-target_size(1)) / (stimRange(end)/ifi);
    dva_changed_every_flip = 0.07; % looming para
    pixels_changed_every_flip = dva_changed_every_flip * pix_per_dva / 2;
    sti_center = [Xc, Yc];
    %--------------------------

    %% ExpInfo
    trials_each = 100;
%     trials_each = 50;
%     trials_each = 15;
    A = zeros(trials_each, 5); % size, condition, stimulus order, selected key(left1,right2), judge the target as longer or not(1, 0)
    A(:, 2) = 1; % condition 1, looming
    A(1:ceil(trials_each/2), 3) = 1; % looming stimulus on left or right hemifield
    A(ceil(trials_each/2)+1:end, 3) = 2;

    r = randperm(size(A, 1));
    Design = A(r, :);

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
    NumTrials = trials_each;

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
    stimRange = linspace(0.2, 1, 21);

    priorAlphaRange = linspace(0.2, 1, grain);
    priorBetaRange =  linspace(log10(.0625), log10(80), grain);
    priorGammaRange = 0.5; % generating guess rate - ignored becase 'gammaEQlambda' set to 1.
    priorLambdaRange = (0:.01:.1);

    PM1 = PAL_AMPM_setupPM;
    % PM2 = PAL_AMPM_setupPM;

    PM1.condition = 'Looming Disk';
    PM1.xlabel = 'Duration of static disk (s)';
    PM1.ylabel = 'Proportion of static reference disk perceived longer';
    PM1.ref_intensity = target_duration;

    %Initialize PM structure (use of single() cuts down on memory load)
    PM1 = PAL_AMPM_setupPM(PM1, 'priorAlphaRange',single(priorAlphaRange),...
        'priorBetaRange',single(priorBetaRange),'priorGammaRange',single(priorGammaRange),...
        'priorLambdaRange',single(priorLambdaRange), 'numtrials',NumTrials, 'PF' , PF,...
        'stimRange',single(stimRange), 'gammaEQlambda', 1, 'marginalize',marginalize);

    %% Welcome/intro text
    textStr = 'This experiment is a DURATION discrimination experiment.\n In each trial, you will see two discs successively showed on the center of the screen.\n The task is to judge which one lasted on the screen LONGER.\n If the FIRST disc is showed LONGER, press the `1` button.\n If the SECOND disc is showed LONGER, press the `2` button.\n Try your best to keep your eyes on the FIXATION on the center of the screen during the experiment.\n Note that sometimes, the discs change size during the presentation.\n You should ignore this in your judgment. \n Press SPACE key to continue.';
    DrawFormattedText(screen.window, textStr, 'center', 'center', 255, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    WaitSecs(.5);

    textStr = 'IMPORTANT: Please base your response on your impression of time (how long it felt)\n and avoid using a strategy (for example counting) to solve the task.\n Press SPACE key to continue.';
    DrawFormattedText(screen.window, textStr, 'center', 'center', 255, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
    Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    WaitSecs(.5);

    if sbj.exp_type == 1
        %% Training
        textStr = 'Welcome to the training phase. Press SPACE key to start.';
        DrawFormattedText(screen.window, textStr, 'center', 'center', 255, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
        Screen('Flip', screen.window);
        KbStrokeWait(-1);
    end

    % Timer
    for o = 1:length(presSecs)
        % Convert our current number to display into a string
        numberString = num2str(presSecs(o));
        % Draw our number to the screen
        Screen('FillOval', screen.window, 128, [Xc - 20, Yc - 20, Xc + 20, Yc + 20]);
        DrawFormattedText(screen.window, numberString, 'center', 'center', 255);
        % Flip to the screen
        Screen('Flip', screen.window);
    end
    Screen('Flip', screen.window);

    %% Formal experiment
    suspend1 = 0;
    k = 1;
    skip = false; % skip this phase
    while PM1.stop ~= 1
        if skip
            break;
        end
        first_size = ref_size_pixel;
        second_size = ref_size_pixel;
        
        condition = Design(k, 2);
        ord = Design(k, 3);
        if condition == 1
            ref_duration = PM1.xCurrent;
        end

        % for controlling the inluence of stimuli size, half time small than ref, half time larger than ref
        target_half_looming_size_pixel = double(pixels_changed_every_flip * ceil(target_duration/screen.ifi/2));
        if ord == 1
            first_duration = target_duration;
            second_duration = ref_duration;
            if condition == 1
                % init the size of first stimulus
                first_size = ref_size_pixel - target_half_looming_size_pixel;
            end
        else
            first_duration = ref_duration;
            second_duration = target_duration;
            if condition == 1
                second_size = ref_size_pixel - target_half_looming_size_pixel;
            end
        end

        % rest every 70 trials
        if mod(k, 70)==1 && k~=1
            textStr = 'You may now take a short break. Press SPACE key to start again.';
            DrawFormattedText(screen.window, textStr, 'center', 'center', 255, [], [], [], 2, [], [0 0 Xc*2 Yc ]);
            Screen('Flip', screen.window);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            KbStrokeWait(-1);
            WaitSecs(2);
        end

        % first Stimulus
        cf = 1;
        while cf < ceil(first_duration/screen.ifi)
            Screen('FillOval', screen.window, lumin, [sti_center(1)-first_size, sti_center(2)-first_size, sti_center(1)+first_size, sti_center(2)+first_size]);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            if ord == 1
                if condition == 1
                    first_size = first_size + pixels_changed_every_flip;
                end
            end
            cf = cf + 1;
        end

        % SOA
        cf = 1;
        while cf < ceil(interval/screen.ifi)
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            cf = cf + 1;
        end

        % second Stimulus
        cf = 1;
        while cf < ceil(second_duration/screen.ifi)
            Screen('FillOval', screen.window, lumin, [sti_center(1)-second_size, sti_center(2)-second_size, sti_center(1)+second_size, sti_center(2)+second_size]);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            if ord == 2
                if condition == 1
                    second_size = second_size + pixels_changed_every_flip;
                end
            end
            cf = cf + 1;
        end
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        WaitSecs(.2);

        textStr = 'Which disc was showed longer? \n (FIRST disc: `1`. SECOND disc: `2`)';
        DrawFormattedText(screen.window, textStr, 'center', 'center', 255, [], [], [],2, [], [0 0 Xc*2 Yc]);
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        % Response
        while true
            [press, ~, keycode] = KbCheck(-1);
            if press
                if keycode(key.esc)
                    return;
                elseif keycode(key.resp1)
                    the_key = 1;
                    % if reference is selected, then response=1
                    if ord == 1
                        response = 0;
                    else
                        response = 1;
                    end
                    break;
                elseif keycode(key.resp2)
                    the_key = 2;
                    if ord == 2
                        response = 0;
                    else
                        response = 1;
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
        Design(k, 1) = ref_duration;
        Design(k, 3) = the_key; % judge the target was longer or not
        Design(k, 4) = response;
        % Blank
        cf = 1;
        while cf < ceil(0.8/screen.ifi)
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            cf = cf + 1;
        end
        k = k + 1;
    end
    %% Save Data
    data.sbj = sbj;
    PMs(1) = CHToolbox_PMF_RemoveNonsenseData(PM1);
    data.Design = Design;
    data.PMs = PMs;
    save(filename, 'data');
catch
    sca;
    if exist('Design', 'var') == 1
        assignin('base', 'Design', Design);
    end
    %Throw the more rect PTB error into the matlab command window. Useful
    %for debugging.
    psychrethrow(psychlasterror);
end
toc
end