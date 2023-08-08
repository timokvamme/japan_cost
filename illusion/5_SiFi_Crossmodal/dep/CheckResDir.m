function [ ResDir, ResFileName ] = CheckResDir( Subject )
%[ ResDir, ResFileName ] = CheckResDir( Subject )

ResDir = [pwd filesep 'Results' filesep Subject filesep];

if ~exist(ResDir) 
    mkdir(ResDir);
    ResFileName = 'Results_1';
else
    FileNo = length(dir([ResDir 'Results_*'])) +1;
    ResFileName = ['Results_' num2str(FileNo)];
    Continue = input(['Fuer diese VP bestet bereits ein Ergebnisordner mit ' num2str(FileNo-1) ' Ergebnisdateien. Trotzdem fortfahren? (0/1)']);
    if ~Continue
        error('OK, breche jetzt ab');
    end
end


end

