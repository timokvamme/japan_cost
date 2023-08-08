function generateFilled(varargin)
% if no argument, it will generate all sounds and save them, else it will
% generate the sound following the input duration and play.
narginchk(0, 2)

amp = 1; 
fs = 48000;  % sampling frequency
freq = 500;

silent_duration = 0.05; % slient part put on the start and end, or it can't play rightly when use headphone
silent_values = zeros(1, fs*silent_duration);

if nargin == 0
    durations_group1 = 1:0.5:4;
    durations_group2 = 2:1:8;

    for i = 1:length(durations_group1)
        t = 0 : 1/fs : durations_group1(i); % time vector
        tone = amp * sin(2*pi*freq*t);
        values = [silent_values, tone, silent_values];
        filename = sprintf('sources/FilledDuration_Group1_%d.wav', durations_group1(i)*10);
        audiowrite(filename, values, fs);
    end

    for i = 1:length(durations_group2)
        t = 0 : 1/fs : durations_group2(i); % time vector
        tone = amp * sin(2*pi*freq*t);
        values = [silent_values, tone, silent_values];
        filename = sprintf('sources/FilledDuration_Group2_%d.wav', durations_group2(i));
        audiowrite(filename, values, fs);
    end
elseif nargin == 2
    duration = varargin{1};
    player = varargin{2};
    t = 0 : 1/fs : duration; % time vector
    tone = amp * (0.5*sin(2*pi*freq*t)+0.5);
    values = [silent_values, tone, silent_values];

    % old
    % hSound = audioplayer(values, fs, 16, -1); % audio handle
    % playblocking(hSound);

    %% new
    values = [values; values];
    PsychPortAudio('FillBuffer', player.pahandle, values);
    % Start audio playback for 'repetitions' repetitions of the sound data,
    % start it immediately (0) and wait for the playback to start, return onset timestamp.
    t1 = PsychPortAudio('Start', player.pahandle, 1, 0, 1); % 最后一个1表示等播放开始了再运行后面的
    % Wait for end of playback, then stop:
    PsychPortAudio('Stop', player.pahandle, 1);
end
return;