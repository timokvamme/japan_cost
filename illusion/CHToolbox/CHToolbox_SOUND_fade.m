function [new_signal] = CHToolbox_SOUND_fade(fs, origin_signal, fade_duration)

signal_length = length(origin_signal);
fade_num = ceil(fade_duration*fs);
gate = sin(linspace(-pi/2, pi/2, fade_num));
gate = (gate + 1) / 2;
offgate = fliplr(gate);
envolope = [gate, ones(1, signal_length-fade_num*2), offgate];
new_signal = origin_signal .* envolope;