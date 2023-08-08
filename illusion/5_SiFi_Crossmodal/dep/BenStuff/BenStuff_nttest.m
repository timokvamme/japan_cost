function  [H,P,CI,STATS]  = BenStuff_nttest( X,dim )
% [H,P,CI,STATS]  = BenStuff_nttest( X,dim )
%   t-test along dim from X
%   
%   X:              is a matrix
%   dim:            is the dimension along which t-tests should be done
%   
% uses matlabs t-test; no breakpoints etc. 
% 
% found a bug? please let me know!
% benjamindehaas@gmail.com 5/2017
%

%% double checks

if ~(ndims(X)>2)
    error('for ndims <=2 please use native t-test function!');%
end

if ~(squeeze(X)==X)
    error('please make sure X has no singleton dimensions!')
end

%% let's go
DimFirst=shiftdim(X,dim-1);%move dim of interest leftmost

Siz=size(DimFirst);
List=reshape(DimFirst,Siz(1),prod(Siz(2:end)));%reshape to 2-D list
[H, P, CI, STATS]=ttest(List);%ttest

H = reshape(H, Siz(2:end));%reshape into matrix missing dimension of interest
P = reshape(P, Siz(2:end));
CIn(:,:,1) = reshape(CI(1,:), [Siz(2:end)]);
CIn(:,:,2) = reshape(CI(2,:), [Siz(2:end)]);
CI = CIn;
STATS.tstat = reshape(STATS.tstat, Siz(2:end));
STATS.df = reshape(STATS.df, Siz(2:end));
STATS.sd = reshape(STATS.sd, Siz(2:end));


end

