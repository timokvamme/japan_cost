function BenStuff_PPV_Demo
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 Linewidth=1.5;
  
  Alpha=.05;
  Power=[0:.01:1];

  PPV_Priorp2=BenStuff_PPV(.2, Power, Alpha);
  PPV_Priorp5=BenStuff_PPV(.5, Power, Alpha);
  PPV_Priorp7=BenStuff_PPV(.7, Power, Alpha);

  figure; hold on;
  plot(Power, PPV_Priorp2, 'r', 'linewidth', Linewidth);
  plot(Power, PPV_Priorp5, 'y', 'linewidth', Linewidth);
  plot(Power, PPV_Priorp7, 'g', 'linewidth', Linewidth);
  legend('Prior: .2', 'Prior: .5', 'Prior: .7', 'Location', 'Southeast');
  set(gca, 'Fontsize', 14);
  xlabel(['Power (1-Beta)/[Alpha always ' num2str(Alpha) ']']);
  ylabel('Positive predictive power');

end

