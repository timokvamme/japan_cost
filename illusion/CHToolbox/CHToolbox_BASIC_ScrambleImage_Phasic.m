function [scrambledImage] = CHToolbox_BASIC_ScrambleImage_Phasic(inputImage, showOption, randOption)
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

ImSize = size(inputImage);

% generate random phase structure
RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));

for layer = 1:size(inputImage,3)
    ImFourier(:,:,layer) = fft2(inputImage(:,:,layer));       

    % amplitude spectrum
    Amp(:,:,layer) = abs(ImFourier(:,:,layer));

    % phase spectrum
    Phase(:,:,layer) = angle(ImFourier(:,:,layer));

    % add random phase to original phase
    Phase(:,:,layer) = Phase(:,:,layer) + RandomPhase;

    % combine Amp and Phase then perform inverse Fourier
    scrambledImage(:,:,layer) = ifft2(Amp(:,:,layer).*exp(sqrt(-1)*(Phase(:,:,layer))));   
end

scrambledImage = mat2gray(real(scrambledImage)); % get rid of imaginery part in image (due to rounding error)

if showOption
    subplot(1,2,1); imshow(inputImage); title('input image');
    set(gca, 'YDir', 'reverse');
    subplot(1,2,2); imshow(scrambledImage); title('scrambled image');
    set(gca, 'YDir', 'reverse');
end