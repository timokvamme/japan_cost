function [ FixTex, UpTex, DownTex ] = PrepareTextures( Params, Win )
%[ FixTex, UpperDiskTex, LowerDiskTex, LeftFaceTex, RightFaceTex ] = PrepareTextures( Params )
%
%   function to prepare textures for SiF experiment, as specified
%   in Params
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 11/2017
%
%   adapted for standard experiment for Christian, bdh 03/2020
%

disp = Params.disp;

% positions
StimCenterXm = disp.WindowCenterX;
StimCenterYm = disp.WindowCenterY;

StimCenterYu = disp.WindowCenterY - Params.StimEcc*disp.Scale;%left
StimCenterYd = disp.WindowCenterY + Params.StimEcc*disp.Scale;%right

% fix texture
FixRadius =  Params.FixSize .*disp.Scale;
FixRect = [StimCenterXm - FixRadius, StimCenterYm - FixRadius, StimCenterXm + FixRadius, StimCenterYm + FixRadius];

FixTex = Screen('OpenOffScreenWindow', Win);
Screen('FillRect', FixTex, Params.BackGr);%set background colour
Screen('FillOval', FixTex, Params.FixCol, FixRect);%draw fix dot 

% stim textures
StimRadius =  Params.StimSize .*disp.Scale;
UpRect = [StimCenterXm - StimRadius, StimCenterYu - StimRadius, StimCenterXm + StimRadius, StimCenterYu + StimRadius];
DownRect = [StimCenterXm - StimRadius, StimCenterYd - StimRadius, StimCenterXm + StimRadius, StimCenterYd + StimRadius];

UpTex = Screen('OpenOffScreenWindow', Win);
Screen('FillRect', UpTex, Params.BackGr);%set background colour
Screen('FillOval', UpTex, Params.FixCol, FixRect);%draw fix dot 
Screen('FillOval', UpTex, Params.StimCol, UpRect);%draw stim 

DownTex = Screen('OpenOffScreenWindow', Win);
Screen('FillRect', DownTex, Params.BackGr);%set background colour
Screen('FillOval', DownTex, Params.FixCol, FixRect);%draw stim
Screen('FillOval', DownTex, Params.StimCol, DownRect);%draw fix dot 


