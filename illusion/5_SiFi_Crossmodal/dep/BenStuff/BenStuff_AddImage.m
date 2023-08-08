function ImHandle = BenStuff_AddImage( img, ax, opt )
% ADDIMAGE Add an image to an existing set of axes
% ImHandle = addimage(img,ax,delta,crop)
% Input
% img image data (N x M or N x M x 3)
% ax axes handle, default = gca
% opt 'crop' the image is cropped to fit in the axes
% 'fit' the image is resized to fit in the axes (default)
% 'expand' the axes are expanded to show all of the image
% Output
% ImHandle handle of new image object

% Copyright 2015, North Carolina State University
% Written by Ken Garrard

% ----
% Use the handle returned by addimage to set the 'alphadata' property to get the transparency level you want. For example,
% 
%    p = peaks(201);
%    q = imread('pout.tif');
%    figure;
%    imagesc(p);
%    h = addimage(q,gca,'fit');
%    set(h,'alphadata',0.5);



% Check number of arguments
narginchk(1,3);

% Validate axes argument, default is current axes
if nargin < 2 || isempty(ax), ax = gca;
elseif ~ishghandle(ax) || ~strcmpi(get(ax,'type'),'axes')
   error('Invalid axis handle argument');
end

% Validate option argument
if nargin < 3, opt = 'fit'; end
opt = find(strcmpi(opt,{'crop' 'fit' 'expand'}) > 0, 1);
if isempty(opt), opt = 2; end

% Range of values in a vector
rangefun = @(v)(max(v(:))-min(v(:)));

% Get axes limits and center
xl = xlim(ax);
yl = ylim(ax);
x0 = sum(xl)/2;
y0 = sum(yl)/2;

% Size of the image
%[r,c] = dealcol(size(img));
[r,c] = (size(img));

% Resize the image to fit in the axes
if opt == 2
   if rangefun(xl) > rangefun(yl)
        [locX,locY] = resizeXY(xl,yl,c/r);
   else [locY,locX] = resizeXY(yl,xl,r/c);
   end
   
% Let the axes expand to accommodate the image
else
   locX = [x0-c/2 x0+c/2];
   locY = [y0-r/2 y0+r/2];
end

% Save hold state and switch it to ON
nxtplt = get(ax,'nextplot');
set(ax,'nextplot','add');

% Add the image to the current axes
set(ax,'XLimMode','auto','YLimMode','auto');
ImHandle = subimage(locX,locY,img);

% Restore the hold state
%set(ax,'nextplot',nxtplt);

% Crop the image to fit in the axes
if opt == 1
   xlim(xl);
   ylim(yl);
end

% --- Rescale axis ranges while preserving aspect ratio
function [ud,vd] = resizeXY(ud,vd,rat)
if rat*rangefun(vd) < rangefun(ud)
     ud = [ud(1) ud(1) + rat * rangefun(vd)];
else vd = [vd(1) vd(1) + 1/rat * rangefun(ud)];
end
end

end




