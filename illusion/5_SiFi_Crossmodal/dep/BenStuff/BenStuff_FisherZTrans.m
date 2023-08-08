function [ zMatrix ] =  BenStuff_FisherZTrans( CorrMatrix )
%[ zMatrix ] =  BenStuff_FisherZTrans( CorrMatrix ) apply Fisher z
% transformation to Matrix of correlation values
%   following Fisher, 1921 (cf. Silver & Dunlap, 1987)
%   Ben de Haas, 3/2012
%   found a bug? please let me know benjamindehaas@gmail.com

zMatrix=atanh(CorrMatrix);% make life easy...
%zMatrix=.5*log((CorrMatrix+1)./(1-CorrMatrix));

end

