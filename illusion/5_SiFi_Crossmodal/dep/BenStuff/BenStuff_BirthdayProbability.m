function BenStuff_BirthdayProbability( NumPeople )
%BirthdayProbability( NumPeople ) Illustrates probability of >=1 common
%birthday in a group of NumPeople


pNone=1;% initialise probability of no coincidence
for i=1:NumPeople
    pNone=pNone*((366-i)/365);
    pNoneVector(i)=pNone;
end

pMinOne=1-pNone;
pMinOneVector=1-pNoneVector;

display(['The probability of a minimum of one birthday coincidence among ' num2str(NumPeople) ' people is ' num2str(pMinOne) '\n also check out the figure' ]);

figure; hold on;
plot(pMinOneVector*100, 'linewidth', 2);
set(gca, 'fontsize', 15);
title('Wahrscheinlichkeit min. einer Geburtstagsdopplung');
xlabel('Anzahl der Personen');
ylabel('Wahrscheinlichkeint (in %)')
hold off;




end

