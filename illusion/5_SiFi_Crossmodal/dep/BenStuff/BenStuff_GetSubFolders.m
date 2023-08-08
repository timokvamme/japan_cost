function SubFolders = BenStuff_GetSubFolders( Folder )
%SubFolders = BenStuff_GetSubFolders( Folder )
%   little helper function to retrieve subfolders within a folder
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
%
%   nicked from: http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
%

Files=dir(Folder);
SubFolders={Files([Files.isdir]).name};
SubFolders=SubFolders(~ismember(SubFolders, {'.', '..'}));


end

