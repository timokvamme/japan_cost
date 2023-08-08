function BenStuff_tspitter(X)
%BenStuff_tspitter(X,Y) convenient function to echo descriptives plus
%t-test against 0 for a vector

Mean=mean(X)
SEM=sem(X')
Median=median(X)
[H,P,CI,tstat]=ttest(X)


end

