function NormX = BenStuff_Normalise( X)
% [ NormX ] = BenStuff_NormaliseBy( X )normalise X to a [0 1] range
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 25/8/2014

X=X-min(X(:));
X=X/max(X(:));
NormX=X;

end

