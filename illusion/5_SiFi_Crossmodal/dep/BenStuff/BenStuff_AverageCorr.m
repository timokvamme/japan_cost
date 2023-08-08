function [ AverageCorr ] = BenStuff_AverageCorr( CorrMatrix,Dim )
%[ AverageCorr ] = BenStuff_AverageCorr( CorrMatrix ) 
%   averages correlation coefficients via Fisher's z transformation
%   (and back), cf. Silver & Dunlap, 1987
%   cf. http://en.wikipedia.org/wiki/Fisher_transformation
%   
%   found a bug? please let me know 
%   benjamindehaas@gmail.com 3/2012
%

if nargin<2
    Dim=1;
end
ZCorrMatrix =  atanh( CorrMatrix ); %do fisher transformation
AverageZ=mean(ZCorrMatrix,Dim);%mean of z values
%AverageCorr=(exp(2*AverageZ)-1)./(exp(2*AverageZ)+1);
AverageCorr=tanh(AverageZ);

end

