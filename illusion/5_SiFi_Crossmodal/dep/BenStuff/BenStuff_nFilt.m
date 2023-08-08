function  [X_Filt]  = BenStuff_nFilt( X,dim,LoCut, HiCut, TR)
% [X_Filt]  = BenStuff_nFilt( X,dim, LoCut, HiCut )
%   bandpass filter X along dim using discrete cosine transformation
%   
%   X:              is a matrix
%   dim:            is the dimension along which filter should be applied
%   LoCut:          frequencies < LoCut will be removed (defaults to first two components)
%   HiCut:          frequencies > HiCut will be removed (defaults to 0.5 Hz) 
%   TR:             TR (temporal discretization of data, defaults to 1s)
%
%   X_Filt:         is the filtered version of X
%   
%   
% uses matlabs dct; no breakpoints etc. 
% 
% found a bug? please let me know!
% benjamindehaas@gmail.com 9/2015
%

%% double checks

if ~(ndims(X)>1)
    error('for 1 D please use native DCT function!');%
end

if ~(squeeze(X)==X)
    error('please make sure X has no singleton dimensions!')
end

if nargin<5
    TR = 1;
end

if nargin <4 
    HiCut = .5;
end

if nargin <3
    LoCut = [1:2];%components to be reomved
end

%% let's go

if ndims(X)==2
    List = X;
    if dim ==2
        List = List';
    end
else
    %reshape to list
    DimFirst=shiftdim(X,dim-1);%move dim of interest leftmost
    Siz=size(DimFirst);
    List=reshape(DimFirst,Siz(1),prod(Siz(2:end)));%reshape to 2-D list
end

%filter
NumVols = size(List, 1);
FreqComps =  (1:NumVols)./(NumVols.*TR);
TooLo = false(size(FreqComps));

if length(LoCut)==1
    TooLo = FreqComps<LoCut;
else
    TooLo(LoCut) = true;
end

TooHi = FreqComps>HiCut;

IsOut = TooHi | TooLo;

ListFilt = dct(List);%DCT 
ListFilt(IsOut,:) = 0;%remove unwanted components
ListFilt = idct(ListFilt);%invert DCT

if ndims(X)==2
    X_Filt = ListFilt;
    if dim ==2
        X_Filt = X_Filt';
    end
else
    %reshape back into orignial format
    DimFirst_Filt=reshape(ListFilt, Siz);%invert reshape
    X_Filt=shiftdim(DimFirst_Filt, ndims(X)-(dim-1));%move everything back in order
end



end

