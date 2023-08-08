function Tex = BenStuff_DrawFixTexture(Win, Distance, FixRadius, BackCol, FixCol, Cross, PenWidth)
%Tex = BenStuff_DrawFixTexture(Win, disp, [FixRadius], [BackCol], [FixCol], [Cross], [FixWidth])
%   function to draw fixation dot / cross in psychtoolbox
%
%   Win:        window pointer
%   Distance:   viewing distance in mm [defaults to 650]
%   FixRadius:  radius of fixation dot/cross in d.v.a. [defaults to .25]
%   BackCol:    background color triplet [defaults to [.5 .5 .5]]
%   FixCol:     fix color [defaults to [0 0 0]]
%   Cross:      will draw cross rather than disk if true [default = 0]
%   PenWidth:   pen width for cross drawing in d.v.a. [defaults to .1]
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 8/2017
%

disp = BenStuff_PtbGetDisp(Win, Distance);

%% defaults
if nargin < 7; PenWidth = .1*disp.Scale; end %deafult pen width for cross .1 d.v.a.
if nargin < 6; Cross = 0; end %deafults to dot
if nargin < 5; FixCol = [0 0 0]; end %default fix color: black
if nargin < 4; BackCol = [.5 .5 .5]; end %default background color: mid grey
if nargin < 3; FixRadius = .25; end %default fixation dot radius (/half cross width): .25 d.v.a.
if nargin < 2; Distance = 650; end%viewing distance defaults to 650 mm

%% Rect
FixRadius = FixRadius .*disp.Scale;%scale radius to pixels
FixRect = [disp.WindowCenterX - FixRadius, disp.WindowCenterY - FixRadius, disp.WindowCenterX + FixRadius, disp.WindowCenterY + FixRadius];

%% let's draw
Tex=Screen('OpenOffScreenWindow', Win);
Screen('FillRect', Tex, BackCol);%set background colour

if Cross
    Screen('DrawLine', Tex, FixCol, FixRect + [FixRadius 0 -FixRadius 0], PenWidth);
    Screen('DrawLine', Tex, FixCol, FixRect + [0 FixRadius 0 -FixRadius], PenWidth);
else%dot
    Screen('FillOval', Tex, FixCol, FixRect); 
end

end

