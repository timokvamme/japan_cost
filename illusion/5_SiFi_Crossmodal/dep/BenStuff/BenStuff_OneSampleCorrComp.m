function [ h, p, ZPF ] = BenStuff_OneSampleCorrComp( r1A, r2B, r12, rAB, r1B, r2A, n, alpha)
%[ h, p, ZPF ] = BenStuff_OneSampleCorrComp( r1A, r2B, r12, rAB, r1B, r2A, n, alpha)
%   Compare r1A with r2B (nonoverlapping r's from one sample (i.e. two
%   predictors, two criteria, one sample))
%
%   h: hypothesis: 1 if difference is significant, else 0
%   ZPF: ZPF (Z Pearson-Filion) statistic following Raghunathan et al. 1996
%   p value of difference
%
%   r1A: correlation between first predictor (1) and first criterion (A)
%   r2B: correlation between second predictor (2) and second criterion (B)
%   
%   THE ABOVE TWO ARE COMPARED... now we need to know about the covariances
%
%   r12: corr between predictors (= rAX in Wuensch's notation)
%   rAB: corr between criteria (= rBY in Wuensch's notation)
%   r1B: corr between first predictor and second criterion (= rAY in Wuensch's notation)
%   r2A: corr between second predictor and first criterion (= rBX in Wuensch's notation)
%   
%   n= number of subjects 
%   alpha: alpha level (defaults to .05)

%   Equations nicked from ...
%   http://core.ecu.edu/psyc/wuenschk/StatHelp/ZPF.docx
%   cf. Raghunathan, Rosenthal, and Rubin (1996, Psychological Methods, 1, 178-183) 
%   
%   Fisher's Transformation is used
%   en.wikipedia.org/wiki/Fisher_transformation
%   http://www.jstor.org/stable/2331838 - Fisher, 1915 - to really do your
%   head in...
%   
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 10/2012

if nargin<8
    alpha=.05;
end


Z1A=atanh(r1A);%Fisher transformation
Z2B=atanh(r2B);

k=(r12 - r2A*r1A)*(rAB-r2A*r2B) + (r1B - r12*r2B)*(r2A - r12*r1A)...
    +	(r12 - r1B*r2B)*(r3A - r1B*r1A) + (r1B - r1A*rAB)*(r2A - rAB*r2B);

ZPF=(sqrt((n-3)/2))*(Z1A-Z2B/(sqrt(1-(k/(2*(1-r1A^2)*(1-r2B^2))))));

CriticalZ=(-erfinv(alpha - 1)) .* sqrt(2); %e.g. 1.96 for alpha=.05 (n is not assumed to be tiny here!)

if abs(ZPF)>CriticalZ
    h=1;
else
    h=0;
end

p=normcdf(-abs(ZPF),0,1)*2;%two-tailed


end

