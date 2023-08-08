function BenStuff_Wichtel(test)
%   BenStuff_Wichtel(test)
%
%   de Haas family Wichtelei - test defaults to 1 and will result in all e-mails being
%   sent to benjamindehaas@gmail.com

rng('shuffle');

if nargin<1
    test=1;
end

Schenker={'Ricky & Maria', 'Benny & Simone', 'Oems', 'Sammy & Domenica'};
if ~test
    emails={'maria.de.haas@web.de', 'benjamindehaas@gmail.com', 'naomi.de.haas@googlemail.com', 'samuel.de-haas@wirtschaft.uni-giessen.de'};
else
    for i=1:length(Schenker)
        emails(i)={'benjamindehaas@gmail.com'};
    end
end
Beschenkte=Schenker;


isgood=0;

while ~isgood 
    isgood=1;
    Beschenkte=datasample(Beschenkte, length(Beschenkte), 'replace', false);
    for i=1:length(Schenker)
        if strcmp(Schenker(i),Beschenkte(i))
            isgood=0;
        end
    end
end


for i=1:length(Schenker)
    BenStuff_SpamMe( emails(i), 'Wichtelei Weinachten 2015', ['Der de-Haas-Wichtel-o-mat sagt ' Schenker(i) ' bewichtelt dieses Jahr ' Beschenkte(i) 'p.s.: Richtwert sind 20 Euro - Froehliche Weihnachten, Allemann!'] );
end



