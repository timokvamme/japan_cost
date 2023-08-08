function BenStuff_PrintA4( FigureH, FileName )
%BenStuff_PrintA4( FigureH, FileName )
%   scale figure to A4 and save as .pdf
%
% kudos to 
% https://uk.mathworks.com/matlabcentral/answers/93972-how-can-i-print-a-figure-to-pdf-in-landscape-with-the-right-scaling-in-matlab-7-3-r2006b
%
% found a bug? please let me know!
% benjamidehaas%gmail.com 11/2016
%

set(FigureH,'PaperOrientation','landscape');
set(FigureH,'PaperUnits','normalized');
set(FigureH,'PaperPosition', [0 0 1 1]);
print(FigureH, '-dpdf', [FileName '.pdf']);


end

