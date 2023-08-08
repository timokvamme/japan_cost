function [ h, p, ZPF, r1A, r2B ] = BenStuff_OneSampleCorrCompD( P1, C1, P2, C2, alpha)
%[ h, p, ZPF, r1A, r2B ] = BenStuff_OneSampleCorrCompD( P1, C1, P2, C2, [alpha])
%   
%   
%   Compare r between P1 and C1 with r between P2 and C2 (nonoverlapping r's from one sample (i.e. two
%   predictors, two criteria, one sample))
%
%   h: hypothesis: 1 if difference is significant, else 0
%   ZPF: ZPF (Z Pearson-Filion) statistic following Raghunathan et al. 1996
%   p value of difference
%
%   P1/2: Vector containing data for first/second predictor 
%   C1/2: Vector containing data for first/second criterion 
%
%   r1A: correlation between first predictor (1) and first criterion (A)
%   r2B: correlation between second predictor (2) and second criterion (B)
%   
%   
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

if nargin<5
    alpha=.05;
end

P1=P1(:); P2=P2(:); C1=C1(:) ;C2=C2(:); % make sure these are columns 

n=size(P1,1); % determine sample size

% correlations
r1A=corr(P1, C1); 
r2B=corr(P2, C2);

% 'nuissance' covariance 
r12=corr(P1,P2); 
rAB=corr(C1, C2); 
r1B=corr(P1, C2);
r2A=corr(P2, C1);


Z1A=atanh(r1A);%Fisher transformation
Z2B=atanh(r2B);


%% core calculations
k=(r12 - r2A*r1A)*(rAB-r2A*r2B) + (r1B - r12*r2B)*(r2A - r12*r1A)...
    +	(r12 - r1B*r2B)*(rAB - r1B*r1A) + (r1B - r1A*rAB)*(r2A - rAB*r2B);

ZPF=(sqrt((n-3)/2))*(Z1A-Z2B/(sqrt(1-(k/(2*(1-r1A^2)*(1-r2B^2))))));

% conversion to p
CriticalZ=(-erfinv(alpha - 1)) .* sqrt(2); %e.g. 1.96 for alpha=.05 (n is not assumed to be tiny here!)

if abs(ZPF)>CriticalZ
    h=1;
else
    h=0;
end

p=normcdf(-abs(ZPF),0,1)*2;%two-tailed


end

