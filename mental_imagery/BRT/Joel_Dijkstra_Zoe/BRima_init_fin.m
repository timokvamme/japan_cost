function BRima_init_fin(SubID, redContrast, greenContrast)

%% ---------- Description ----------
% initializes parameters and runs experiment

% author: Youngzie Lee, UCLA
% last edited: 09.18.2020

%% ---------- Program history ----------


%% ---------- Start Setup ----------
% Prevents MATLAB from reprinting the source code when the program runs.
echo off

% Initializes the experiment parameters in struct P
P = struct;

% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

RestrictKeysForKbCheck([]); % reenable all keys for KbCheck

% Prevent spilling of keystrokes into console:
% ListenChar(-1);

%% ---------- Basic Info Setup ----------

if nargin < 1 % Zoe's computer screen resolutions
    SubID = 1;
    redContrast = 100;
    greenContrast = 100;
    screenWidth = 53;
    screenHeight = 33;
    screenDistance = 60;
end

P.subject = num2str(SubID);
P.date = datestr(now, 'yyyymmdd');
P.dataPath  = fullfile(pwd,P.subject);

%load(sprintf('trialMatrix_%s.mat',P.subject)) % load the trial matrix
load('fuu'); trialMatrix = fuu;
if ~exist(P.dataPath, 'dir'), mkdir(P.dataPath); end

% % Determine current session
% [P.session, P.sessionName] = current_session([P.date '_brima_' subjectID], P.dataPath); 
% if strcmp(P.session, 'abort'), error('No response given, exiting.'); end

%% ---------- Screen Setup ----------
% screen parameters???

% % % screenWidth = input('What is the screen width in centimeters?');
% % % screenHeight = input('What is the screen height in centimeters?');
% % % screenDistance = input('What is the distance to the screen in centimeters?');
% screenNumber = input('What is the screen number you want to use? Default is 0');

screenid = max(Screen('Screens'));

[screenResolution(1), screenResolution(2)] = Screen('WindowSize', screenid);
visualField_horizontal = atan(screenWidth/2/screenDistance)*180/pi*2;    % in degrees
horizontal_pixPerDeg = screenResolution(1)/visualField_horizontal;         % in degrees
visualField_vertical = atan(screenHeight/2/screenDistance)*180/pi*2;     % in degrees
vertical_pixPerDeg = screenResolution(2)/visualField_vertical;             % in degrees

P.pixPerDeg = (horizontal_pixPerDeg + vertical_pixPerDeg)/2;
P.frameHz = Screen('FrameRate', screenid);
%calibrationFile = [];
P.resolution       = Screen('Rect', screenid);
P.backgroundColour = 0;

P.fontName         = 'Arial';
P.fontSize         = 26;

%% ---------- Key Setup ----------
P.leftKey   = 's'; % vividness indicatons
P.rightKey  = 'f';
P.redKey = 'j';
P.greenKey= 'l';
P.mixedKey= 'k';
P.keys      = {'j','k','l'}; % response keys
P.escapeKey = 'ESCAPE';

%% ---------- Grating Setup ----------
% stimulus size
P.stimSizeInDegree = 10;
P.stimSizeInPix = round([P.stimSizeInDegree*P.pixPerDeg P.stimSizeInDegree*P.pixPerDeg]);	% Width, height of stimulus
P.gaborSize = P.stimSizeInPix(1);

% Size of support in pixels, derived from P.gaborSize:
P.tw = 2*P.gaborSize+1;
P.th = 2*P.gaborSize+1;

P.distFromFixInDeg = 1;
P.distFromFixInPix = round(P.pixPerDeg * P.distFromFixInDeg);
P.baseRect = [0 0 160 160]; % stimulus frame
P.fixRadiusInDegree = .6;


% % *** If the grating is clipped on the sides, increase widthOfGrid.
% widthOfGrid = 200;
% halfWidthOfGrid = widthOfGrid / 2;
% widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

% Grating parameters
P.edge = 20.0; % spatial constant (sc) of the gaussian hull function of the gabor, ie. the "sigma" value in the exponential function.
% P.targDev   = 10; % grating deviation from vertical
P.phase = 0; % initial phase of the gabors sine grating in degrees
P.freq = .2; % spatial frequency in cycles per pixel
P.tilt = 45; % optional orientation angle in degrees (0-360)
P.aspectRatio = 1.0; % aspect ratio width vs. height
P.contrast = 100; % initial contrast, not shown to participant.



