function [ CorrMatrix ] =  BenStuff_FisherZTransInv( ZCorrMatrix )
%[ ZCorrMatrix ] =  BenStuff_FisherZTransInv( CorrMatrix ) retransform Fisher z
%values to Matrix of correlation values
%   following Fisher, 1921 (cf. Silver & Dunlap, 1987)
%   Ben de Haas, 3/2012
%   found a bug? please let me know benjamindehaas@gmail.com

CorrMatrix=tanh(ZCorrMatrix);% make life easy...

end

