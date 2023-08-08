% function run_all
close all
clear
commandwindow

hz = 100;

tic
sbj.id = input('Subject ID: ');
sbj.name = input('Subject Name: ', 's');
exp_num = input('Exp No.: ');
sbj.exp_type = input('Practice(1) or Main Exp(2)? ');

% check subject ID
if ~isnumeric(sbj.id)
    error('Subject ID must be a number (integer)');
end
sbj.id = num2str(sbj.id);
sbj.res_path = sprintf('%s/results/Sub_%s', pwd, sbj.id);
if exist(sbj.res_path, 'dir') == 7 && exp_num == 1
%     error('Subject ID already exists. You must pick a unique Subject ID.');
else
    mkdir(sbj.res_path);  
end

addpath(genpath([pwd filesep 'CHToolbox' filesep]));% add dependencies folder

% !!need to modify if use new device
monitor.num = max(Screen('Screens'));
monitor.resolution = Screen('Resolution', monitor.num);
monitor.distance = 0.6; % m

%% Screen Parameters and keys
InitializeMatlabOpenGL;
Screen('Preference', 'SkipSyncTests', 0);
[screen.window, screen.rect] = PsychImaging('OpenWindow', monitor.num, 128);
Screen('BlendFunction', screen.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % 透明�??�??
screen.ifi = Screen('GetFlipInterval', screen.window);
screen.resolution = [screen.rect(3) screen.rect(4)]; % 如果是左右眼分开的话，那就是单眼的分辨率
% Get the nominal framerate of the monitor (for timer).
screen.nominalFrameRate = Screen('NominalFrameRate', screen.window);

if screen.nominalFrameRate ~= hz
    error('fresh rate is not 100 !');
end

[w_mm, h_mm] = Screen('DisplaySize', screen.window);
monitor.size(1) = w_mm / 1000;
monitor.size(2) = h_mm / 1000;

topPriorityLevel = MaxPriority(screen.window);
Priority(topPriorityLevel);

% Select specific text font, style and size:
Screen('TextFont', screen.window, 'Courier New');
% Screen('TextSize',screen.window, 14);
Screen('TextSize', screen.window, 20);
Screen('TextStyle', screen.window, 1);
HideCursor();

% Keys
KbName('UnifyKeyNames');
key.start = KbName('SPACE');
key.esc = KbName('ESCAPE');
key.resp1 = KbName('1!'); % if this does not work try '1' instead of 1!
key.resp2 = KbName('2@');% if this does not work try '2' instead of 1@
key.next = KbName('n');

% select which experiments to run
runExps = [1, 2, 3, 4, 5];
latinsquare = CHToolbox_BASIC_MakeLatinsquare(length(runExps)); 
sequence = latinsquare(length(runExps) - mod(str2num(sbj.id), length(runExps)), :); % sequence of experiments

the_exp = sequence(exp_num);

if exp_num == 1
    %% Welcome text
    DrawFormattedText(screen.window, 'Welcome to the study. \n It consists of a series of short visual and auditory experiments. \n Press SPACE key to continue to the first experiment.', 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
end

switch the_exp
case 1
    %% time dilation illusion
    expText = ['This is experient ', num2str(exp_num),' of ', num2str(length(runExps)),'. \n Press SPACE key to start.'];
    DrawFormattedText(screen.window, expText, 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    Screen('Flip', screen.window);
    WaitSecs(.5);
    cd './1_Duration_Visual'
    % TimeDilation_looming_psy(sbj, screen, monitor, key);
    Duration_visual(sbj, screen, monitor, key);
    cd '..'
    DrawFormattedText(screen.window, 'The experient is finished, press SPACE key to continue.', 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
case 2
    %% filled duration illusion
    expText = ['This is experient ', num2str(exp_num),' of ', num2str(length(runExps)),'.\n Press SPACE Key to start.'];
    DrawFormattedText(screen.window, expText, 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    Screen('Flip', screen.window);
    WaitSecs(.5);
    cd './2_Duration_Auditory'
    Filled_duration_psy(sbj, screen, monitor, key);
    cd '..'
    DrawFormattedText(screen.window, 'The experient is finished, press SPACE key to continue.', 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
case 3
    %% duration crossmodal
    expText = ['This is experient ', num2str(exp_num),' of ', num2str(length(runExps)),'.\n Press SPACE Key to start.'];
    DrawFormattedText(screen.window, expText, 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    Screen('Flip', screen.window);
    WaitSecs(.5);
    cd './3_Duration_Crossmodal'
    Duration_crossmodal(sbj, screen, monitor, key);
    cd '..'
    DrawFormattedText(screen.window, 'The experient is finished, press SPACE key to continue.', 'center', 'center', 255);
    Screen('Flip', screen.window);
case 4
    %% kaniza illusion
    expText = ['This is experient ', num2str(exp_num),' of ', num2str(length(runExps)),'. \n Press SPACE Key to start.'];
    DrawFormattedText(screen.window, expText, 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    Screen('Flip', screen.window);
    WaitSecs(.5);
    cd './4_Luminance_Visual_Kaniza'
    Luminance_visual_kanizsa(sbj, screen, monitor, key);
    % kaniza_v1(sbj, screen, monitor, key);
    cd '..'
    DrawFormattedText(screen.window, 'The experient is finished, press SPACE key to continue.', 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
case 5
    %% sound-induced flash illusion
    expText = ['This is experient ', num2str(exp_num),' of ', num2str(length(runExps)),'.\n Press SPACE Key to start.'];
    DrawFormattedText(screen.window, expText, 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
    Screen('Flip', screen.window);
    WaitSecs(.5);
    cd './5_SiFi_Crossmodal'
    FlashBeep(sbj, screen, monitor);

    cd '..'
    DrawFormattedText(screen.window, 'The experient is finished, press SPACE key to continue.', 'center', 'center', 255);
    Screen('Flip', screen.window);
    KbStrokeWait(-1);
end

if exp_num == 5
    DrawFormattedText(screen.window, 'You have completed all experiments. Thank you! \n The results are being saved.', 'center', 'center', 255);
    Screen('Flip', screen.window);
end

WaitSecs(2);
ShowCursor;
sca;
toc
% end