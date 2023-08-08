function [ OutArg ] = BenStuff_SIAM(Parameters)

%SIAM sound induced apparent motion
%   this is a mock ptb function to pilot whether SiF can extend to inducing
%   apparent motion - i.e. inducing the percpetion of a flash at a *new*
%   location
%
%   THIS VERSION IS FOR DYNAMICAL PILOTING IN CONJUNCTION WITH
%   BenStuff_PtbPilot
%
%   ->Subjectively sounds don't make (much of) a difference
%

%% fixed params

Parameters.Fixation_Width=[10 60]; % Width of fixation spot/surrounding gap in pixels
Parameters.Spider_Web=0;%opacity of spider web

Parameters.FlashDur=.032; % 1 frame at 60 Hz
Parameters.FlashISI=.032; % 2 frames at 60 Hz
Parameters.FirstOnset=.75; %750ms slack

Parameters.y_Offset=20; %y offset of disk in pixels
Parameters.Disk_Distance=3; %that many disk diameters they will be apart

Parameters.ShadePriors=0; %no shade priors as default




%% Initialize

%SetupKeyCodes;
KeyCodes.Numbers=30:39;
KbName('UnifyKeyNames');

% % ptb
 Rect=Parameters.Rect;
 Win=Parameters.Win;
 
Parameters.Illusion=1; %default - extra beep is ON

PremParameters.free=Parameters.free;
PremParameters.Condition=Parameters.Condition;
PremParameters.Illusion=Parameters.Illusion;
    


% Spiderweb coordinates
[Ix Iy] = pol2cart([0:30:330]/180*pi, Parameters.Fixation_Width(1));
[Ox Oy] = pol2cart([0:30:330]/180*pi, Rect(3)/2);
Rc = Rect(3) - Parameters.Fixation_Width(2);
Sc = round(Rc / 10);
Wc = Parameters.Fixation_Width(2) : Sc : Rect(3);
Wa = round(Parameters.Spider_Web * 255);


%prepare beep
freq=3500;
duration =.02;
sampleFreq = 44100;
dt = 1/sampleFreq;
t = [0:dt:duration];
beep=sin(2*pi*freq*t);
beep=[beep;beep];%needs to be stereo
%now use psychportaudioto fill buffer
device = PsychPortAudio('Open', [], Parameters.AudioPriority);%'mode' flag: 1 (only playback), 'reglatencyclass' flag to demand high priority 
PsychPortAudio('FillBuffer' ,device, beep);



% Parameters.Rect=Rect;
% Parameters.Win=Win;


    

