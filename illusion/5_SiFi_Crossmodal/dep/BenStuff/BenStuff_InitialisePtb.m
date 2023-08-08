function [ Window, disp ] = BenStuff_InitialisePtb( ViewingDistance, TestMode )
%[ Window, disp ] = BenStuff_InitialisePtb( ViewingDistance, TestMode ) 
%   set up ptb
%   Window is a handle (the windowpointer)
%   disp is a struct 

if nargin<1
    ViewingDistance=800;%default to 80 cm from screen (i.e. 101)
end


if nargin<2
    TestMode=0;
end

if TestMode
    Window=Screen('OpenWindow', WhichScreen, [128 128 128], [0 0 1000 800]);
else
    Window=Screen('OpenWindow', WhichScreen, [128 128 128]);
    HideCursor;
end
    
% determine center of window
[disp.WindowWidth, disp.WindowHeight]=Screen('windowsize', Window); % give me the size of the window
disp.WindowCenter=[WindowWidth/2, WindowHeight/2];% store the centervalues in variables
disp.WindowCenterX=WindowCenter(1);
disp.WindowCenterY=WindowCenter(2);


%display calibration
[disp.WidthMM, disp.HeightMM]=Screen('DisplaySize', Window); %get various infos to create PTB scalefactor
disp.screenNumber=Screen('WindowScreenNumber', Window);
disp.Resolution=Screen('Resolution', disp.screenNumber);
disp.Hz=1/Screen('GetFlipInterval', Window);
disp.PixPerMM=disp.Resolution.width/disp.WidthMM;
disp.PixPerMMSanityCheck=disp.Resolution.height/disp.HeightMM;

disp.ViewingDistance=ViewingDistance;
disp.DegVisAngPerMM=2*atand(.001*2*disp.ViewingDistance/1000);%values in m!
disp.DegVisAngPerPix=2*atand(.001/disp.PixPerMM*2*disp.ViewingDistance/1000);
disp.PixPerDegVisAng=1/disp.DegVisAngPerPix;
disp.Scale=disp.PixPerDegVisAng;

end

