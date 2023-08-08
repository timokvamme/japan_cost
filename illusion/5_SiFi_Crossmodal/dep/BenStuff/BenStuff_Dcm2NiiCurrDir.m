function BenStuff_Dcm2NiiCurrDir(CurrDir, output_path)
%   Dcm2NiiCurrDir( [CurrDir], [output_path] ) handle Siemens dicoms in current
%   directory (or provided CurrDir):
%    convert dcm to nii and save in output_path
%   
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 2/14
%

   
BatchNo=1;
spm_jobman('initcfg');

if nargin<1
    CurrDir=pwd;
end

if nargin<2
    output_path=CurrDir;
end
    

        listScans = dir([CurrDir '*.dcm']);
        
        if ~isempty(listScans)
            for num = 1:length(listScans) 
                FileName=[CurrDir listScans(num).name];
                listScans(num).name = FileName;
            end
            Files = {listScans.name};% put all files in one cell array

            matlabbatch{BatchNo}.spm.util.dicom.data = Files;
            matlabbatch{BatchNo}.spm.util.dicom.root = 'flat';
            matlabbatch{BatchNo}.spm.util.dicom.outdir = {output_path};
            matlabbatch{BatchNo}.spm.util.dicom.convopts.format = 'nii';
            matlabbatch{BatchNo}.spm.util.dicom.convopts.icedims = 0;
            % Run the batch
            spm_jobman('run_nogui', matlabbatch);
        end
end

