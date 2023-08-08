function [t,p] = BenStuff_TfromR( r, n, partial )
%t = BenStuff_TfromR( r, n, partial ) calculate t value for Pearson's r
%   t: t-value for null hypothesis (rho=0)
%   p: associated p-value
%   r: Pearson's product moment correlation coefficient
%   n: sample size
%   partial: optional argument, if set to 1 assumes r is a partial
%   correlation coefficient and will adjust degrees of freedom accordingly
%
%   cf. eg. Wetzels & Wagenmakers 2012, psychom bull rev 

if nargin<3
    partial=0;
end

if partial
    df=n-3;
else
    df=n-2;
end

t=r*sqrt(df/(1-r^2));
if t<0
    p=tcdf(t,df).*2; %two-sided p-value
else
    p=(1-tcdf(t,df)).*2;
end
    


end

