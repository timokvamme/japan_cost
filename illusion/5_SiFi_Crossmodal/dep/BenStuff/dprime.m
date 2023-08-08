function dPrime = dprime( pHit,pFA )
%dPrime = dprime( pHit,pFA )
%   Another tiny, convenient one matlab could well provide..
% assumes pHit and pFA to be neither 1 nor 0 - apply Snodgrass & Corvin
% correction if neccesary...
%
%   found a bug? please let me know: benjamindehaas@gmail.com

dPrime=norminv(pHit)-norminv(pFA);

end

