function Duration_visual(sbj, screen, monitor, key)
%%%%%%
% set fresh rate to 100Hz
%%%%%%
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
        Screen('BlendFunction', screen.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % 透明�?�?
        screen.ifi = Screen('GetFlipInterval', screen.window);
        screen.resolution = [screen.rect(3) screen.rect(4)]; % 如果是左右眼分开的话，那就是单眼的分辨率
        % Get the nominal framerate of the monitor (for timer).
        screen.nominalFrameRate = Screen('NominalFrameRate', screen.window);

        sprintf("%s",screen.nominalFrameRate)
        %if screen.nominalFrameRate ~= 60
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

    % check if the installed Psychtoolbox is based on OpenGL
    global GL;
    AssertOpenGL;
    InitializeMatlabOpenGL;

    filename = sprintf('%s/%s_Duration_visual_%s.mat', sbj.res_path, sbj.id, string(datetime('today', 'Format', 'yyyyMMdd')));
    [Xc, Yc] = RectCenter(screen.rect);

    %--------------------------
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
            Exp.trial_num = 100;
        end
    end

    text_color = 255;

    % shuffle
    A = zeros(Exp.trial_num, 6); % duration, condition, order, position(left or right), selected key(1,2), judge the static stimulus as longer or not(1, 0)
    A(:, 2) = 1; % condition 1, looming
    A(1:ceil(Exp.trial_num/2), 3) = 1; % looming stimulus on first or second
    A(ceil(Exp.trial_num/2)+1:end, 3) = 2;
    A(1:ceil(Exp.trial_num/2), 4) = 1; % looming stimulus at left 
    A(ceil(Exp.trial_num/2)+1:end, 4) = 1;
    all = A;
    r = randperm(size(all, 1));
    Design = all(r, :);

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

    stimulus.lumin = 200;
    
    %% background
    scaleFac = 0.75;
    margin = 0.25;
    
    % align front, back, left, right side with CRT
    grid.LowerBound = -0.455/scaleFac;
    grid.UpperBound = 0.455/scaleFac;
    % grid.LeftBound = -0.606/scaleFac;
    % grid.RightBound = 0.606/scaleFac;
    grid.LeftBound = -0.906/scaleFac;
    grid.RightBound = 0.906/scaleFac;
    % grid.FrontBound = 0.35*-3.25/scaleFac;
    % grid.BackBound = 0.45*-6.75/scaleFac;
    grid.FrontBound = 0.05*-3.25/scaleFac;
    grid.BackBound = 0.95*-6.75/scaleFac;

    upleftgrid = grid; lowleftgrid = grid; uprightgrid = grid; lowrightgrid = grid;
    upleftgrid.LowerBound = grid.UpperBound*(1-margin);
    upleftgrid.RightBound = grid.LeftBound*(1-margin);
    lowleftgrid.UpperBound = grid.LowerBound*(1-margin);
    lowleftgrid.RightBound = grid.LeftBound*(1-margin);
    uprightgrid.LowerBound = grid.UpperBound*(1-margin);
    uprightgrid.LeftBound = grid.RightBound*(1-margin);
    lowrightgrid.UpperBound = grid.LowerBound*(1-margin);
    lowrightgrid.LeftBound = grid.RightBound*(1-margin);
    
    upfaceTexs = fliplr([ 1 2 6 5 ]);
    lowfaceTexs = fliplr([ 3 4 8 7 ]);
    rightfaceTexs = fliplr([ 2 3 7 6 ]);
    leftfaceTexs = fliplr([ 4 1 5 8 ]);
    epx = 0.15;
    epy = 0.28;
    
    % static stimulus
    static.exp_durations = linspace(0.3, 1, 21);
    static.frame_num = round(static.exp_durations / screen.ifi);
    static.real_durations = static.frame_num * screen.ifi;

    % looming
    looming.exp_durations = 0.5;
    looming.frame_num = round(looming.exp_durations * screen.nominalFrameRate);
    looming.real_durations = looming.frame_num * screen.ifi;

    %% setting ball texture and moving trajectory  
    % texture on ball
    bv = zeros(8);
    wv = ones(8);
    ballimg = double(repmat([bv wv; wv bv],7,4) > 0.5) * 255; % black white checkerboard
    ballimg = repmat(ballimg,[1 1 3]); % 3 color channels (RGB)
    ballimg(:,:,3) = 0;
    balltex = Screen('MakeTexture', screen.window, uint8(ballimg), [], 1); % ?specialFlags? is set to 1
    
    % ball size
    ballSize = 0.1; % radius in meter at the end point
    slices = 100;
    stacks = 100;
    % moving speed
    BallSpeed = 48;
    
    % set up moving trajectory
    hit_x_sets = [0]; % hit (0cm), miss (10cm)
    % positions = [-1, 1]; % left (-1), right (+1)
    positions = [0]; % left (-1), right (+1)
    for d = 1:length(looming.exp_durations) % duration
        for hx = 1:length(hit_x_sets) % hit, miss
            for pos = 1:length(positions) % left, right
                the_duration = looming.exp_durations(d);
                frame_num = looming.frame_num(d);               
                hitx = hit_x_sets(hx) * positions(pos);

                % align endpoint (same x, y, z) acorss hit/miss and duration conditions
                endx = 0.2 * positions(pos); %0.18*directset(movedir);
                endz = -1 * (2 - monitor.distance); % 2 meter away             
                % startpoint
                startz = -1 * (abs(endz) + abs(the_duration .* BallSpeed));               
                % hitpoint (subject's position)
                hitz = monitor.distance;         
                % find startx
                startx = (endz-startz) / (hitz-endz) * (endx-hitx) + endx;      
                % find dx, dz
                dx = (endx - startx) / frame_num;
                dz = (endz - startz) / frame_num;         
                % save parameters
                newx1(d, hx, pos) = startx;
                newdx(d, hx, pos) = dx;
                newz1(d, hx, pos) = startz;
                newdz(d, hx, pos) = dz;
                newtraceY(d, hx, pos) = 0;
            end
        end
    end
    
    % ball size in degree
    startPointZset = -1 * (looming.exp_durations .* BallSpeed) + endz;
    ballInRetinoStart = atand(ballSize./(abs(startPointZset)+hitz)); % ball size in start point (degree)
    ballInRetinoEnd = atand(ballSize./(abs(endz)+hitz)); % ball size in start point (degree)
    for j = 1:length(startPointZset)
        clear temp;
        for  i = 1:looming.frame_num(j)
            newZset = startPointZset(j) + i*BallSpeed*screen.ifi;
            temp(i,1) = atand(ballSize./(abs(newZset)+hitz));
            ballInRetino(i,j) = atand(ballSize./(abs(newZset)+hitz)); % ball size in start point (degree)
        end
        ballavg(1,j) = mean(temp); % average size for each duration condition (7 levels) 
    end
    ballavgall = mean(ballavg); % grand mean of ball size 
    ballavgsize = tand(ballavgall) * (abs(endz)+hitz)/2;
    % ballavgsize = ballSize;
%     ballavgsize = 0.04;

    %% ---------Start OpenGL: ball--------
    Screen('BeginOpenGL', screen.window);
    glEnable(GL.TEXTURE_2D); % Enable 2D texture mapping
    
    % Generate 8 textures and store their handles (background texture)
    wall_contrastindex = 0.6;
    wall_color = 150; 
    random_size_x = 32;
    random_size_y = 4;
    random_size_z = 128;
    random_resample_time = 8;
    Rx = random_size_x*random_resample_time;
    Ry = random_size_y*random_resample_time;
    Rz = random_size_z*random_resample_time;
    
    texname=glGenTextures(8);
    for i=1:8   % upper;lower;right;left
        if i <= 4
            random_size_width = random_size_x;
            Rwidth = Rx;
        else
            random_size_width = random_size_y;
            Rwidth = Ry;
        end
        % Enable i'th texture by binding it:
        glBindTexture(GL.TEXTURE_2D,texname(i));
        
        % Compute random pattern in matlab matrix 'random_pattern_square'  
        random_pattern_square = (1-wall_contrastindex+wall_contrastindex*rand(random_size_z, random_size_width))*wall_color; 
        random_pattern_square = resample(random_pattern_square,random_resample_time,1,0);
        random_pattern_square = resample(random_pattern_square',random_resample_time,1,0);
        random_pattern_square = uint8(random_pattern_square);
        
        % Assign image in matrix 'tx' to i'th texture:
        glTexImage2D(GL.TEXTURE_2D,0,GL.LUMINANCE,Rwidth,Rz,0,GL.LUMINANCE,GL.UNSIGNED_BYTE,random_pattern_square);
        % Setup texture wrapping behaviour:
        glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);
        glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);
        % Setup filtering for the textures:
        glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.LINEAR);
        glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.LINEAR);
        % Choose texture application function: It shall modulate the light
        % reflection properties of the the cubes face:
        glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
    end
    
    glClear;
    
    % Setting ball texture
    [gltex, gltextarget] = Screen('GetOpenGLTexture', screen.window, balltex); % Retrieve OpenGL handles to the PTB texture
    glEnable(gltextarget); % Enable texture mapping
    glBindTexture(gltextarget, gltex); % Bind our texture
    
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE); % Textures color texel values shall modulate the color computed by lighting model
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT); % Clamping behaviour shall be a cyclic repeat
    glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
    glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR); % Set up minification and magnification filters.
    glGenerateMipmapEXT(gltextarget); % generate all depth levels automatically (gluBuild2DMipmaps)
    mysphere = gluNewQuadric; % Create the sphere as a quadric object
    gluQuadricTexture(mysphere, GL.TRUE); % Enable automatic generation of texture coordinates for our quadric object
    
    glViewport(0, 0, RectWidth(screen.rect), RectHeight(screen.rect)); % Set viewport properly iin pixels
    
    glEnable(GL.LIGHTING); % Turn on OpenGL local lighting model
    glEnable(GL.DEPTH_TEST); % Enable proper occlusion handling via depth tests
    glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT,  [ .9 .9 .9 1 ]);
    glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE,  [ .9 .9 .9 1 ]); % Define the sphere light reflection properties: ambient, diffuse and specular reflection
    
    glMatrixMode(GL.MODELVIEW); % Setup modelview matrix: position, orientation and looking direction of camera
    glLoadIdentity;
    
    gluLookAt(0,0,0,0,0,-100,0,1,0); % Cam is located at 3D position of the worlds coordinate system
    glClearColor(0.5,0.5,0.5,0); % Set background color to 'gray'
    
    glLightfv(GL.LIGHT0,GL.AMBIENT, [ .5 .5 .5 1 ]);
    glLightfv(GL.LIGHT0,GL.DIFFUSE, [ .5 .5 .5 1 ]);
    glEnable(GL.LIGHT0); % diffuse light
    
    glClear; % Clear out the backbuffer whenever redraw
    Screen('EndOpenGL', screen.window);

    % set up camera's position
    % FOV = atand(monitorWidth/2/monitor.distance)*2;
    near = monitor.distance-0.1;
    far = -100;
    zero_plane = 0;
    dist = monitor.distance - zero_plane;
    win_x = monitor.size(1) / 2;
    win_y = monitor.size(2) / 2;
    eyeeccen = 0;

    %% staircase setup
    marginalize = [];
    AvoidConsecutive = 1;
    WaitTime = 4;
    NumTrials = Exp.trial_num;
    grain = 101;

    PF = @PAL_Logistic;
    stimRange = static.exp_durations;
    priorAlphaRange = linspace(min(static.exp_durations), max(static.exp_durations), grain);
    priorBetaRange =  linspace(log10(.0625), log10(80), grain);
    priorGammaRange = 0.5; % generating guess rate - ignored becase 'gammaEQlambda' set to 1.
    priorLambdaRange = (0:.01:.1);

    % static
    PM = PAL_AMPM_setupPM;
    PM.condition = 'Looming - static match';
    PM.ref_intensity = looming.exp_durations;
    PM.xlabel = 'Duration of static stimulus(s)';
    PM.ylabel = 'Proportion of static stimulus perceived longer';
    %Initialize PM structure (use of single() cuts down on memory load)
    PM = PAL_AMPM_setupPM(PM, 'priorAlphaRange',single(priorAlphaRange),'priorBetaRange',single(priorBetaRange),'priorGammaRange',single(priorGammaRange),'priorLambdaRange',single(priorLambdaRange), 'numtrials',NumTrials, 'PF' , PF,'stimRange',single(stimRange), 'gammaEQlambda', 1, 'marginalize',marginalize);
    
    HideCursor;
    %% Welcome/intro text
    textStr = 'This experiment is a DURATION discrimination experiment.\n In each trial, you will see two balls successively showed on the center of the screen.\n The task is to judge which ball lasted LONGER.\n If the FIRST one is showed LONGER, press the `1` button.\n If the SECOND one is showed LONGER, press the `2` button.\n Try your best to keep your eyes on the FIXATION at the center of the screen during the experiment.\n Note that sometimes, the stimulus change size during the presentation.\n You should ignore this in your judgment. \n Press SPACE key to continue.';
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
        condition = Design(k, 2);
        if condition == 1 % 
            the_duration = PM.xCurrent;
        end
        order = Design(k, 3);
        position = Design(k, 4);

        if mod(k, 50) == 1
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
            Screen('BeginOpenGL', screen.window);
            % set projection matrix
            glMatrixMode(GL.PROJECTION);
            glLoadIdentity;
            moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
            % setting background
            glClear;
            glScalef(scaleFac,scaleFac,scaleFac);
            funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
            funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
            funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
            funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
            glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
            Screen('EndOpenGL', screen.window)
            DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [], 2, [], [0 0 Xc*2 Yc*2-100]);
            % fixation
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            KbStrokeWait(-1);
            WaitSecs('UntilTime', GetSecs + 1);
        end

        if order == 1
            % looming stimulus first
            cf = 1;
            while cf <= looming.frame_num(1)
                Screen('BeginOpenGL', screen.window);
                % set projection matrix
                glMatrixMode(GL.PROJECTION);
                glLoadIdentity;
                moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
                % setting background
                glClear;
                glScalef(scaleFac,scaleFac,scaleFac);
                funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
                funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
                funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
                funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
                glScalef(1/scaleFac,1/scaleFac,1/scaleFac);

                % target balls
                glBindTexture(gltextarget, gltex); % Bind ball texture (checkerboard)
                % new parameters measued by target frame
                clear x1 dx traceY z1 dz;
                x1 = newx1(1,1,position);
                dx = newdx(1,1,position);
                traceY = newtraceY(1,1,position);
                dz = newdz(1,1,position);
                z1 = newz1(1,1,position);
                glTranslatef(x1+dx*cf, traceY, z1+dz*cf); % Position Change of the sphere
                glRotatef(8*cf, 10, 10, 10);
                %glRotatef(4*fk_tmp, 0, rotDirection, 0);
                gluSphere(mysphere, ballSize, slices, stacks);
                Screen('EndOpenGL', screen.window);
                Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end

            % ISI
            Screen('BeginOpenGL', screen.window);
            glClear;
            % set projection matrix
            glMatrixMode(GL.PROJECTION);
            glLoadIdentity;
            moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
            % setting background
            glClear;
            glScalef(scaleFac,scaleFac,scaleFac);
            funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
            funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
            funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
            funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
            glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
            Screen('EndOpenGL', screen.window);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            ISI = randi([Exp.ISI(1), Exp.ISI(2)]) / 1000;
            WaitSecs('UntilTime', GetSecs + ISI);

            % static stimulus
            cf = 1;
            while cf <= round(the_duration / screen.ifi)
                Screen('BeginOpenGL', screen.window);
                % set projection matrix
                glMatrixMode(GL.PROJECTION);
                glLoadIdentity;
                moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
                % setting background
                glClear;
                glScalef(scaleFac,scaleFac,scaleFac);
                funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
                funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
                funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
                funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
                glScalef(1/scaleFac,1/scaleFac,1/scaleFac);

                glBindTexture(gltextarget, gltex); % Bind ball texture (checkerboard)
                % glTranslatef(endx*positions(3-position), 0, endz); % Position of the sphere
                glTranslatef(endx*positions(position), 0, endz); % Position of the sphere
                glRotatef(90, 1, 0, 0);
                gluSphere(mysphere, ballavgsize, slices, stacks); % average size (0.0212 meter) in steady condition
                Screen('EndOpenGL', screen.window);
                Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end
        else
            % static stimulus
            cf = 1;
            while cf <= round(the_duration / screen.ifi)
                Screen('BeginOpenGL', screen.window);
                % set projection matrix
                glMatrixMode(GL.PROJECTION);
                glLoadIdentity;
                moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
                % setting background
                glClear;
                glScalef(scaleFac,scaleFac,scaleFac);
                funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
                funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
                funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
                funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
                glScalef(1/scaleFac,1/scaleFac,1/scaleFac);

                glBindTexture(gltextarget, gltex); % Bind ball texture (checkerboard)
                % glTranslatef(endx*positions(3-position), 0, endz); % Position of the sphere
                glTranslatef(endx*positions(position), 0, endz); % Position of the sphere
                glRotatef(90, 1, 0, 0);
                gluSphere(mysphere, ballavgsize, slices, stacks); % average size (0.0212 meter) in steady condition
                Screen('EndOpenGL', screen.window);
                Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end

            % ISI
            Screen('BeginOpenGL', screen.window);
            % set projection matrix
            glMatrixMode(GL.PROJECTION);
            glLoadIdentity;
            moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
            % setting background
            glClear;
            glScalef(scaleFac,scaleFac,scaleFac);
            funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
            funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
            funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
            funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
            funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
            glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
            Screen('EndOpenGL', screen.window);
            Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
            Screen('Flip', screen.window);
            ISI = randi([Exp.ISI(1), Exp.ISI(2)]) / 1000;
            WaitSecs('UntilTime', GetSecs + ISI);
            
            % looming stimulus second
            cf = 1;
            while cf <= looming.frame_num(1)
                Screen('BeginOpenGL', screen.window);
                % set projection matrix
                glMatrixMode(GL.PROJECTION);
                glLoadIdentity;
                moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
                % setting background
                glClear;
                glScalef(scaleFac,scaleFac,scaleFac);
                funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
                funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
                funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
                funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
                funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
                glScalef(1/scaleFac,1/scaleFac,1/scaleFac);

                % target balls
                glBindTexture(gltextarget, gltex); % Bind ball texture (checkerboard)
                % new parameters measued by target frame
                clear x1 dx traceY z1 dz;
                x1 = newx1(1,1,position);
                dx = newdx(1,1,position);
                traceY = newtraceY(1,1,position);
                dz = newdz(1,1,position);
                z1 = newz1(1,1,position);
                glTranslatef(x1+dx*cf, traceY, z1+dz*cf); % Position Change of the sphere
                % glRotatef(90, 1, 0, 0);
                glRotatef(8*cf, 10, 10, 10);
                %glRotatef(4*fk_tmp, 0, rotDirection, 0);
                gluSphere(mysphere, ballSize, slices, stacks);
                Screen('EndOpenGL', screen.window);
                Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
                Screen('Flip', screen.window);
                cf = cf + 1;
            end
        end

        Screen('BeginOpenGL', screen.window);
        % set projection matrix
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
        % setting background
        glClear;
        glScalef(scaleFac,scaleFac,scaleFac);
        funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
        funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
        funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
        funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
        funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
        funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
        glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
        Screen('EndOpenGL', screen.window)
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        WaitSecs('UntilTime', GetSecs + 0.3);

        % Response
        Screen('BeginOpenGL', screen.window);
        % set projection matrix
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
        % setting background
        glClear;
        glScalef(scaleFac,scaleFac,scaleFac);
        funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
        funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
        funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
        funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
        funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
        funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
        glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
        Screen('EndOpenGL', screen.window);
        textStr = 'Which stimulus lasted longer? \n (FIRST: press 1. SECOND: press 2)';
        DrawFormattedText(screen.window, textStr, 'center', 'center', text_color, [], [], [],2, [], [0 0 Xc*2 Yc*2-100]);
        Screen('DrawTexture',screen.window,fixation.texture,[],fixation.rect);
        Screen('Flip', screen.window);
        while true
            [press, press_time, keycode] = KbCheck(-1);
            if press
                if keycode(key.esc)
                    return;
                elseif keycode(key.resp1)
                    the_key = 1;
                    % if static stimulus (looming is reference) is selected, than response=1
                    if order == 1
                        response = 0;
                    else
                        response = 1;
                    end
                    break;
                elseif keycode(key.resp2)
                    the_key = 2;
                    if order == 2
                        response = 0;
                    else
                        response = 1;
                    end
                    break;
                end
            end
        end
        % update
        if condition == 1
            if PM.xCurrent == max(single(stimRange)) && AvoidConsecutive
                suspend = 1;
                suspend_count = suspend_count + 1;
            else
                if suspend_count >= 1
                    suspend_count = suspend_count - 1;
                end
            end
            % 如果刺激�??大还连续�??2次以上，则重复做，不计入次数
            if suspend && suspend_count > 2 && ~response
                WaitSecs('UntilTime', GetSecs + ITI);
                continue;
            end
            % 表示做错了肯定是因为按错�??
            if suspend == 1
                suspend = rand(1) > 1./WaitTime;
            end
            PM = PAL_AMPM_updatePM(PM, response, 'fixLapse', suspend);
        end
        Design(k, 1) = the_duration;
        Design(k, 5) = the_key;
        Design(k, 6) = response;
        k = k + 1;

        % ITI Blank
        Screen('BeginOpenGL', screen.window);
        % set projection matrix
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        moglStereoProjection(-win_x, win_x, -win_y, win_y, near, far, zero_plane, dist, eyeeccen);
        % setting background
        glClear;
        glScalef(scaleFac,scaleFac,scaleFac);
        funTunnelWallGl(upfaceTexs,texname(3),grid, epx);
        funTunnelWallGl(lowfaceTexs,texname(4),grid, epx);
        funTunnelWallGl(leftfaceTexs,texname(5),upleftgrid, epy);
        funTunnelWallGl(leftfaceTexs,texname(6),lowleftgrid, epy);
        funTunnelWallGl(rightfaceTexs,texname(7),uprightgrid, epy);
        funTunnelWallGl(rightfaceTexs,texname(8),lowrightgrid, epy);
        glScalef(1/scaleFac,1/scaleFac,1/scaleFac);
        Screen('EndOpenGL', screen.window);
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
        data.sbj = sbj;
        PMs(1) = CHToolbox_PMF_RemoveNonsenseData(PM);
        data.Design = Design;
        data.PMs = PMs;
        save(filename, 'data', 'monitor', 'screen', 'Exp', 'static', 'looming');
    end
catch
    sca;
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