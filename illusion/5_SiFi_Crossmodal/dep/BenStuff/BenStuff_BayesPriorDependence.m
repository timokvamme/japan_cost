%% BenStuff_BayesPriorDependence

% let's test dependence of BF on prior distribution

PriorMean=1;%prior distribution (p(population value|theory))
PriorSD=0;
PriorSDs=[];
BayesFactors=[];
BayesFactors_uniform=[];

for n=1:10^3
    PriorSD=PriorSD+.01;
    PriorSDs=[PriorSDs, PriorSD];
    
    DiffSample=randn(1000,1);

    BF=BenStuff_DienesBF(mean(DiffSample),std(DiffSample),0,[],[],PriorMean, PriorSD);
    BayesFactors=[BayesFactors,BF];

    BF_uniform=BenStuff_DienesBF(mean(DiffSample),std(DiffSample),1,-2*PriorSD+PriorMean,+2*PriorSD+PriorMean);
    BayesFactors_uniform=[BayesFactors_uniform,BF_uniform];
end



figure; hold on;
plot(PriorSDs, BayesFactors);
plot(PriorSDs, BayesFactors_uniform, 'r');
legend({'Normal', 'uniform (+/- 2SD)'})
title(['Prior distribution centred on ' num2str(PriorMean)]);
xlabel('prior SD');
ylabel('BayesFactor');

% figure;
% plot(4*PriorSDs, BayesFactors_uniform);
% title(['Uniform Prior']);
% xlabel('Width of uniform Prior');
% ylabel('BayesFactor');
% 
