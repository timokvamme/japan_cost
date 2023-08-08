function [ X_MeanCentered ] = BenStuff_MeanCenterCols( X, MedianFlag )
%[ X_MeanCentered ] = BenStuff_MeanCenterCols( X, MedianFlag )
%   mean centers 2-D matrix X column-wise
%
%   MedianFlag defaults to 0, if set to 1 will center on median instead of mean of columns
%
%   there might be cleverer or native Matlab solutions for this - this was
%   coded offline (onboard an airplane)
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 2/2015
%
%   bdh 10/2017: added MedianFlag and nan compatibility, 
%                noted this becomes kind of obsolete from Matlab 2016b
%

if nargin < 1
    error('Please provide an input matrix!');
elseif nargin > 2
    error('Please provide only two input arguments!');
end

if nargin < 2
    MedianFlag = 0;
end
    

if ndims(X)~=2
    error('Please ensure input variable is a 2-D Matrix!');
end

if MedianFlag 
    X_MeanCentered=X-repmat(nanmedian(X),size(X,1),1);
else
    X_MeanCentered=X-repmat(nanmean(X),size(X,1),1);
end

end

