function [ Posterior, BF ] = BenStuff_p2Bayes( p )
%[ Posterior, BF ] = BenStuff_p2Bayes( p )
%  following equation 11 in Sellke et al., 2001 The American Statistician
%  
%   found a bug? please let me know!
%   benjamindehaas@gmail.com

if length(p)>1
    error('sorry, only scalar input');
end
if p>1 || p<0
    error('impossible p-value!');
end

if p<=.382
    Posterior=1-(1/(1+.5/sqrt(p)));
else
    Posterior=(1/(1+2*sqrt(p)));
end

BF=Posterior/(1-Posterior);


end

