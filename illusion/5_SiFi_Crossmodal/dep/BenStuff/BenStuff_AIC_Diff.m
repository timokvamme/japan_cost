function [AIC_Diff, BIC_Diff] = BenStuff_AIC_Diff( K1, K2, RSS1, RSS2, n1, n2)
%[AIC_Diff, BIC_Diff] = BenStuff_AIC_Diff( Model1K, Model2K, Model1RSS, Model2RSS, n1, n2)
%   calculates the difference in the Akaike Information Criterion between
%   two models fitted to the same data (model1 - model2).
%
%   the model with lower score is to be preferred, a difference from about
%   4 is considered significant. optionally the difference in bayesian
%   information criterion is given as well. BIC tends to penalise additional
%   parameters more than AIC.
%   
%   K1: number of fitted paramters of the first model
%   K2: number of fitted parameters of the second model  
%   RSS1: residual sum of squares for model 1
%   RSS2: residual sum of squares for model 2
%   n1: size of sample 1
%   n2: size of sample 2
%  
%   nicked from wiki: 
%   http://en.wikipedia.org/wiki/Akaike_information_criterion c.f. http://www.researchgate.net/post/What_is_the_AIC_formula
%   http://en.wikipedia.org/wiki/Bayesian_information_criterion BEWARE -
%   this might be wrong, check out discussion page on wiki
%
%   found a bug?
%   please let me know: benjamindehaas@gmail.com


%% Calculate AICs (note that this will be offset by a constant - which doesn't matter for comparison)

AIC1=n1.*log(RSS1./n1)+2.*K1;
AIC1=AIC1+(2.*K1.*(K1+1))./(n1-K1-1);%correction for finite sample size

BIC1=n1.*log(RSS1./(n1-1))+K1.*log(n1);

AIC2=n2.*log(RSS2./n2)+2*K2;
AIC2=AIC2+(2.*K2.*(K2+1))./(n2-K2-1);%correction for finite sample size

BIC2=n2*log(RSS2./(n2-1))+K2.*log(n2);

%% Calculate Difference
AIC_Diff=AIC1-AIC2;

BIC_Diff=BIC1-BIC2;

end