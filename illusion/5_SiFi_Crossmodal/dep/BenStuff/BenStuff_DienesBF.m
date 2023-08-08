function Bayesfactor = BenStuff_DienesBF( mean,se, meanoftheory, sdtheory, uniform, lower, upper)
%Bayesfactor = BenStuff_DienesBF( mean,sem, meanoftheory, stdtheory, [uniform], [lower], [upper])
%   Bayes factor calculator nicked from Zoltan Dienes (http://www.lifesci.sussex.ac.uk/home/Zoltan_Dienes/inference/Bayesfactor.html)
%   Modified to default to bounded uniform prior 
%   (bounds default to sample mean plus/minus 3 sample SD)
%
%   found a bug? please let me know: benjamindehaas@gmail.com
%
%

sd=se;%it is just to confusing to call the sample SE 'sd'

if nargin<5 %defaults to uniform prior, bounded by sample mean +/- 3 sample SD
    uniform=1;
    lower=mean-3*sd;
    upper=mean+3*sd;
end

normaly = @(mn, variance, x) 2.718283^(- (x - mn)*(x - mn)/(2*variance))/realsqrt(2*pi*variance); 
  
      %sd = input('What is the sample standard error? '); 
      sd2 = sd*sd; 
      
      %obtained = input('What is the sample mean? '); 
       obtained=mean;
      
      %uniform = input('is the distribution of p(population value|theory) uniform? 1= yes 0=no '); 
   
     if uniform == 0 
          %meanoftheory = mean;%input('What is the mean of p(population value|theory)? '); 
          %sdtheory = input('What is the standard deviation of p(population value|theory)? '); 
          omega = sdtheory*sdtheory;    
          tail =2;% input('is the distribution one-tailed or two-tailed? (1/2) '); 
     end 
     
     
%      if uniform == 1 
%           lower = input('What is the lower bound? '); 
%           upper = input('What is the upper bound? '); 
%      end 
     
     
     
     area = 0; 
     if uniform == 1 
         theta = lower; 
     else theta = meanoftheory - 5*(omega)^0.5; 
     end 
     if uniform == 1 
          incr = (upper- lower)/2000; 
     else incr =  (omega)^0.5/200; 
     end 
         
     for A = -1000:1000 
          theta = theta + incr; 
          if uniform == 1 
              dist_theta = 0; 
              if and(theta >= lower, theta <= upper) 
                  dist_theta = 1/(upper-lower); 
              end               
          else %distribution is normal 
              if tail == 2 
                  dist_theta = normaly(meanoftheory, omega, theta); 
              else 
                  dist_theta = 0; 
                  if theta > 0 
                      dist_theta = 2*normaly(meanoftheory, omega, theta); 
                  end 
              end 
          end 
          
          height = dist_theta * normaly(theta, sd2, obtained); %p(population value=theta|theory)*p(data|theta) 
          area = area + height*incr; %integrating the above over theta 
     end 
     
     
     Likelihoodtheory = area;
     Likelihoodnull = normaly(0, sd2, obtained);
     Bayesfactor = Likelihoodtheory/Likelihoodnull;


end

