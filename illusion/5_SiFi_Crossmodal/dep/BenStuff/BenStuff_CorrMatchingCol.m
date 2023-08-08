function [ r ] = BenStuff_CorrMatchingCol(X,Y)
%[ r ] = BenStuff_CorrMatchingCol(X,Y)
%   only correlate matching columns of X and Y (X(:,1) with Y(:,1) and so forth)
%   ~100 times faster than combining corr with diag 
%   kudos to http://stackoverflow.com/questions/9262933/what-is-a-fast-way-to-compute-column-by-column-correlation-in-matlab
%
% found a bug? please le me know!
% benjamindehaas@gmail.com 12/14
%

Xn=bsxfun(@minus,X,mean(X,1));
Yn=bsxfun(@minus,Y,mean(Y,1));
Xn=bsxfun(@times,Xn,1./sqrt(sum(Xn.^2,1)));
Yn=bsxfun(@times,Yn,1./sqrt(sum(Yn.^2,1)));
r=sum(Xn.*Yn,1);

end

