function BenStuff_EyePlotter(EyeData, PixPerDeg, Clean)
% BenStuff_EyePlotter(EyeData, PixPerDeg, Clean)
%
% plots normalised eye data from Eyelink
%
%   PixPerDeg defaults to 1080/17
%   Clean defaults to 1 (very liberal blink removal via outlier criterion)
%

if nargin<2 || isempty(PixPerDeg)
    PixPerDeg = 1080 / 17; %assume 1080p resolution at display height of 17 deg (i.e. max ecc 8.5)
end

if nargin<3
    Clean = 1;
end

OutCriterion = 4; %anything > OutCriterion*MAD out if clean 

%% Clean?
if Clean %remove outliers
    XY=EyeData(:,2:3);
    MAD=mad(XY);
    MAD=max(MAD);
    XYMeanCentered=XY - repmat(mean(XY),size(XY,1),1);
    Outliers = [any((abs(XYMeanCentered)') > OutCriterion*MAD)]';  
    EyeData=EyeData(~Outliers,:);
end%if Clean

%% scale everything to 0-1 range
Range=range(EyeData);
Range=Range./PixPerDeg;
Range=(round(Range.*50))./100;%here it's divided by two (we want extrema +/-)
RangeX=Range(2);
RangeY=Range(3);

Scaled = EyeData; 
Scaled(:,1) = [NaN; diff(Scaled(:, 1))];%temporal distance between samples  
Scaled = Scaled - repmat(min(Scaled),size(Scaled,1),1);%scale everything
Scaled = Scaled./repmat(max(Scaled),size(Scaled,1),1);

%% plot timeseries
%figure(gcf); hold on;
set(gca, 'FontSize', 10);
set(gca, 'FontWeight', 'b');

plot(Scaled);
%legend({'inter-sample time', ['x [range ' num2str(RangeX) ' deg]'], ['y [range ' num2str(RangeY) ' deg]'], 'pupil size'});
text(0,0.9,['x [range +/-' num2str(RangeX) ' deg]'], 'color',[0 .5 0]);
Xlim=get(gca, 'xlim');
text(Xlim(2)/2, 0.9, ['y [range +/-' num2str(RangeY) ' deg]'], 'color', 'r');
set(gca, 'YTick', [0 1]);
set(gca, 'YTickLabel', {'Min', 'Max'});
%set(gca, 'YTickLabel', {['x: -' num2str(RangeX./2) '/y: -' num2str(RangeY./2)], ['x: ' num2str(RangeX./2) '/y: ' num2str(RangeY./2)]});
%xlabel('Sample No');