% [gab_x gab_y] = meshgrid(widthArray, widthArray);
% a=cos(deg2rad(P.tilt))*P.freq*360;
% b=sin(deg2rad(P.tilt))*P.freq*360;
% multConst=1/(sqrt(2*pi)*P.freq);
% x_factor=-1*(gab_x-x).^2;
% y_factor=-1*(gab_y-y).^2;
% sinWave=sin(deg2rad(a*(gab_x - x) + b*(gab_y - y)+P.phase));
% varScale=2*P.freq^2;
% m=P.contrast*(multConst*exp(x_factor/varScale+y_factor/varScale);
% 
% gabortex=Screen('MakeTexture', win, m, [], [], 2);
% texrect = Screen('Rect', gabortex);
% 
% Screen('DrawTextures', win, gabortex, [], [], rotAngles, [], 0.5, [], [], sflags);

%% ---------- Gamma-corrected CLUT ----------
P.meanLum = 0.5;
P.contrast = 1;
P.stimContrast = 0.2;
P.amp = P.meanLum * P.contrast;

nColours = 255;	% number of gray levels to use in mpcmaplist, should be uneven
mpcMapList = zeros(256,3);	% color look-up table of 256 RGB values, RANGE 0-1
tempTrial = linspace(P.meanLum-P.amp, P.meanLum+P.amp, nColours)';	% make grayscale gradient

P.meanColourIdx = ceil((nColours)/2) -1; % mean colour number (0-255) of stimulus (used to index rows 1:256 in mpcmaplist)
P.ampColourIdx  = floor(P.stimContrast*(nColours-1)); % amplitude of colour variation for stimulus
% 
% if ~isempty(P.calibrationFile)
%     load(P.calibrationFile);	% function loads inverse gamma table and screen dacsize from most recent calibration file
%     
%     mpcMapList(1:nColours,:) = repmat(tempTrial, [1 3]);
%     mpcMapList(256,1:3) = 1;
%     mpcMapList = round(map2map(mpcMapList,gammaInverse));
%     
%     P.CLUT = mpcMapList;
% end


%% ---------- Color Setup ----------
P.backgroundColor = 0;
P.red = [1 0 0];
P.green = [0 1 0];

% set contrast values from user input
P.redContrast = redContrast;
P.greenContrast = greenContrast;

P.preContrastMultiplier = 1;
P.initialContrast = 0.5;


% contrast = 30.0; % amplitude of gabor in intensity units; multiplied to the evaluated gabor equation before converting the
% value into a color value. check if 'contrast' is right definition..
% aspectratio = 1.0; % aspect ratio of the hull of the gabor. This
% % parameter is ignored if the 'nonSymmetric' flag hasn't been set to 1 when
% % calling the CreateProceduralGabor() function.

%% ---------- Fixation Setup ----------
% P.fixRadiusInDegree = .6;
P.fixCrossDimPix = 20;
P.fixLineWidthPix = 2;
%% ---------- Experiment Setup ---------
P.session = 1;
P.nRuns = 1;
P.nTrialsPerRun = size(trialMatrix,1)/P.nRuns;
P.runIdx = ((P.session-1)*P.nTrialsPerRun+1):(P.session*P.nTrialsPerRun);
P.trialMatrix = trialMatrix(P.runIdx,:);


P.phaseVaried = rand(1, P.nTrialsPerRun);
P.phaseVaried = 100 .* P.phaseVaried;

%% ---------- Cue Setup ----------
P.retroCueID = {'R','G'};
P.retroCueColour = [255 255 255];

%% ---------- Timing Setup ----------
P.fix               = 0.2;	
P.startDur          = 0.4;
P.postStartDur      = 0.3;

P.cueDur            = 0.75; 
P.imageryDur        = 7; 
P.confDur           = 5; % time the conf stimulus will be on screen for (=response epoch)
P.BRstimDur         = 0.75;
P.responseDur       = 3; % response time window

P.ISIrange          = [0.4, 0.6];
P.postStimRange     = [0.4, 0.6];
P.ITIrange          = [0.4, 0.6]; 
P.confDim           = P.confDur - 1; % how far into the conf task should the rating start to dim?
P.postStimDur       = 0.2;

%% ---------- Vividness Rating Setup ----------
P.lineLengthPix            = 300;
P.vertLineLengthPix        = 20;
P.sliderLengthPix          = 40;
P.matchMean                = P.backgroundColour;
P.matchContrast            = 0.4;
P.matchAmp                 = P.matchMean * P.matchContrast;
P.lineDiamPix              = 5;
P.midX                     = (P.resolution(3)-P.resolution(1))/2+P.resolution(1);
P.midY                     = (P.resolution(4)-P.resolution(2))/2+P.resolution(2);
P.lineRect                 = [P.midX-P.lineLengthPix/2 P.midY-P.lineLengthPix/2 P.midX+P.lineLengthPix/2 P.midY+P.lineLengthPix/2];
P.sliderRect               = [P.midX-P.sliderLengthPix/2 P.midY-P.sliderLengthPix/2 P.midX+P.sliderLengthPix/2 P.midY+P.sliderLengthPix/2];
P.yOffset                  = 120;

%% ---------- Trigger Setup ---------- do i need this?
P.triggerStart = 66; 
P.triggerCue   = 70; % + identity of the cue
P.triggerResponseOnset = 80;
P.triggerResponse = 90; % + identity of the response
% perception = first-or-second stim   | stim identity
% imagery =    first-or-second stim+2 | stim identity

%% ----------- Save matrix P ------------ can omit for main session
save('P', 'P');

%% ---------- Run Experiment! ----------
% BRima_task_fin(P);

