function [ LoCutOff, LoCutOffHz, CumEnergy] = BenStuff_LoCutOff( X,TR, CumEnergy, Fig)
%[ LoCutOff, LoCutOffHz, CumEnergy] = BenStuff_LoCutOff( X,TR, [CumEnergy])
%   function to determine cut-off for low pass filtering of time series
%
%   takes prediction matrix and TR as input parameters and determines
%   which components of a discrete cosine transformation can be savely 
%   discarded based on 'fastest' prediction 
%
%   X:          predictions as saved in src file produced by SamSrf
%   TR:         TR in seconds
%   CumEnergy:  optional, defaults to .99. how much of the signal 
%               should be explained by the components not discarded?
%   Fig:        Optional figure output to compare low pass and original for
%               'fastest' prediction. Defaults to false
%
%   LoCutOff:   Cut off (components LoCutOff:end can be discarded)
%   LoCutOffHz: Cut off in Hz
%   CumEnergy:  actual cumulative energy for components not discarded
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 09/15
%

if nargin<4
    Fig=false;
end

if nargin<3
    CumEnergy=.99;
end

% use standard Hrf
Hrf = samsrf_hrf(TR);

% derive actual predicitons by convolving with HRF
for p = 1:size(X,2)
    cX = conv(X(:,p), Hrf);
    Xhrf(:,p) = cX(1:size(X,1));
end
%discrete cosine transformation
Xc=dct(Xhrf);

%cumulative energy of cosine components
Sums = repmat( squeeze(sum(abs(Xc))), size(Xc,1),1);%total per column
Cums = cumsum(abs(Xc))./Sums;%cumulative proportions
[Mins I] = min(Cums');%minimum cumnulative proportion of components across predictions

[Foo, LoCutOff] = find((Mins-CumEnergy)>0);
CumEnergy = Mins(LoCutOff(1));
I = I(LoCutOff(1));%which time series is the 'fastest' in terms of criterion
LoCutOff = LoCutOff(2);%first one to be discarded
LoCutOffHz = LoCutOff./(size(X,1).*TR);

if Fig
    %compare time courses
    Raw = squeeze(Xhrf(:,I));
    LoPass = squeeze(Xc(:,I));
    LoPass(LoCutOff:end) = 0;%discard components beyond cut-off
    LoPass = idct(LoPass); %invert dct
    
    %'worst hit'
    Filtered = Xc;
    Filtered(LoCutOff:end,:) = 0;
    Filtered = idct(Filtered);
    
    E = squeeze(sum((Filtered-Xhrf).^2,1));%error
    [Foo, Worst] = max(E);
    
    WorstFiltered = squeeze(Filtered(:,Worst));
    WorstRaw = squeeze(Xhrf(:,Worst));

    %plot cosine transformation
    figure; hold on;
    set(gca, 'FontSize', 16);
    set(gca, 'FontWeight', 'b');
    
    plot((1:size(Xc,1))./(size(Xc,1).*TR), squeeze(Xc(:,I)),'LineWidth',2);
    Ylim=ylim(gca);
    line([LoCutOffHz LoCutOffHz], Ylim, 'LineStyle', '--', 'LineWidth',2,'Color', 'k')
    
    legend({'''fastest'' prediction', 'CutOff'});
    
    ylabel('Amplitude');
    xlabel('components of DCT [Hz]')
    
    %plot comparison
    figure; hold on;
    title('Fastest');
    set(gca, 'FontSize', 16);
    set(gca, 'FontWeight', 'b');
    
    plot(Raw, 'LineWidth', 2);
    plot(LoPass, 'LineWidth', 2, 'Color', 'r');
    
    legend({'raw prediction', 'filtered version'});
    
    ylabel('Amplitude');
    xlabel('volumes');
    
    
    %plot comparison
    figure; hold on;
    title('largest error');
    set(gca, 'FontSize', 16);
    set(gca, 'FontWeight', 'b');
    
    plot(WorstRaw, 'LineWidth', 2);
    plot(WorstFiltered, 'LineWidth', 2, 'Color', 'r');
    
    legend({'raw prediction', 'filtered version'});
    
    ylabel('Amplitude');
    xlabel('volumes')
end%if figure



end

