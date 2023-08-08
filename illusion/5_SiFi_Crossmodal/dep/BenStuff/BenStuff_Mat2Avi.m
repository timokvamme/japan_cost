function BenStuff_Mat2Avi(matmov, fname)
%BenStuff_Mat2Avi
% Saves the movie matmov as the AVI file fname.
%

% if length(size(matmov)) == 3
%     map = colormap(gray(256));
%     avi = avifile([fname '.avi'], 'Colormap', map, 'FPS', 20, 'Compression', 'None'); % 'Cinepak');
% else
    avi = VideoWriter(fname, 'Archival');
    open(avi);
    %avi = avifile([fname '.avi'], 'FPS', 30, 'Compression', 'None');
% end

h = waitbar(0, 'Frames completed');

%play forward
% if length(size(matmov)) == 3
%     for i = 1:size(matmov,3) 
%         avi = addframe(avi, matmov(:,:,i)); 
%         waitbar(i/size(matmov,3), h);
%     end
% else
    for i = 1:size(matmov,4) 
        writeVideo(avi,matmov(:,:,:,i));
        %avi = addframe(avi, matmov(:,:,:,i)); 
        waitbar(i/size(matmov,4), h);
    end
% end

close(h);
%avi = close(avi);
close all;