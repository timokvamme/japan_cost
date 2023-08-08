function BenStuff_MergeData( Folder, PrePend, OutName )
%BenStuff_MergeData( Folder, [PrePend], [OutName] )
% merge all nifti volumes of format PrePend*.nii ni Folder into 4D timeseries
% the resulting 4D nifti will be saved as OutName.nii 
%
%   PrePend defaults to 'ubf'
%   OutName defaults to '4D'   
%
%   found a bug? please let me know... 
%   benjamindehaas@gmail.com 11/14
%
%
   

%% prep
BatchNo=1;

    
if nargin<2
    PrePend='ubf';
end

if nargin<3
    OutName='4D';
end
    
   
%% let's do it   
EPIs={};%initialise
CurrEPIs=dir([Folder PrePend '*.nii']);
for iFile=1:length(CurrEPIs)
    EPIs{iFile}=[Folder CurrEPIs(iFile).name];
end
spm_file_merge(EPIs, [Folder OutName]);

end
