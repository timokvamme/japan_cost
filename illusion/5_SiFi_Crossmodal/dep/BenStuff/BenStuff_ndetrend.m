function  [X_detr]  = BenStuff_ndetrend( X,dim )
% [X_detr]  = BenStuff_ndetrend( X,dim )
%   remove linear trends along dim from X
%   
%   X:              is a matrix
%   dim:            is the dimension along which linear trends should be removed from X
%   X_detr:         is the detrended version of X
%   
% uses matlabs detrend; no breakpoints etc. 
% 
% found a bug? please let me know!
% benjamindehaas@gmail.com
%

%% double checks

if ~(ndims(X)>2)
    error('for ndims <=2 please use native z-score function!');%z-score only works along first non-singleton dimension if ndims >2
end

if ~(squeeze(X)==X)
    error('please make sure X has no singleton dimensions!')
end

%% let's go
DimFirst=shiftdim(X,dim-1);%move dim of interest leftmost

Siz=size(DimFirst);
List=reshape(DimFirst,Siz(1),prod(Siz(2:end)));%reshape to 2-D list
List_detr=detrend(List);%detrend

DimFirst_detr=reshape(List_detr, Siz);%invert reshape
X_detr=shiftdim(DimFirst_detr, ndims(X)-(dim-1));%move everything back in order



end

