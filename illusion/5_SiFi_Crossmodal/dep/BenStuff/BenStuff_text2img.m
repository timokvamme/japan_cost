function [Lo, Up] = BenStuff_text2img(text_string, image_width, image_height, font, font_weight, font_size, ImFolder, SavePng)
% Syndax : text2img(text_string, image_width, image_height, font, font_weight, font_size, ImFolder)
% Example: text2img(MATLAB, 1024, 768, 'Times New Roman', 'bold', 32, ['.' filesep 'ImFolder' filesep]);
% This function puts the "text_string" in an image with dimensions
% image_height x image_width
% NOTE: This function was created as Matlab's inbuilt function "getframe"
% does not capture the data in the required image size.
% Written by: Aniket Vartak
% Email:      aniket@ucf.edu
%
% modified for cropping purposes by Ben 04/2014
% found a bug? please let me know!
% benjamindehaas@gmail.com
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2
    image_width=1024/2;
end
if nargin<3
    image_height=768/2;
end
if nargin<4
    font='Times New Roman';
end
if nargin<5
    font_weight='normal';
end
if nargin<6
    font_size=128;
end
if nargin<7
    ImFolder=['.' filesep 'CroppedWords' filesep];
end
if nargin<8
    SavePng=0;
end

if ~exist(ImFolder)
    mkdir(ImFolder);
end

% Get the screen size so that the figure could be placed accordingly.
screen_size = get(0, 'ScreenSize');
Fig=figure('Position', [10 10 screen_size(3)-10 screen_size(4)-10]);
axis([0 image_width 0 image_height]);
text(image_width, image_height, text_string, 'Position',[ image_height/2  image_width/2], ...
    'FontName', font,'FontWeight',font_weight, 'FontSize',font_size, 'HorizontalAlignment','center', 'VerticalAlignment', 'middle');
set(gca, 'XTick', [],  'YTick', []);
hold on; 

% get the frame to be saved
Frame = getframe(gca);
% Make all the edges white (The getframe adds edges at first column and last row)
Frame.cdata(:,1,:) = 255;
Frame.cdata(end,:,:) = 255;
Im=Frame.cdata(:,:,1);%black and white only

%crop whitespace
Dim1=any(~Im');%one wherever there is no whitespace
Dim2=any(~Im);
    
HiDim1=find(Dim1, 1, 'last' )+1;%now find highest and lowest indices without whitespace along either dimension
LoDim1=find(Dim1, 1 )+1;
HiDim2=find(Dim2, 1, 'last' )+1;
LoDim2=find(Dim2, 1 )+1;
    
Cropped=Im(LoDim1:HiDim1, LoDim2:HiDim2);

% Up
Up=Cropped( 1:(size(Cropped, 1)/2),:);%upper half

% Lo
Lo=Cropped((size(Cropped, 1)/2)+1:end, :);

if SavePng
    % Write images
    %imwrite(Frame.cdata,'temp.png');
    imwrite(Lo,[ImFolder text_string '_Lo.png']);
    imwrite(Up,[ImFolder text_string '_Up.png']);
end

close(Fig);
