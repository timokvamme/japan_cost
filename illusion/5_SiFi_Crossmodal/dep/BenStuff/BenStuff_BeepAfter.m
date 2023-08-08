function BenStuff_BeepAfter( NumSecs )
%BenStuff_BeepAfter( NumSecs )
%   Timer that beeps after NumSecs seconds
%

StartTime = GetSecs;

Dur = 0;
while Dur < NumSecs 
    Dur = GetSecs - StartTime;
end 

if ~(Dur < NumSecs)
    disp(Dur);
    beep;
end 

end

