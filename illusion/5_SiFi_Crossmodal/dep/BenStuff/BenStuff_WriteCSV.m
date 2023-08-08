function BenStuff_WriteCSV( Data, Hdr, FileName )
%BenStuff_WriteCSV( Data, Hdr, FileName )
% write data in a matrix and hdr row to a CSV
%
%   Data:       Matrix containing data, number of cols must match number of Hdr
%               entries
%
%   Hdr:        Cell containing Hdr entries for each column of Data
%   FileName:   name under which CSV is stored (w/o extension)
% 
%   kudos to http://uk.mathworks.com/matlabcentral/newsreader/view_thread/281495
%
% found a bug? please let me know!
% benjamindehaas@gmail.com 3/16
%

FileName = [FileName '.csv'];

fid = fopen(FileName, 'w');
for iHdr = 1:length(Hdr)-1
    fprintf(fid, '%s\t', Hdr{iHdr}) ;
end
 fprintf(fid, '%s\n', Hdr{end}) ;
fclose(fid);

dlmwrite(FileName, Data, '-append', 'precision', '%.6f', 'delimiter', '\t');


end

