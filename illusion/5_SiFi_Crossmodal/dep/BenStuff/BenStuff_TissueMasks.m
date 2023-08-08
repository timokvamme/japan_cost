function BenStuff_TissueMasks( StrIm, FunIm )
%BenStuff_TissueMasks( StrIm, FunIms )
%   calls SPM to create tissue class images from StrIm and saves out
%   resliced versions of those in register with FunIm
%
%   useful for e.g. BenStuff_PowerPlot, or to select regions of no interest
%   / nuissance signal for ctrl analyses (e.g. null distribution of pRF fits
%   to WM time series)
%   
%   c1: grey matter; c2: white matter; c3: CSF
%
%   StrIm:  String containing filename for strucutral .nii
%   FunIm:  String contianing filename for functional .nii 
%           (defines space to reslice to; needs to be co-registered to StrIm!)  
%   
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 4/2017
%
%   dependencies: SPM (12)
%


%% paths

SPMdir = spm('Dir');
TPMdir = [SPMdir filesep 'tpm' filesep];%template directory (might be specific for SPM 12)

StrFolder = fileparts(StrIm);
if isempty(StrFolder)
    StrFolder = pwd;
end

if isempty(fileparts(FunIm))
    FunIm = [pwd filesep FunIm];%ensure full path
end

%% segment
matlabbatch{1}.spm.spatial.preproc.channel.vols = {StrIm};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[ TPMdir 'TPM.nii,1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[ TPMdir 'TPM.nii,2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[ TPMdir 'TPM.nii,3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[ TPMdir 'TPM.nii,4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[ TPMdir 'TPM.nii,5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[ TPMdir 'TPM.nii,6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];

spm_jobman('run', matlabbatch);
clear('matlabbatch');

%% reslice
for iTissue = 1:6
    Foo = dir([StrFolder filesep 'c' num2str(iTissue) '*.nii']);
    TissueImgs{iTissue} = [StrFolder filesep Foo.name];
end

matlabbatch{1}.spm.spatial.coreg.write.ref = {FunIm};
matlabbatch{1}.spm.spatial.coreg.write.source = TissueImgs';
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run', matlabbatch);
clear('matlabbatch');

%% write and save note (-> txt providing pointing to FunIm as reference space rc* images)

ResliceNote = ['Reslicing was done based on ' FunIm ' by BenStuff_TissueMasks.m on ' datestr(now)];
TxtPtr = fopen([StrFolder filesep 'ResliceNotes.txt'], 'wt');
fprintf(TxtPtr, '%s', ResliceNote);
fclose(TxtPtr);


end

