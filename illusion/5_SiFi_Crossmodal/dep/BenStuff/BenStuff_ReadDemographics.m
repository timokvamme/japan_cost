function [ Age, Male, RightHanded ] = BenStuff_ReadDemographics( ResultsPath )
%[ Age, Male, RightHanded ] = BenStuff_ReadDemographics( ResultsPath )
%
%   function to read in demographic information from ppt folders named 
%   according to SamPendu style acronyms
%
%   ResultsPath:    full path to directory containing ppts folders
%                   (defaults to pwd)
%
%   Age:            Numeric vector with ppt ages
%   Male:           Binary gender vector (true = male)
%   RightHanded:    Binary vector of handedness (true = right handed)
%
%   found a bug? please let me know!
%   benjamindehaas@lgmail.com 7/2017
%


if nargin < 1
    ResultsPath = pwd;
end

Age = [];
Male = [];
RightHanded = [];

FolderNames = BenStuff_GetSubFolders(ResultsPath);


for iFolder = 1:length(FolderNames)
    Name = FolderNames{iFolder};
    AgePos = find(isstrprop(Name, 'digit'));

    if any(AgePos < 3)
        disp([Name ' does not have correct format! (digit at 2nd pos or earlier)']);
    else
        ThisAge = str2double(Name(AgePos));
        
        if ~(strcmp(Name(end), 'r') || strcmp(Name(end), 'l'))
            disp([Name ' does not have correct format! (last character neither r nor l)']);strcmp(Name(end), 'l')
            ThisRight = 0;
        else
            if strcmp(Name(end), 'r')
                ThisRight = true;
            elseif   strcmp(Name(end), 'l')
                ThisRight = false;
            end%if strcmp(Name(end), 'r')
            
            if ~(strcmp(Name(end-1), 'm') || strcmp(Name(end-1), 'f'))
                disp([Name ' does not have correct format! (2nd to last char neither m nor f)']);
            else
                if   strcmp(Name(end-1), 'm') 
                    ThisMale = true;
                elseif   strcmp(Name(end-1), 'f') 
                    ThisMale = false;
                end
                
                Age = [Age; ThisAge];
                Male = [Male; ThisMale];
                RightHanded = [RightHanded; ThisRight];
            end% if ~(strcmp(Name(end-1), 'm') || strcmp(Name(end-1), 'f'))
            
        end%if ~(strcmp(Name(end), 'r')|strcmp(Name(end), 'l'))
    end%if any(AgePos < 3)
end

