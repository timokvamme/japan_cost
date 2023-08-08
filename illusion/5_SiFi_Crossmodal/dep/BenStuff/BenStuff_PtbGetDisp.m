function [ disp ] = BenStuff_PtbGetDisp( Window, ViewingDistance)
%[ disp ] = BenStuff_PtbGetDisp( Window, ViewingDistance)
%   function to determine and return details of the display and Ptb window
%
%   Window              handle to Ptb window
%   ViewingDistance     viewing distance in mm
%
%   disp                struct containing display and Window details:
%
%                       disp.WindowCenterX 
%                       disp.WindowCenterY 
%                       disp.WindowWidth 
%                       disp.WindowHeight
%                       disp.WidthMM
%                       disp.HeightMM
%                       disp.Resolution
%                       disp.Hz
%                       disp.PixPerMM
%                       disp.PixPerMMSanityCheck
%                       disp.ViewingDistance
%                       disp.DegVisAngPerMM
%                       disp.DegVisAngPerPix
%                       disp.PixPerDegVisAng
%                       disp.Scale
%
%                       disp.PtbStamp
%
% found a bug? please let me know!
% 9/16 benjamindehaas@gmail.com
%

% determine center of window
[WindowWidth, WindowHeight]=Screen('WindowSize', Window); % give me the size of the window
WindowCenter=[WindowWidth/2, WindowHeight/2];% store the centervalues in variables
WindowCenterX=WindowCenter(1);
WindowCenterY=WindowCenter(2);

%display calibration
[disp.WidthMM, disp.HeightMM]=Screen('DisplaySize', Window); %get various infos to create PTB scalefactor
screenNumber=Screen('WindowScreenNumber', Window);
disp.Resolution=Screen('Resolution', screenNumber);
disp.Hz=1/Screen('GetFlipInterval', Window);
disp.PixPerMM=disp.Resolution.width/disp.WidthMM;
disp.PixPerMMSanityCheck=disp.Resolution.height/disp.HeightMM;

disp.ViewingDistance=ViewingDistance;
disp.DegVisAngPerMM=2*atand(.001*2*disp.ViewingDistance/1000);%values in m!
disp.DegVisAngPerPix=2*atand(.001/disp.PixPerMM*2*disp.ViewingDistance/1000);
disp.PixPerDegVisAng=1/disp.DegVisAngPerPix;
disp.Scale=disp.PixPerDegVisAng;

disp.WindowCenterX = WindowCenterX;
disp.WindowCenterY = WindowCenterY;
disp.WindowWidth = WindowWidth;
disp.WindowHeight = WindowHeight;

disp.PtbStamp = BenStuff_PTB_Stamp(Window);



end

