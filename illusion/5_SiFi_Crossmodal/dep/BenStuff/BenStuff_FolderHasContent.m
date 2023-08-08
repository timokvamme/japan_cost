function [NumFiles, NumSubFolders] = BenStuff_FolderHasContent( Folder )
% [NumFiles, NumSubFolders] = BenStuff_FolderHasContent( Folder )
%   little helper function to check whether a folder has content
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
%
%   nicked from: http://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
%

SubFolders=BenStuff_GetSubFolders(Folder);
NumSubFolders=length(SubFolders);

Files=dir(Folder);
Files={Files(~[Files.isdir]).name};
NumFiles=length(Files);

end

