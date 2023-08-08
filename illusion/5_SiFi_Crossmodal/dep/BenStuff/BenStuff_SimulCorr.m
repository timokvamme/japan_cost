function [ x,y,Corr ] = BenStuff_SimulCorr( r, e, n, m1, m2, s1, s2  )
%[ x,y,Corr ] = BenStuff_SimulCorr( r, [e], [n], [m1], [m2], [s1], [s2]  )
%   simulate datasets with defined correation
%
%   r: desired correlation
%   e: tolerated deviation of r (defaults to <.05)
%   n: sample size (defaults to 50)
%   m1: mean of sample 1 (defaults to 0)
%   m2: mean of sample 2 (defaults to 0)
%   s2: standard deviation of sample 1 (defaults to 1)
%   s2: standard deviation of sample 2 (defaults to 1)
%
%   x: vector containing dataset 1
%   y: vector containing dataset 2
%   Corr: actual correlation
%
%   stolen from http://stats.stackexchange.com/questions/32169/how-can-i-generate-data-with-a-prespecified-correlation-matrix 
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 3/2015
%




%% defaults
if nargin<2
    e=.05;
end

if nargin<3
    n=50;
end

if nargin<4
    m1=0;
end

if nargin<5
    m2=0;
end

if nargin<6
    s1=1;
end

if nargin<7
    s2=1;
end

Error=1;
while Error>=e
    
    u=randn(1,n);
    v=randn(1,n);
    x=s1*u+m1;
    y=s2*(r*u+sqrt(1-r^2)*v)+m2;

    Corr=corr(x',y');
    Error=abs(Corr-r);
end

end

