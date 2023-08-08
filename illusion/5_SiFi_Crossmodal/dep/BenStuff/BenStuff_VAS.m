function [ ResponseVal, Params ] = BenStuff_VAS( Win, Question, NegPole, PosPole, Polarity)
%[ ResponseVal, Params ] = BenStuff_VAS(Win, Question, NegPole, PosPole, Polarity)
%   function to display visual analog scale in WindowPtr using psychtoolbox
%
%   Win:        Pointer to window opened previously in psychtoolbox
%   Question:   String containing question or statement to be judged
%   NegPole:    Label of negative pole, defaults to 'Strongly disagree'
%   PosPole:    Label of positive pole, defaults to 'Strongly agree'
%   Polarity:   defaults to '+', meaning PosPole is on the right
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 11/2014 
%   
%   (inspired by http://stackoverflow.com/questions/26481064/likert-and-analog-scale-psychtoolbox-matlab)
%

%% variables
if nargin<5
    Polarity='+';
end

if nargin<4
    PosPole='Strongly agree';
end

if nargin<3
    NegPole='Strongly disagree';
end

BenStuff_SetUpRand;
KeyCodes=BenStuff_SetUpKeyCodes;

%PTB
Params.Stamp=BenStuff_PTB_Stamp(Win);
Rect=Params.Stamp.Win.Rect;
Slack=Screen('GetFlipInterval', Win);
[CenterX, CenterY] = RectCenter(Rect);

%settings
PixPerPress=5;
Width=Params.Stamp.Win.Width/2.5;%~half as wide as window
WhiskerLength=20;
LineCol=[0, 0, 0];%black lines
TextCol=[0 0 0];
PenWidth=3;

QFontSize=16;
PFontSize=14;

LeftEnd=CenterX-Width/2;
RightEnd=CenterX+Width/2;
WhiskerUp=CenterY-WhiskerLength/2;
WhiskerLo=CenterY+WhiskerLength/2;

TextHeight=CenterY+WhiskerLength*2;
QuestionHeight=CenterY-WhiskerLength*5;
TextXOffSet=50;

SelRect= [0 0 10 30];%selectionrect
SelRectCol=[0 0 0];%paint it black

%now store it all away
Params.PixPerPress=PixPerPress;
Params.Width=Width;%width in pixels
Params.WhiskerLength=WhiskerLength;
Params.LineCol=LineCol;%black lines
Params.TextCol=TextCol;
Params.PenWidth=PenWidth;
Params.TextHeight=TextHeight;
Params.QuestionHeight=QuestionHeight;
Params.TextXOffSet=TextXOffSet;
Params.SelRect=SelRect;
Params.Slack=Slack;
Params.QFontSize=QFontSize;
Params.PFontSize=PFontSize;
%% Basic texture
BaseWin=Screen('OpenOffScreenWindow', Win);

%write question

Screen('TextSize', BaseWin, QFontSize);
DrawFormattedText(BaseWin, Question ,'center', QuestionHeight, TextCol);

Screen('DrawLine', BaseWin, LineCol, LeftEnd, CenterY, RightEnd, CenterY, PenWidth);%horizontal line
Screen('DrawLine', BaseWin, LineCol, LeftEnd, WhiskerUp, LeftEnd, WhiskerLo, PenWidth);%left whisker
Screen('DrawLine', BaseWin, LineCol, RightEnd, WhiskerUp, RightEnd, WhiskerLo, PenWidth);%left whisker

%label poles
Screen('TextSize', BaseWin, PFontSize);
if strcmp(Polarity, '+')
    Screen('DrawText', BaseWin, NegPole, LeftEnd-TextXOffSet, TextHeight,TextCol);
    Screen('DrawText', BaseWin, PosPole, RightEnd-TextXOffSet, TextHeight,TextCol);
else
    Screen('DrawText', BaseWin, PosPole, LeftEnd-TextXOffSet, TextHeight,TextCol);
    Screen('DrawText', BaseWin, NegPole, RightEnd-TextXOffSet, TextHeight,TextCol);
end

%initise window
CurrVal=0;
CurrX=CenterX+CurrVal;
CurrSelRect=CenterRectOnPoint(SelRect, CurrX, CenterY);
Screen('DrawTexture', Win, BaseWin);
Screen('FillRect', Win, SelRectCol,CurrSelRect);
Screen('Flip', Win);

%% loop
Active=1;
LastFrame=0;

KbWait([], 2);%ensure no key is pressed

while Active
    [Foo, Foo, Key ] = KbCheck;
    Key=find(Key);
    if Key==KeyCodes.Esc
        Screen('Flip', Win);
        Params.ABORTED=1;
        ResponseVal=CurrVal/(Width/2);%normalise
        if strcmp(Polarity, '-')
            ResponseVal=-ResponseVal;
        end
        display(['Aborted by user at value: ' num2str(ResponseVal)]);
        ResponseVal=NaN;
        Active=0;
    elseif Key==KeyCodes.Left
        CurrVal=CurrVal-PixPerPress;
    elseif Key==KeyCodes.Right
        CurrVal=CurrVal+PixPerPress;
    elseif Key==KeyCodes.Space
        SelRectCol=[255 0 0];% red flash when selected
        LastFrame=1;
        Params.ABORTED=0;
        ResponseVal=CurrVal/(Width/2);%normalise
        if strcmp(Polarity, '-')
            ResponseVal=-ResponseVal;
        end
        display(['User selected value: ' num2str(ResponseVal)]);
    end
    
    if CurrVal<-Width/2%cap values
        CurrVal=-Width/2;
    elseif CurrVal>Width/2
        CurrVal=Width/2;
    end
    
    
    %actual drawing
    CurrX=CenterX+CurrVal;
    CurrSelRect=CenterRectOnPoint(SelRect, CurrX, CenterY);
    Screen('DrawTexture', Win, BaseWin);
    Screen('FillRect', Win, SelRectCol,CurrSelRect);
    Screen('Flip', Win);
    
    if LastFrame
        WaitSecs(.5);
        Active=0;
        Screen('Flip', Win);
    end
end%while active


end

