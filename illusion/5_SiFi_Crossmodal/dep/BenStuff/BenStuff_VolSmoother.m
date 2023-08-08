function BenStuff_VolSmoother( AllImages, KernelSize )
%VolSmoother( Files, KernelSize ); 
%Smoothes AllImages with a kernel of KernelSize mms using SPM code
%
% found a bug? 
  

    Batch_No=1;

    matlabbatch{Batch_No}.spm.spatial.smooth.data = AllImages;

    %settings
    matlabbatch{Batch_No}.spm.spatial.smooth.fwhm = [KernelSize KernelSize KernelSize];%5mm FWHM
    matlabbatch{Batch_No}.spm.spatial.smooth.dtype = 0;
    matlabbatch{Batch_No}.spm.spatial.smooth.im = 0;
    matlabbatch{Batch_No}.spm.spatial.smooth.prefix = ['s0' num2str(KernelSize)];

    disp(['Smoothing with kernelsize ' num2str(KernelSize) ' - started ' datestr(now)]);
    
    %Run the batch
    spm_jobman('run_nogui', matlabbatch);
    clear matlabbatch

end

