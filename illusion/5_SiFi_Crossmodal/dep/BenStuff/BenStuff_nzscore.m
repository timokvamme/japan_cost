function  [X_z]  = BenStuff_nzscore( X,dim )
% [X_z]  = BenStuff_nzscore( X,dim )
%   zscore along dim from X - expects ndims(X)>2 and no singleton
%   dimensions
%   
%   X:      is a matrix
%   dim:    is the dimension along which linear trends should be removed from X
%   X_z:    is the z-scored version of X
%   
% uses matlabs z-score 
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
X_shifted=shiftdim(X,dim-1);%move dim of interest leftmost
X_z=zscore(X_shifted);
X_z=shiftdim(X_z, ndims(X)-(dim-1));%move everything back in order

end

