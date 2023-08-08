function Sample = BenStuff_RandSampleLogical( Logical, n )
% Sample = BenStuff_RandSampleLogical( Logical, n )
% randomly sample n true elements from logical array
%
%   Logical: logical array
%   n:       desired size of subsample of true entries
%   Sample:  array of same size as logical, but with only a subset of n
%            true entries
%
%   found a bug? please let me know!
%   bejamindehaas@gmail.com 11/2015
%

assert(islogical(Logical) && ~(sum(Logical)<n), 'input array needs to be a logical with at least n true entries!');

Sample = false(size(Logical));
Ind = randsample(find(Logical),n);%randomly sample a subset of true indices
Sample(Ind) = true;

end

