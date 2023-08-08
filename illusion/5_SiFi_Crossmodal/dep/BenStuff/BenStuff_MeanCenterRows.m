function [ X_MeanCentered ] = BenStuff_MeanCenterRows( X )
%[ X_MeanCentered ] = BenStuff_MeanCenterRows( X )
%   mean centers 2-D matrix X row-wise
%
%   there might be cleverer or native Matlab solutions for this - this was
%   coded offline (onboard an airplane)
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 2/2015
%
%   bdh 9/2016:  mean(X,2) is indeed correct and giving the row-wise means

if nargin<1
    error('Please provide an input matrix!');
elseif nargin>1
    error('Please provide only one input argument!');
end

if ndims(X)~=2
    error('Please ensure input variable is a 2-D Matrix!');
end

X_MeanCentered=X-repmat(mean(X,2),1,size(X,2));

end

