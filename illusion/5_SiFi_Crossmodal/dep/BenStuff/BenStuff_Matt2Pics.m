function BenStuff_Mat2Pics(matmov, nametemp, scaled, PicFormat)
%BenStuff_Mat2Pics(matmov, nametemp, scaled)
% Saves the movie matmov as series of pic files
%

if nargin<4
    PicFormat='PNG';%default to png
end

x = size(matmov, 2);
y = size(matmov, 1);
if ndims(matmov)==4
    c = size(matmov,3);
    z = size(matmov, 4);
else
    z = size(matmov, 3);
end

%if there is scaling
if nargin > 2
   img = imresize(matmov(:,:,1), scaled, 'bicubic');
    x = size(img, 2);
    y = size(img, 1);   
end

h = waitbar(0, 'Frames completed');

%play forward
for i = 1:z
    FileName=[nametemp num2str(i)];
    if ndims(matmov)==4
        if nargin > 2
            img(:,:,:) = imresize(matmov(:,:,:,i), scaled, 'bicubic'));
        else
            img(:,:,:) = matmov(:,:,:,i); 
        end
        
        imwrite(img,FileName,PicFormat); 
        waitbar(i/size(matmov,4), h);
    else
        if nargin > 2
            img(:,:,:) = imresize(matmov(:,:,i), scaled, 'bicubic'));
        else
            img(:,:,:) = matmov(:,:,i); 
        end
        
        imwrite(img,FileName,PicFormat); 
        waitbar(i/size(matmov,3), h);
    end
end

close(h);
%imwrite(gif, map, [fname '.gif'], 'DelayTime', 0, 'LoopCount', Inf);
close all;