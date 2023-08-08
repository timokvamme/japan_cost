function Results = EnquireDemographics( Results )
%Results = EnquireDemographics( Results )

Results.Age = input('Alter?');
Results.Handedness = input('links- (l) oder rechts (r) haendig?', 's');
Results.Sex = input('Geschlecht (m/w/a)?', 's');
Results.CorrectedVision = input('Sehhilfe?', 's');



end

