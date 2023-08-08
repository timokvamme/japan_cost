function BenStuff_KickDummiesFromMotion( Folder, NumDummies )
%   BenStuff_KickDummiesFromMotion( Folder, NumDummies ) removes dummy vols from
%   motion regressor file and saves under new name ending in '_DummiesRemoved'
%
%
%   Folder: Folder containing rp_*.txt file (should be only one!), new file
%           will be saved here as well
%
%   NumDummies: number of dummy volumes
%
%   
% found a bug? please let me know!
% benjamindehaas@gmail.com 5/2015
%

Foo=dir([Folder 'rp_*.txt']);

if length(Foo)>1
    error('Found more than 1 motion regressor file - did You remove dummies already?!');
elseif length(Foo)<1
    error('Found no motion regressor file in this folder!');
end


FileName=[Folder Foo.name];
NewFileName=[FileName(1:end-4), '_' num2str(NumDummies) '_DummiesRemoved.txt'];

display(['reading ' FileName]);
%read file
fid=fopen(FileName);
Foo=fscanf(fid, '%f', [6, inf]);
Foo=Foo';
fclose(fid);

%remove dummy entries 
Foo=Foo(NumDummies+1:end,:);

%write shortened txt
fid=fopen(NewFileName, 'w');
fprintf(fid,  [repmat('%16.7e', 1, 6) '\r\n'], Foo);
fclose('all');

display(['saved ' NewFileName]);


end

