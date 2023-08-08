function [ Lower8, Upper8, Lower32, Upper32, Plot, TestedRatio  ] = BenStuff_LikelihoodRatios( SampleMean, SEM, n, Theta1, Theta2)
%[ Lower8, Upper8, Lower32, Upper32, Plot, TestedRatio  ] = BenStuff_LikelihoodRatios( SampleMean, SEM, n, [Theta1], [Theta2])
%   calculates the distribution of likelihood ratios for the population mean 
%   based on sample characteristics and the assumption of approximate normality
%   
%   mean: sample mean, provide a vector for between group designs
%   SEM:  standard error of the mean, provide a vector for between group designs 
%   n: smaple size, provide a vector for between group designs
%   Theta1 & Theta2: Optional - give likelihood ratio for two specific
%   hypotheses - defaults to maximum likelihood vs 0 
%  
%
%   Lower8: lower boundary of the 1/8 LI
%   Upper8: upper boundary of the 1/8 LI
%   Lower32: lower boundary of the 1/32 LI
%   Upper32: upper boundary of the 1/32 LI
%   Plot: figure handle for plot
%   TestedRatio: likelihood ratio for Theta 1 vs Theta 2 (optional)
%
%   code was stolen from the fatastic book of Zoltan Dienes:
%   http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/index.htm
%   please cite either the book or this paper of his when using this: 
%   http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/Dienes%202011%20Bayes.pdf
%
%   found a bug? my fault not Dienes'!
%   please let me know: benjamindehaas@gmail.com

%% First calculate distribution of likelihood ratios
if length(n)==2 %for mulitple groups
    BetweenGroups=1;
    HarmonicMeanN=length(n)./(sum(1./n));%use harmonic mean of n
    DoF=HarmonicMeanN-length(n);%degrees of freedom (adjusted for number of groups)
    SampleMean=SampleMean(1)-SampleMean(2);%assumes two groups!
    SEM1=SEM(1);%caluclate SEM of differences; cf http://onlinestatbook.com/2/sampling_distributions/samplingdist_diff_means.html
    SEM2=SEM(2);
    Std1=SEM1*sqrt(n(1));
    Std2=SEM2*sqrt(n(2));
    SEM=sqrt((Std1^2/n(1))+(Std2^2/n(2)))
    
elseif length(n)>2
    error('not sure I can handle more than two groups, please check the code!');
else
    BetweenGroups=0;
    SampleVariance = n*SEM^2; 
    SumOfSquares = SampleVariance*(n-1);
end

if nargin<4
    Theta1=SampleMean;
    Theta2=0;
end

  
LikelihoodMax = 0; %initialise
Theta(1) = SampleMean - 5*SEM; %begin 5 SEMs from sample mean
Increment = SEM/100; %define resolution of iterative calculation
  
%now calculate likelihood for each bin
 for Bin = 1:1000 
    Theta(Bin) = Theta(1) + (Bin-1)*Increment; %parameter value (i.e. mean) for current bin
    if ~BetweenGroups %one sample test
        Likelihood(Bin) = (SumOfSquares + n*(SampleMean - Theta(Bin))^2)^(-n/2); %likelihood for that value
    else %between groups design
        Likelihood(Bin) = (1 +(SampleMean - Theta(Bin))^2/(DoF*SEM^2))^(-(DoF+1)/2); 
    end
    if Likelihood(Bin) > LikelihoodMax %update maximum likelihood
        LikelihoodMax = Likelihood(Bin); 
    end 
 end 
 for Bin = 1:1000 %now convert distribution to Likelihood rations
     Likelihood(Bin) = Likelihood(Bin)/LikelihoodMax; 
 end 
 
 
%% calculate specific ratio
%if nargin >3 
  B1 = int16((Theta1 - Theta(1))/Increment  + 1);%determine corresponding bins
  B2= int16((Theta2 - Theta(1))/Increment  + 1); 
  TestedRatio  = Likelihood(B1)/Likelihood(B2); 
%end
     
 
 %% determine boundaries of conventional intervals
 OutOfRange = SampleMean - 6*SEM; 
 
 Lower8 = OutOfRange; %intialise
 Lower32 = OutOfRange; 
 Upper8 = OutOfRange; 
 Upper32 = OutOfRange; 
 
 for Bin = 1:1000 
     if Lower8 == OutOfRange 
         if Likelihood(Bin) > 1/8 
             Lower8 = Theta(Bin); 
         end 
     end 
     if Lower32 == OutOfRange 
         if Likelihood(Bin) > 1/32 
             Lower32 = Theta(Bin); 
         end 
     end 
     if and(Lower8 ~= OutOfRange, Upper8 == OutOfRange) 
         if Likelihood(Bin) < 1/8 
             Upper8 = Theta(Bin); 
         end 
     end 
     if and(Lower32 ~= OutOfRange, Upper32 == OutOfRange) 
         if Likelihood(Bin) < 1/32 
             Upper32 = Theta(Bin); 
         end 
     end 
 end 
  
%% finally, do the plot

Plot=figure;
hold on;

Line8=line([Lower8, Upper8], [1/8, 1/8]);
set(Line8, 'Color', 'b');
Line32=line([Lower32, Upper32], [1/32, 1/32]);
set(Line32, 'Color', 'k');
legend(['1/8 interval: ' num2str(Lower8) ' to ' num2str(Upper8)], ...
    ['1/32 interval: ' num2str(Lower32) ' to ' num2str(Upper32)], 'Location', 'Best');

scatter(Theta, Likelihood, 'r');

set(gca, 'fontsize', 15);

title('Distribution of Likelihood Ratios');
xlabel('Population mean');
ylabel('Likelihood ratio');

hold off;



end

