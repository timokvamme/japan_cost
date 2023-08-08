function [Files, SubFolders] = BenStuff_GetContent( Folder )
%[Files, SubFolders] = BenStuff_GetContent( Folder )
%   little helper function to retrieve files and subfolders separately from
%   a parent dir
%
%   Files: cell string contianing files in folder
%   SubFolders: cell string containing 
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
%

SubFolders=BenStuff_GetSubFolders(Folder);

Files=dir(Folder);
Files={Files(~[Files.isdir]).name};

end

