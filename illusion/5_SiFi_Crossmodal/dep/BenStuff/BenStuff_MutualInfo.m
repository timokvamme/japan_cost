function [ I, Hstim, Hcond, ScaledI ] = BenStuff_MutualInfo(nStim, ClassifierAccuracy)
%[ I, Hstim, Hcond ] = BenStuff_MutualInfo(nStim, ClassifierAccuracy) 
%
% calculates mutual information between (equiprobable!) stimuli 
% and measured responses in a quick n dirty fashion
%
% quick n dirty calculation of mutual
% information between stimuli and measured responses 
% (e.g. labels retrieved from classifying neural activation patterns
% obtained using fMRI MVPA and machine learning algorithms)
% 
% nStim: number of (equiprobable!) stimuli to decode
% ClassifierAccuracy: probability of classification being accurate (0-1)
%
% Hstim: Stimulus entropy in bits
% Hcond: Stimulus entropy in bits, given a response 
% I: Mutual information between stimuli and response in bits (Hstim-Hcond)
% ScaledI:0 is no mutual information, 1 is exhaustive mutual information
%
% !!!!ASSUMPTIONS THAT MAY OR MAY NOT BE VALID!!!!!!
% - flat stimulus frequency distribution 
%   (i.e. equal probabilities across stimuli)
% - flat response frequency distribution 
%   (i.e. equal probabilities across label answers obtained)
% - flat error frequency distribution
%   (i.e. unbiased misclassifications; 
%   if a wrong label is assigned it is equally likely to be any of the 
%   wrong labels;
%   note that violations of this assumption can only yield
%   *under*estimation of I, i.e. we err on the conservative side) 
%
% IF YOU'D PREFER AVOIDING THESE: 
% provide correct labels and classifications to MutualInformation.m, 
% as found here: 
% http://www.mathworks.com/matlabcentral/fileexchange/28694-mutual-information  
%   
%
% Follows definitions as found in Panzeri & Ince, 2012 
% ('Visual Population Codes', pp. 568f)
% 
% all BS? found a bug? please let me know: benjamindehaas@gmail.com
%
% Ben de Haas  2/2012
P_Stim=1/nStim;% equiprobable stimuli

Hstim=-log2(P_Stim); % because Hstim=-nStim*(Pstim*log2(Pstim)) for equiprobable stimuli
Hcond=-log2(ClassifierAccuracy); % again, summating over equiprobable stimuli and labels simply drops 

I=Hstim-Hcond; 

ScaledI=I/Hstim; %normalized to 0-1 scale: 0 is no mutual information, 1 is exhaustive mutual information
end

