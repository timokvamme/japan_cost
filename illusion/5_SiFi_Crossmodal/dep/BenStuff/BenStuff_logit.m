function [ LogitTrafos ] = BenStuff_logit( p )
%[ LogitTrafos ] = BenStuff_logit( p ) tiny function for logit
%transformation
%   p - vector containing values between 0 and 1 (typically probabilities)
%   LogitTrafos - logit transformation of p [.5*(log(p./(1-p)))]
%   equation according to Ashburner & Friston, 2000 (Wiki doesn't have the .5*)

LogitTrafos=.5*log(p./(1-p));


end

