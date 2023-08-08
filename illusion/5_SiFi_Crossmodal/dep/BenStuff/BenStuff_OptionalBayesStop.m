%% BenStuff_OptionalBayesStop

% let's test whether social priming works (e.g. walking speed difference
% between 'old' and 'young' primed folks);
% let's assume we can publish a BF >3, i.e. 'substantial evidence'

PriorMean=.5;%prior distribution (p(population value|theory))
PriorSD=1;

%initialise
BF=1;
n=0;
DiffSample=[];
BayesFactors=[];
Ns=[];
Means=[];

while BF<3 && n<10^3
   n=(n+2);%we assume a between design
   DiffSample=[DiffSample, randn(1)];%add random difference
   Means=[Means,mean(DiffSample)];
   BF=BenStuff_DienesBF(mean(DiffSample),std(DiffSample),0,[],[],PriorMean, PriorSD);
   if isnan(BF)
       BF=1;%default if neccesary
   end
       
   BayesFactors=[BayesFactors, BF];
   Ns=[Ns,n];
end

if BF<3 
    display(['No luck this time; BF after ' num2str(n) ' participants is ' num2str(BF)]);
else
    display(['Hooray! We got a paper!; BF after ' num2str(n) ' participants is ' num2str(BF)]);
end

figure;
plot(Ns, BayesFactors);
xlabel('number of participants');
ylabel('BayesFactor');

figure;
plot(Ns, Means);
xlabel('number of participants');
ylabel('SampleMean');


