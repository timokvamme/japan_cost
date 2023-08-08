function [ Ms ] = BenStuff_NaNshift( M, Shift )
%[ Ms ] = BenStuff_NaNshift( M, Shift )
%
%   will apply a non-circular columns-wise shift padding with NaNs
%   the amount of shift for each column can vary and is determined 
%   by vector Shift 
%   
%   M:      unshifted matrix
%   Shift:  specifies amount of shift for each column - negative values
%           correpond to upshift
%
%   Ms:     shifted and NaN-padded version of M
%
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 5/2016 
%

[NumRows NumCols] = size(M);

if any(~isequal(Shift, int32(Shift)))
    error('Entries of Shift have to be integers!');
end

if length(Shift(:)) > NumCols
    error('Number of entries in Shift has to correpond to number of columns of M!');
end

Ms = NaN(size(M));%initialise
    

% NB: Apparently looping is faster than all the do-my-head-in type solutions
% one could come up with 

for iCol = 1:NumCols
    
    shift = Shift(iCol);
    Col = M(:,iCol);
    
    if shift > 0 %downshift
        Ms(shift+1:end,iCol) = Col(1:end-shift);
    elseif shift < 0 %upshift
        Ms(1:end+shift,iCol) = Col(1-shift:end);
    else%no shift
        Ms(:,iCol) = Col;
    end   
end%for iCol

end

