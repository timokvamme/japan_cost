function [ GG_AdjustedP, AdjustedDF_Cond, AdjustedDF_Res, F, GG_Epsilon, p, Anova_Table ] = BenStuff_NonSphericityAdjustedP( Data )
%[  GG_AdjustedP, AdjustedDF_Cond, AdjustedDF_Res, F, GG_Epsilon, p, Anova_Table ] = BenStuff_NonSphericityAdjustedP( Data, F )
%   gives p value according to greenhouse geisser corrected degrees of
%   freedom - uses Matlab central Funcitons epsGG to derive epsilon (Matlab central function)
%   use anova_rm to get F value
%   
%   found a bug? please let me know: benjamindehaas@gmail.com

[Anova_p, Anova_Table]=anova_rm(Data);%do ANOVA
DF_Cond=Anova_Table{2,3};%retrieve degrees of freedom
DF_Res=Anova_Table{4,3};
F=Anova_Table{2,5};
p=Anova_Table{2,6};

GG_Epsilon=epsGG(Data);%epsilon

AdjustedDF_Cond=DF_Cond*GG_Epsilon;%adjust degrees of freedom
AdjustedDF_Res=DF_Res*GG_Epsilon;

GG_AdjustedP=1-fcdf(F, AdjustedDF_Cond, AdjustedDF_Res);



end

