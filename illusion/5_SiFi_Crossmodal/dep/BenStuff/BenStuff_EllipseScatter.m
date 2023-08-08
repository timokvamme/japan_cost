function BenStuff_EllipseScatter(x,y,xRadius,yRadius, LineWidth, Color, SubSample)
%BenStuff_EllipseScatter(x,y,xRadius,yRadius, [LineWidth], [Color], [SubSample])
%   do a scatterplot of ellipses (e.g. to show center and dispersion parameters along two tuning dimensions)
%
%   x:          center positions along first dimension
%   y:          center positions along second dimension
%   xRadius:    dispersion along first dimension
%   yRadius:    dispersion along second dimension
%   SubSample:  optional argument - plot subsample of datapoints 
%               you can either provide a scalar -> n samples will be drawn
%               randomly, or a vector of pre-determined indices 
%               a value of NaN will result in all data being plotted (default)
%
%   LineWidth:  optional, defaults to 1
%   Color:      optional RGB triplet, defaults to [0 0 0]
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 11/2015
%

%% some house-hold tasks

if nargin<7
    SubSample=NaN;
end

if nargin <6
    Color = [0 0 0];
end

if nargin<5
    LineWidth = 1;
end

assert(all(size(x)==size(y) & size(xRadius)==size(yRadius) & size(x)==size(xRadius) & isvector(x)),...
    'First four input variables need to be vectors of equal size!');

if isrow(x)
    x=x'; y=y'; xRadius=xRadius'; yRadius=yRadius';
end

if isscalar(SubSample) && ~isnan(SubSample)
    assert((length(x)>SubSample), ['Subsample is ' num2str(SubSample) ', but only ' num2str(length(x)) ' datapoints to draw from!']);
    SubSample = randsample(1:length(x), SubSample);
elseif isvector(SubSample) && ~(isnan(SubSample))
    assert((length(x)>max(SubSample) & min(SubSample)>0 & isinteger(SubSample)), ['Subsample should only contain positive integers smaller or equal to number of datapoints!']);   
   x=x(SubSample);
   y=y(SubSample);
   xRadius=xRadius(SubSample);
   yRadius=yRadius(SubSample);
end

    
    
%% here the interesting bits happen
theta = 0:.01:2*pi;
[fx, ft] = ndgrid(xRadius,theta);
[fy, ft] = ndgrid(yRadius,theta);
xPlot = fx.*cos(ft);
xPlot = bsxfun(@plus,xPlot,x);%

yPlot = fy.*sin(ft);
yPlot = bsxfun(@plus,yPlot,y);%


for iRow=1:size(xPlot,1)
    plot(xPlot(iRow,:), yPlot(iRow,:), 'LineWidth', LineWidth, 'Color', Color); hold on;
end

end

