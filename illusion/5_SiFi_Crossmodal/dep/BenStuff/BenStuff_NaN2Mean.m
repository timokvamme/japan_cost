function M= BenStuff_NaN2Mean( M )
%M_Out= BenStuff_NaN2Mean( M_In )
%   replace NaN with mean - for matrices works along columns
%
%   found a bug? please let me know
%   benjamindehaas@gmail.com 30-10-13

if isrow(M)
    Row=1;
    M=M';%if vector make sure it's column 
else
    Row=0;
end

[row,col] = find(isnan(M));%find NaN indices
ColMeans=nanmean(M);
M(isnan(M)) = ColMeans(col);


if Row
    M=M';
end

end

