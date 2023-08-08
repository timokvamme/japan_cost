function  BenStuff_Img2Nii( filename )
%BenStuff_Img2Nii( filename )
%   convert hdr and img files to .nii
%   provide filename without extension

V=spm_vol([filename '.img']);
ima=spm_read_vols(V);
V.fname=[filename '.nii'];
spm_write_vol(V,ima);


end

