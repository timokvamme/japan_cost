function BenStuff_Heeger_Vis(Alpha, Sigma, c)
%BenStuff_Heeger_Visualization working my way through Reynolds & Heeger,
%2009
%   illustrating eq 3 & 4

close all;
clc;

if nargin<3
    Alphas=1:3;
    Betas=[0, .5, 1];
    Sigmas=[1,5,10];
    c=0:50;
end

Colors={'r', 'g', 'b'};

%% response gain (Alpha)
figure;
hold on;
title('Response Gain');
Sigma=1;
Beta=0;
for AlphaNo=1:length(Alphas)
    Alpha=Alphas(AlphaNo);  
    Color=Colors{AlphaNo};
    r=(Alpha*c)./(c+Sigma+Beta*c);
    plot(c,r, 'LineWidth', 1.5, 'Color', Color);
end

legend(['Alpha=' num2str(Alphas(1))], ['Alpha=' num2str(Alphas(2))], ['Alpha=' num2str(Alphas(3))]);
xlabel('Stimulus Contrast');
ylabel('Response');

hold off;

%% contrast gain (Sigma)

figure;
hold on;
title('Contrast Gain');
Alpha=1;
Beta=0;
for SigmaNo=1:length(Sigmas)
    Sigma=Sigmas(SigmaNo);  
    Color=Colors{SigmaNo};
    r=Alpha*c./(c+Sigma+Beta*c);
    plot(c,r, 'LineWidth', 1.5, 'Color', Color);
end

legend(['Sigma=' num2str(Sigmas(1))], ['Sigma=' num2str(Sigmas(2))], ['Sigma=' num2str(Sigmas(3))]);
xlabel('Stimulus Contrast');
ylabel('Response');


hold off;

%% Stimulus size (Beta)

figure;
hold on;
title('Stimulus size (extending cRF)');
Alpha=1;
Sigma=1;
for BetaNo=1:length(Betas)
    Beta=Betas(BetaNo);  
    Color=Colors{BetaNo};
    r=Alpha*c./(c+Sigma+Beta*c);
    plot(c,r, 'LineWidth', 1.5, 'Color', Color);
end

legend(['Beta=' num2str(Betas(1))], ['Beta=' num2str(Betas(2))], ['Beta=' num2str(Betas(3))]);
xlabel('Stimulus Contrast');
ylabel('Response');


hold off;
end

