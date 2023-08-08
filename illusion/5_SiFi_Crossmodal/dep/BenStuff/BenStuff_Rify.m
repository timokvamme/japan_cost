function [Rified, Hdr] = BenStuff_Rify( Orig, Factors, FactorNames, FileName )
%Rified = BenStuff_Rify( Orig )
%   R-ify data 
%   
%   Orig is expected to be organised in rows and columns according to
%   subjects and conditions, respectively
%   
%   Factors is a set of binary vectors with as many rows as there are
%   factors. the number of column vectors has to equal that of Orig
%
%   FactorNames is a cellstr with corresponding facto names
%
%   FileName is an optional argument; if provided will save out a CSV file
%   using BenStuff_
%
%   Rified has one column with data, one with subject numbers and
%   additional binary ones for factors
%   Hdr is a cell string containing corresponding titles, incl FactorNames
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 10/2016
%

%sanity checks
assert(nargin>2);
assert(size(Factors,2)==size(Orig,2));
assert(length(FactorNames)==size(Factors,1));

%wirte Hdr
Hdr = [{'Data', 'Subject'} FactorNames];

%now re-arrange data
Subjects = repmat([1:size(Orig,1)]',size(Orig,2),1);%subject numbers

%binary factor vectors
for iFac = 1:size(Factors,1)
    Cols = Factors(iFac,:);
    Fac =repmat(Cols',1,size(Orig,1))';
    BinaryFacs(:,iFac) = Fac(:)';
end%for iFactor

Rified = [Orig(:), Subjects, BinaryFacs];%stitch everything together

%write to CSV if desired
if nargin >3
    assert(ischar(FileName));
    BenStuff_WriteCSV( Rified, Hdr, FileName );
end

end

