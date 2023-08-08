function [ scrambledImage ] = BenStuff_phaseScrambleImage( inputImage )
%function [ scrambledImage ] = BenStuff_phaseScrambleImage( image )
%
%This function takes an image and keeps its fouier power spectrum constant
%but replaces the phase spectrum with uniform noise.
%
%Input:
%inputImage: input image
%
%Output:
%scrambledImage: output phase scrambled.
%

%email: justin.ales@gmail.com
%Copyright 2012 Justin Ales
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.%
%
% slightly edited by Ben 6/2013 (benjamindehaas@gmail.com)

NumDims=ndims(inputImage);%account for col images, Ben 6/2015

if NumDims==2
    inFourier = fft2(inputImage);
    inAmp = abs(inFourier);
elseif NumDims==3
    In1=squeeze(inputImage(:,:,1));
    In2=squeeze(inputImage(:,:,2));
    In3=squeeze(inputImage(:,:,3));   
    
    InFour1=fft2(In1);
    InAmp1=abs(InFour1);
    
    InFour2=fft2(In2);
    InAmp2=abs(InFour2);
    
    InFour3=fft2(In3);
    InAmp3=abs(InFour3);
end

%This uses a trick to easily scramble phases 
%Making the correct random fft matrix is a little tricky because 
%fourier transforms of real images have symmetry
%It's easier just to take the fourier transform of a white noise image
%White noise has a flat power spectrum and uniform phase spectrum
if NumDims==2
	outPhase=angle(fft2(randn(size(inputImage))));
else
    outPhase=angle(fft2(randn(size(inputImage,1), size(inputImage,2))));
end

%reconstruct the scrambled image from its complex valued matrix
if NumDims==2
    scrambledImage=ifft2(inAmp.*exp(1i.*outPhase),'symmetric');
elseif NumDims==3
    Scr1=ifft2(InAmp1.*exp(1i.*outPhase),'symmetric');
    Scr2=ifft2(InAmp2.*exp(1i.*outPhase),'symmetric');
    Scr3=ifft2(InAmp3.*exp(1i.*outPhase),'symmetric');
    
    scrambledImage(:,:,1)=Scr1;
    scrambledImage(:,:,2)=Scr2;
    scrambledImage(:,:,3)=Scr3;
    
end

%needs to be between 0 and 1 - added by Ben 6/2013
I=scrambledImage;
I=I+abs(min(I(:)));%make sure all values are positive
I=I./(max(I(:)));
scrambledImage=I*128;%assuming uint8

end
