function BenStuff_MergeMasks( MaskPath )
%BenStuff_MergeMasks( MaskPath )
%   function to merge dorsal and ventral bits of V2 and V3 masks
%   expects MaskPath to contain niftis called *h_V*v and *h_V*d, results
%   will be saved in MaskPath as *_V*
%   uses SPM functions
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 11/2014

StartDir=pwd;
MaskNames={'lh_V2', 'lh_V3', 'rh_V2', 'rh_V3'};
cd(MaskPath);

for iMask=1:length(MaskNames)
    MaskName=MaskNames{iMask};
    DorsalFile=[MaskPath MaskName 'd.nii'];
    VentralFile=[MaskPath MaskName 'v.nii'];
    if ~exist(DorsalFile)
        error([DorsalFile ' could not be found!']);
    else
        Hdr=spm_vol(DorsalFile);
        Dorsal=spm_read_vols(Hdr);
    end
    
    if ~exist(VentralFile)
        error([VentralFile ' could not be found!']);
    else
        Ventral=spm_read_vols(spm_vol(VentralFile));
    end
    
    Whole=Ventral|Dorsal;%combine the two
    
    Hdr.dt(1)=64;%save as double 
    Hdr.fname=[MaskName '.nii'];
    spm_write_vol(Hdr,Whole);   
    display(['saved ' MaskPath MaskName '.nii'])
    
end%for iMask

cd(StartDir);

end

