function [ x,y] = BenStuff_SimCorr( r,n, tolerance )
%[ x,y] = BenStuff_SimCorr( r,n )
%   function to simulate correlated data
%
%   r: desired correlation 
%   n: desired sample size (assumes reasonable size, defaults to 10^3)
%   x: feature 1
%   y: feature 2
%   tolerance: tolerated margin of r - defaults to 10%
%
%   c.f. https://www.mathworks.co.uk/matlabcentral/newsreader/view_thread/174179
%   
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 01/14
%

if nargin<2
    n=10^3;
end

if nargin<3
    tolerance=.1;
end

IsBad=1;

while IsBad 
    x = randn(n,1);%two random vectors
    z = randn(n,1);

    k=sqrt((1/r^2)-1);
    y = x + k*z;%third vector correlated with x
    y=y-mean(y);%zscore
    y=y/std(y);

    if corr(x,y)>r*(1+tolerance) || corr(x,y)<r*(1-tolerance)
        IsBad=1;
    else
        IsBad=0;
    end
end

display(['desired r was ' num2str(r) ' - actual r is ' num2str(corr(x,y)) ' which is fair enough']);



end

