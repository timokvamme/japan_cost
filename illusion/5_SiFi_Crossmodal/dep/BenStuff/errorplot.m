function h=errorplot(x, y, e, c, w, L, Alpha)
%errorplot(x, y, e, c, [w], [L], [Alpha])
%
% Similar to errorbar but plots solid curve with shaded regions for errors.
% Error regions are equidistant from the curve. The inputs x, y, and e must 
% be row vectors. Each row is a separate data set. If only one row of x is 
% defined the same x is taken for each set. The input c defines the colours.
% The optional argument w defines the line width of the mean curve. L is an
% optional argument defining the LineStyle. Alpha is an optional argument
% defining the degree of alpha blending for the error shadow.
%
% Note that this function turns hold on! So if you want to plot something
% else afterwards, you must turn hold off first...

if nargin < 7
    Alpha = .5;
end
if nargin < 6
    L = '-';
end
if nargin < 5
    w = 2;
end

% if only one row of x defined 
if size(x,1) == 1
    x = repmat(x, size(y,1), 1);
end

% x values for error plot
ex = [x, fliplr(x)];
ey = [y-e, fliplr(y)+fliplr(e)];

% plot the curves first so legend will work properly
for i = 1:size(y,1)
    col = c(i,:);
    h=plot(x(i,:), y(i,:), 'Color', col, 'LineWidth', 2, 'LineStyle', L);
    hold on;
end

% superimpose transparent polygon
for i = 1:size(y,1)
    col = c(i,:);
%     plot(ex(i,:), ey(i,:), 'Color', col, 'LineStyle', ':');
%     fill(ex(i,:), ey(i,:), (col+[1 1 1])/2, 'EdgeColor', 'none');
    fill(ex(i,:), ey(i,:), col, 'EdgeColor', 'none', 'FaceAlpha', Alpha);
end

% plot the curves again 
for i = 1:size(y,1)
    col = c(i,:);
    plot(x(i,:), y(i,:), 'Color', col, 'LineWidth', w, 'LineStyle', L);
    hold on;
end
