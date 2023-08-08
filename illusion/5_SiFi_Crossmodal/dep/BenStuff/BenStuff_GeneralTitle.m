function [ TitleH ] = BenStuff_GeneralTitle( TitleStr, FontSize, FigureH )
%[ TitleH ] = BenStuff_GeneralTitle( TitleStr, [FontSize], 'FigureH' )
%   put a title above a group of subplots
%
%   prints TitelStr as title and returns a handle to it
%   FontSize defaults to 16, FigureH defaults to current figure
%
%   kudos to 
%   https://uk.mathworks.com/matlabcentral/answers/100459-how-can-i-insert-a-title-over-a-group-of-subplots
%   
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
%

if nargin<2
    FontSize = 16;
end

if nargin<3
    FigureH=gcf;
end

figure(FigureH);%make relevant figure current
ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on');

title(TitleStr, 'FontSize', FontSize);


end

