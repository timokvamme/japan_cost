function [ V ] = BenStuff_VisualAngle( S, D, I )
%[ V ] = BenStuff_VisualAngle( S, D, [I] ) gimme visual angle from distance and
%size, please
%   S: stimulus size
%   D: viewing distance
%   S & D should be in the same metric unit
%
%   I: invert function - if set to 1 the function expects S to refer to
%   visual angle and outputs stimulus size as V (in the same unit that was
%   used to provide viewing distance)
%
% found a bug? please let me know!
% benjamindehaas@gmail.com 
%

if nargin<3
    I=0;
end

if ~I
    V=2.*atand(S./(2.*D));
else
    V=(tand(S./2)).*2.*D; 
end




end

