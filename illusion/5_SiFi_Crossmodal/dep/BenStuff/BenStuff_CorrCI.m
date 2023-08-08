function [ LoR, HiR ] = BenStuff_CorrCI( r,n, alpha)
%[ LoR, HiR ] = BenStuff_CorrCI( r,n, alpha) 
% Provides confidence interval for pearson's r
%   LoR: Lower bound for r
%   HiR: Higher bound for r
%   r: pearson's r
%   n: number of observed pairs
%   alpha: alpha level (defaults to .05)

%   Equations nicked from corrcoef.m and wiki (23/2/2012: ...
%   http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient#Confidence_Intervals)
%
%   CIs are estimated according using Fisher's Transformation
%   They will become more asymmetric for large r and small n
%   cf. 
%   en.wikipedia.org/wiki/Fisher_transformation
%   http://pj.freefaculty.org/stat/lectures/08-ConfIntervals-lecture.pdf
%   http://www.jstor.org/stable/2331838 - Fisher, 1915 - to really do your
%   head in...
%   
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 2/2012

if nargin<3
    alpha=.05;
end

z = atanh(r);%Fisher transformation
se=1./sqrt(n-3);%standard error of fisher transformed r
CriticalZ=(-erfinv(alpha - 1)) .* sqrt(2); %e.g. 1.96 for alpha=.05 (n is not assumed to be tiny here!)
CriticalZ=CriticalZ.*se;%critical Fisher transformed value

LoZ=z-CriticalZ;% lower and upper bound for fisher tranformed r
HiZ=z+CriticalZ;

LoR=tanh(LoZ);%now convert back to r values
HiR=tanh(HiZ);



end