%% trial loop
while Parameters.NoAbort
    %% variable paramsParameters
    Parameters.StimOnsets=[Parameters.FirstOnset:(Parameters.FlashDur+Parameters.FlashISI):Parameters.FirstOnset+((Parameters.FlashDur+Parameters.FlashISI)*(Parameters.Condition))];
    Parameters.TrialDur=max(Parameters.StimOnsets)+.75;% trial duration in seconds - stimuli plus 750 ms slack at end
    Parameters.Disk_Width=50*Parameters.free/2; %width of disk in pixels
    
    if exist('StimTex')
        clear('StimTex');
        clear('FixTex');
    end
    
    % fixation
    FixTex=Screen('OpenOffScreenWindow', Win);
    %draw fixation dot
    Screen('FillOval', FixTex, [0 0 127], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect)); 
    % Overlay spiderweb
    if Wa > 0
        for s = 1:length(Ix)
            Screen('DrawLines', FixTex, [[Ix(s);Iy(s)] [Ox(s);Oy(s)]], 1, [0 0 0 Wa], Rect(3:4)/2);
        end
        for s = Wc
            Screen('FrameOval', FixTex, [0 0 0 Wa], CenterRect([0 0 s s], Rect));
        end
    end

    
    %prepare stimtex accordingly
    for i=1:Parameters.Condition
        [StimTex{i}, Rect]=Screen('OpenOffScreenWindow', Win);
        %draw fixation dot
        Screen('FillOval', StimTex{i}, [], CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect)); 
        % Overlay spiderweb
        if Wa > 0
            for s = 1:length(Ix)
                Screen('DrawLines', StimTex{i}, [[Ix(s);Iy(s)] [Ox(s);Oy(s)]], 1, [0 0 0 Wa], Rect(3:4)/2);
            end
            for s = Wc
                Screen('FrameOval', StimTex{i}, [0 0 0 Wa], CenterRect([0 0 s s], Rect));
            end
        end

        %now draw disk - it wanders downwards along vertical meridian in steps
        %of 1.5 times it's diameter
        
        if Parameters.Condition>1
            if Parameters.ShadePriors
                for Counter2=1:Parameters.Condition+1
                    Screen('FillOval',StimTex{i},[0.9 0.9 0.9]*255,(OffsetRect((CenterRect([0 0 Parameters.Disk_Width Parameters.Disk_Width],Rect)),0,Parameters.y_Offset+(Parameters.Disk_Width*Parameters.Disk_Distance*Counter2))));
                    Screen('FillOval',FixTex,[0.9 0.9 0.9]*255,(OffsetRect((CenterRect([0 0 Parameters.Disk_Width Parameters.Disk_Width],Rect)),0,Parameters.y_Offset+(Parameters.Disk_Width*Parameters.Disk_Distance*Counter2))));
                end
            end
            if i>1
                Screen('FillOval',StimTex{i},[0 0 0]*255,(OffsetRect((CenterRect([0 0 Parameters.Disk_Width Parameters.Disk_Width],Rect)),0,Parameters.y_Offset+(Parameters.Disk_Width*Parameters.Disk_Distance*(i+1)))));
            else
                Screen('FillOval',StimTex{i},[0 0 0]*255,(OffsetRect((CenterRect([0 0 Parameters.Disk_Width Parameters.Disk_Width],Rect)),0,Parameters.y_Offset+(Parameters.Disk_Width*Parameters.Disk_Distance*i))));
            end
        else
            Screen('FillOval',StimTex{i},[0 0 0]*255,(OffsetRect((CenterRect([0 0 Parameters.Disk_Width Parameters.Disk_Width],Rect)),0,Parameters.y_Offset+(Parameters.Disk_Width*Parameters.Disk_Distance*i))));
        end
        
    end

    StartTrialTime=getsecs;
    
    %initialise counters
    CurrFrame=0;
    BeepNo=0;
    FlashNo=0;
    

    
    %% frame loop
    while (getsecs-StartTrialTime)<Parameters.TrialDur && Parameters.NoAbort==1
        CurrFrame=CurrFrame+1;
        
        

        if sum((Parameters.StimOnsets-(getsecs-StartTrialTime))>0 & (Parameters.StimOnsets-(getsecs-StartTrialTime))<Parameters.FlashDur)
            Screen('DrawTexture', Win, FixTex); %fix
            
            %flash
            if FlashNo<Parameters.Condition
                FlashNo=find((Parameters.StimOnsets-(getsecs-StartTrialTime))>0 & (Parameters.StimOnsets-(getsecs-StartTrialTime))<Parameters.FlashDur);
                
                Screen('DrawTexture', Win, StimTex{FlashNo}); %stim
                
            end

            %beep - 
            if  BeepNo<find((Parameters.StimOnsets-(getsecs-StartTrialTime))>0 & (Parameters.StimOnsets-(getsecs-StartTrialTime))<Parameters.FlashDur);%there's one more onset that value of Condition - and that one's used for beep only (no flash)
%                 if BeepNo>=1%Parameters.Condition
                    if Parameters.Illusion
                        BeepNo=find((Parameters.StimOnsets-(getsecs-StartTrialTime))>0 & (Parameters.StimOnsets-(getsecs-StartTrialTime))<Parameters.FlashDur);
                        PsychPortAudio('Start',device);
                    end
%                 else
%                     BeepNo=find((Parameters.StimOnsets-(getsecs-StartTrialTime))>0 & (Parameters.StimOnsets-(getsecs-StartTrialTime))<Parameters.FlashDur);
%                     PsychPortAudio('Start',device);
%                 end
            end

        else
            Screen('DrawTexture', Win, FixTex); %fix
        end  
        Screen('Flip', Win);

        %% update keyread (and OutArg accordingly)
        [Keypr KeyTime Key] = KbCheck;
        if Keypr 
            %Key=find(Key);
            if Key(KbName('ESCAPE')); %escape -> abort
                Parameters.NoAbort=0;
            elseif mean(Key(KeyCodes.Numbers)); %if a number was pressed
                if (find(Key)-29)>0
                    PremParameters.Condition=find(Key)-29;
                end
            elseif Key(KbName('UpArrow'));
                PremParameters.free=Parameters.free+1;
            elseif Key(KbName('DownArrow'));
                if PremParameters.free>1
                    PremParameters.free=Parameters.free-1;
                end
            elseif Key(KbName('LeftArrow'));
                PremParameters.Illusion=1;
            elseif Key(KbName('RightArrow'));
                PremParameters.Illusion=0;    
            end

        end
    end
   %now effectively update parameters (if you do it earlier it will try to do it in the ongoinf trial which is no good)
    Parameters.free=PremParameters.free;
    Parameters.Condition=PremParameters.Condition;
    Parameters.Illusion=PremParameters.Illusion;
end

OutArg=Parameters;



end

