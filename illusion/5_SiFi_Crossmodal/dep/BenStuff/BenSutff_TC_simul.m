function [TC, SampleX, SampleY] = BenSutff_TC_simul(TR, Onsets, Durs)
% [TC, SampleX, SampleY] = BenSutff_TC_simul(TR, Onsets, Durs)
% Quick and dirty look at time course predictions for design evaluation etc.
%  
%   TR:         TR in seconds
%   Onsets:     vector with boxcar onsets in seconds
%   Durs:       vector with boxcar durs in seconds
%
%   TC:         time course predictor
%   SampleX:    vector specifying TC entries corresponding to sampled volumes
%   SampleY:    corresponding values in TC
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 4/2017
%

MicroTime = .1;
Hrf = spm_hrf(MicroTime);

Onsets = Onsets ./MicroTime;
Durs = Durs ./MicroTime;

BoxCar = zeros(1, Onsets(end)+Durs(end)+30./MicroTime);
IsSampled = logical(BoxCar);

IsSampled((TR./MicroTime):(TR./MicroTime):end) = true;

for iOnset = 1:length(Onsets)
    BoxCar(Onsets(iOnset): Onsets(iOnset)+Durs(iOnset)) = 1;
end

TC = conv(BoxCar, Hrf);

SampleY = TC(IsSampled);
SampleX = find(IsSampled);



end

