function [y,Corr ] = BenStuff_SimulCorrData( x, r, e, m, s)
%[ y,Corr ] = BenStuff_SimulCorrData(x, r, [e], [m], [s] )
%   simulate a dataset correlated with datavector x to a defined degree
%
%   x: input data
%   r: desired correlation
%   e: tolerated deviation of r (defaults to <.05)
%   m: desired mean of output (defaults to 0)
%   s: desired standard deviation of output (defaults to 1)
%
%   y: output data correlated with x
%   Corr: actual correlation
%
%   adapted from http://stats.stackexchange.com/questions/32169/how-can-i-generate-data-with-a-prespecified-correlation-matrix 
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 3/2015
%




%% defaults
if nargin<3
    e=.05;
end

if nargin<4
    m=0;
end

if nargin<5
    s=1;
end

%% here stuff happens
Error=1;
while Error>=e
    u=(x-mean(x))./std(x);%zscore
    v=randn(1,length(x));
 
    y=s*(r*u+sqrt(1-r^2)*v)+m;

    Corr=corr(x',y');
    Error=abs(Corr-r);
end

end

