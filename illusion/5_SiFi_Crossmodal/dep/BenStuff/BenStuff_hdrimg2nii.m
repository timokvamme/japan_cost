function BenStuff_hdrimg2nii( filename )
%BenStuff_hdrimg2nii( filename )
%   converts nifits from hdr/nifti to single file .nii
%   filename should be full (or relative) path to hdr and img files as a 
%   string WITHOUT EXTENSION

Volume=spm_vol([filename '.img']);
image=spm_read_vols(Volume);
Volume.fname=[filename '.nii'];
spm_write_vol(Volume,image);

end

