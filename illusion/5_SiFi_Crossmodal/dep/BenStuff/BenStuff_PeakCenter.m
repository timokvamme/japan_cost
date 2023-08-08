function [Mc, Shift] = BenStuff_PeakCenter( M )
%[Mc, Shift] = BenStuff_PeakCenter( M )
%   Centers vector on peak value and truncates to original length, pads
%   with NaNs as needed. For matrices will center columns on peaks accordingly
%
%   If size(M,2) is even, the peak will be centered on (size(M,1)./2)+1
%
%   M:          input matrix
%   Shift:      vector w amount of shift for each column
%   Mc:         peak centered output matrix
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 5/2016
%

%Mc = nan(size(M));%initialise
CenterPos = round(size(M,1)./2);

[Foo, PeakPos] = max(M); %find peaks
Shift = CenterPos-PeakPos;%how far do we need to shift down (up for neg values)

Mc = BenStuff_NaNshift(M, Shift);

end

