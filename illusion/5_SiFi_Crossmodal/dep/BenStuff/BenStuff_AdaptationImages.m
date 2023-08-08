function [ CIm, GIm ] = BenStuff_AdaptationImages( ImFile, Prefix )
%[ CIm, GIm ] = AdaptationImages( ImFile )
%   produce images for color adaptation demo 
%
% ImFile: original image file (string)
% Prefix: string to prepend output file names
%
% CIm : complementary colour version of image (will be saved as 'Prefix_Compl.png')
% GIm : gray version of input image (will be saved as 'Prefix_Gray.png')
%
% found a bug? please let me know!
% benjamindehaas@gmail.com
%

I = imread(ImFile);
IC = imcomplement(I);
Gray = rgb2gray(I);

imwrite(IC, [Prefix '_Compl.png']);
imwrite(Gray, [Prefix '_Gray.png']);

end

