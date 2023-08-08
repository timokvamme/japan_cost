function [ SoundData, AudioHandle ] = PrepareSounds( Params )
%[ SoundData, AudioHandle ] = PrepareSounds( Params )
%
%   function to prepare sound for semantic SiF experiment, as specified
%   in Params
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 03/2020
%

if nargin < 1
    Params.SoundSampleFreq = 44100;
    Params.SoundDur = 20;
    Params.SoundFreq = 3500;
end 

%prepare beep
dt = 1/Params.SoundSampleFreq;
t = [0:dt:Params.SoundDur./1000];
SoundData = sin(2*pi*Params.SoundFreq*t);
SoundData = [SoundData; SoundData];%needs to be stereo

%now use psychportaudioto fill buffer
PsychPortAudio('Close');
PsychPortAudio('Close');
DeviceID = -1;%21;
AudioHandle = PsychPortAudio('Open', DeviceID);%, Params.AudioPriority);%'mode' flag: 1 (only playback), 'reglatencyclass' flag to demand high priority 
%SoundLo = PsychPortAudio('OpenSlave', pamaster);%'mode' flag: 1 (only playback), 'reglatencyclass' flag to demand high priority 
% SoundHi = PsychPortAudio('OpenSlave', pamaster);
% SoundHi = PsychPortAudio('CreateBuffer', PAhandle, SoundHiData);
% SoundLo = PsychPortAudio('CreateBuffer', PAhandle, SoundLoData);

%PsychPortAudio('FillBuffer', AudioHandle, SoundHiData);
%PsychPortAudio('FillBuffer', AudioHandle, SoundLoData);

