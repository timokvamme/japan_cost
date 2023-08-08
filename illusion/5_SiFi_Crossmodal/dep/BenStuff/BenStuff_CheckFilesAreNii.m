function NonNii = BenStuff_CheckFilesAreNii(ParentDir, SubDirs)
%function to check all files in ParentDir are in nii format
%
%   NonNii:     Cell struct containing full paths to non-nii files found
% 
%   ParentDir:  parent directory to be checked (string argument)
%   SubDirs:    optional argument: should sub directories be checked (recursively)?
%               defaults to 1
%   
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 4/2/2016
%

if nargin<2
    SubDirs = 1;%default: check sub directories
end

CritEnd = '.nii';%critical file ending to check

NonNii = {};%initialise

%let's do it
Cont = dir(ParentDir);
for iCont = 1:length(Cont)
    if ~Cont(iCont).isdir && ~strcmp(Cont(iCont).name(end+1-length(CritEnd):end), CritEnd)%no directory and not matching critical ending
        NonNii{length(NonNii)+1} = [ParentDir filesep Cont(iCont).name];
    elseif SubDirs && Cont(iCont).isdir && ~strcmp(Cont(iCont).name,'.') && ~strcmp(Cont(iCont).name,'..')%if directory (other than parent or one above) 
        SubDir = [ParentDir filesep Cont(iCont).name];
        NonNiiTemp = BenStuff_CheckFilesAreNii(SubDir, SubDirs);%recursive search
        if ~isempty(NonNiiTemp)
            NonNii = [NonNii, NonNiiTemp];%concatenate
        end
    end
end%for iCont


