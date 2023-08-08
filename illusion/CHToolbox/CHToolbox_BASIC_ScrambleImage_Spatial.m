function [scrambledImage, permuteParameter] = CHToolbox_BASIC_ScrambleImage_Spatial(inputImage, nSection, showOption, randOption)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function wraps the matlab exchange fucntion "hb_imageScramble" for convenient
% this matlab function returns scrambled matrix of input image, [nSection+1 by nSection+1] 
% example -> image scramble into 2 by 2 grid (without image plot)
% >> resultImage = hb_imageScramble(inputImage, 2, false);
% example -> image scramble into 4 by 4 grid (with image plot)
% >> resultImage = hb_imageScramble(inputImage, 4, true);
% initial commit : 20160326
% hiobeen@yonsei.ac.kr
% key word : image scramble matlab 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if randOption
    rng(1);
end

[scrambledImage, permuteParameter] = hb_imageScramble(inputImage, nSection, showOption);