function BenStuff_WriteGif(ImArray, FrameHz, GifName)
%BenStuff_WriteGif(ImArray, FrameHz, GifName)
%   function to write gifs from image (cell) array in Matlab
%   FrameHz: specifies frame rate in Hz
%   GifName: filename of gif to be saved out (w/o extension)
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 7/17
%
%   inspired by https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ:-Screenshots-or-Recordings
%

for iIm = 1:length(ImArray)
    
    Im = ImArray{iIm};
    
    [ImData, ColMap] = rgb2ind(Im, 256);
    
    if iIm == 1
        imwrite(ImData, ColMap, [GifName '.gif']);
    else
        imwrite(ImData, ColMap, [GifName '.gif'], 'DelayTime', 1/FrameHz, 'WriteMode', 'append');
    end%if iIm == 1
end%for iIm

end

