function HdrFiles = BenStuff_CheckFilesAreHdr(ParentDir, SubDirs)
%function to check for files in ParentDir in hdr format
%
%   HdrFiles:     Cell struct containing full paths to hdr files found
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

CritEnd = '.hdr';%critical file ending to check

HdrFiles = {};%initialise

%let's do it
Cont = dir(ParentDir);
for iCont = 1:length(Cont)
    if ~Cont(iCont).isdir && strcmp(Cont(iCont).name(end+1-length(CritEnd):end), CritEnd)%no directory and not matching critical ending
        HdrFiles{length(HdrFiles)+1} = [ParentDir filesep Cont(iCont).name];
    elseif SubDirs && Cont(iCont).isdir && ~strcmp(Cont(iCont).name,'.') && ~strcmp(Cont(iCont).name,'..')%if directory (other than parent or one above) 
        SubDir = [ParentDir filesep Cont(iCont).name];
        HdrFilesTemp = BenStuff_CheckFilesAreHdr(SubDir, SubDirs);%recursive search
        if ~isempty(HdrFilesTemp)
            HdrFiles = [HdrFiles, HdrFilesTemp];%concatenate
        end
    end
end%for iCont


