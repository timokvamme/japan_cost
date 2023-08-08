function [hVector, p_adj]= BenStuff_HolmBonferroni( pVector, FWE_alpha)
%[hVector, p_adj]= BenStuff_HolmBonferroni( pVector, FWE_alpha)
%   takes a bunch of p-values and determines which of them are significant
%   when the whole lot is FWE corrected to alpha according to the
%   Holm-Bonferroni method
%   
%   Holm, S. (1979) A simple sequentially rejective multiple test procedure. 
%   Scandinavian Journal of Statistics. 6, 65-70.
%
%   adjusted p-values are calculated following en.wikipedia.org/wiki/Holm-Bonferroni_method
%
%   pVector: vector containing the family of p-values
%   FWE_alpha: the family wise error level - defaults to .05
%   
%   hVector: vector indicating whether associated null hypotheses can be
%   refuted (one entry per hypothesis/p-value)
%   p_adj: vector containing adjusted p values
%
%   Example: [NullRefuted, AdjustedPs]=BenStuff_HolmBonferroni( [.04, .01, .002, .03], .05)
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
%


if nargin<2
    FWE_alpha=.05;
end

[pSorted, Indices]=sort(pVector);
m=length(pVector);
hVector=zeros(1,m);%initialise


p_adj=pSorted.*[m:-1:1];

for iTest=2:m
    p_adj(iTest)=max(p_adj(1:iTest));
end
p_adj(p_adj>1)=1;%cap p-values at 1

p_adj(Indices)=p_adj;%sort according to original input

hVector(p_adj<FWE_alpha)=1;

end

