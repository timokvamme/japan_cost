function M = BenStuff_ScrubCell( Cell )
%Matrix = BenStuff_ScrubCell( Cell )
%   function to read number entries of a cell into a matrix -  all other types of entry will be NaN  

Ind=~cellfun(@isnumeric,Cell);%entries that are not numeric
if sum(Ind)>0
    Cell(Ind)=num2cell(NaN);
end

M=cell2mat(Cell);


end

