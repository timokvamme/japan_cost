function [ X_Normalised ] = BenStuff_NormaliseCols( X )
%[ X_Normalised ] = BenStuff_NormaliseCols( X )
%   normalise 2-D matrix X column-wise to [0 1] range
%   puts NaN where max is zero 
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 2/2015
%

if nargin<1
    error('Please provide an input matrix!');
elseif nargin>1
    error('Please provide only one input argument!');
end

if ndims(X)~=2
    error(['Please ensure input variable is a 2-D Matrix!']);
end

X_Normalised=X - repmat(min(X), size(X,1), 1);
Max = max(X_Normalised);
Max(Max==0) = NaN;
X_Normalised=X_Normalised./repmat(max(X_Normalised), size(X,1), 1);

end

