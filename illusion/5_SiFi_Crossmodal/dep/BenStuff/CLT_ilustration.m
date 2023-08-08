function BenStuff_CLT(SampleSize, NumSamples, PopDist)
% BenStuff_CLT([SampleSize], [PopDist], [NumSamples])
% ilustration of the central limit theorem  
%
%   SampleSize:  sample size - who would have thought? defaults to 20
%   NumSamples: number of samples drawn for the bootstrap. defaults to 10k
%   PopDist: here you can specify a population distribution. Options are
%           'normal', 'uniform', 'bimodal', 'skewed'. 
%            Alternatively you can pass a 
%            vector containing the population values of any distribution
%
% cf. http://www.youtube.com/watch?v=ermii2fQWOo
%
% found a bug? please let me know: benjamindehaas@gmail.com
%
%

clc; 
clear all;
close all;

if nargin <3 || PopDist==[]
     PopDist='uniform';
end

if nargin<2 || NumSamples==[]
    NumSamples=10000;
end

if nargin<1 || SampleSize==[]
    SampleSize=20;
end


if isstring(PopDist)
    if strcmp(PopDist, 'uniform')
        Pop=rand(1,100000); 
    elseif strcpm(PopDist, 'bimodal')
        Y1=randn(1, 50000);
        Y2=randn(1, 50000)+5;
        Pop=[Y1, Y2];
    elseif strcmp(PopDist, 'normal')
        Pop=randn(1,100000); 
    elseif strcmp(PopDist, 'skewed')
        Pop=pearsrnd(0,1,-.5,3,100000,1);
    end
end

for i=1:NumSamples
    Sample=randsample(Pop, SampleSize);
    Means(i)=mean(Sample);
end

%Population distribution
figure; hold on;
hist(Pop, 100);
title('Ugly Population Distribution', 'FontSize', 14, 'FontWeight', 'b');
set(gca, 'FontSize', 14, 'FontWeight', 'b');
xlabel('Parameter Value');
ylabel('Number of Occurences');


%histogram w fitted normal
figure;
histfit(Means, 100, 'normal');
title('Beautiful Sampling Distribution', 'FontSize', 14, 'FontWeight', 'b');
set(gca, 'FontSize', 14, 'FontWeight', 'b');
xlabel('Parameter Value');
ylabel(['Number of Sample Means (n=' num2str(SampleSize) ')']);

