function [player] = CHToolbox_SOUND_Initialize(fs)

% Perform basic initialization of the sound driver:
InitializePsychSound(1); % 1 for high accuracy timing and low latency
player.device = -1;
player.nrchannels = 2; % 双声道

% Open the  audio device, with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
try
    % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', player.device, [], 1, fs, player.nrchannels);
catch
    % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', fs);
    fprintf('Sound may sound a bit out of tune, ...\n\n');

    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', player.device, [], 1, [], player.nrchannels);
end
s = PsychPortAudio('GetStatus', pahandle);
player.fs = s.SampleRate;
player.pahandle = pahandle;