function BenStuff_Average4Dnii( Files , detrending, zscoring, OutName)
% BenStuff_Average4Dnii( Files , [detrending], [zscoring], [OutName])
%   average 4-D nii files
%
%   Files is a cell aray with filenames
%   detrending: optional detrending before averaging; defaults to 1
%   zscoring: optional z-scoring before averagin; defaults to 1
%   OutName: name of stored output file; defaults to 'Avg_4D.nii'
%
%

if nargin<4 
    OutName='Avg_4D.nii';
end

if nargin<3 
    zscoring=1;
end

if nargin<2
    detrending=1;
end

%% here we go

for iFile=1:length(Files)
    Mat=spm_read_vols(spm_vol(Files{iFile}));
   
    if zscoring
        Mat=BenStuff_nzscore(Mat,4);
    end
    if detrending
        Mat=BenStuff_ndetrend(Mat,4);
    end
    
    BigMat(:,:,:,:,iFile)=Mat;
    
end


 %read in template hdr
V=spm_vol(Files{1});
Hdr=V(1);
Hdr.dt(1)=64;%save as double 
    
%average across runs
Avg=squeeze(mean(BigMat,5));


 %now write (annoyingly it seems we have to revert to 3D for that and than merge again)
PrevFolder=pwd;
 mkdir([pwd filesep 'Foo' filesep]);
 cd (['.' filesep 'Foo' filesep]);
for iVol=1:size(Avg,4)
    Hdr.fname=['Average' num2str(iVol) '.nii'];
    spm_write_vol(Hdr, squeeze(Avg(:,:,:,iVol)));
end
    
%now merge stuff again...
for iVol=1:size(Avg,4)
    EPIs{iVol}=[pwd filesep 'Average' num2str(iVol) '.nii'];
end

spm_file_merge(EPIs, [PrevFolder filesep OutName]);


%finally, clean up
delete('Average*.nii');
cd(PrevFolder);
rmdir(['.' filesep 'Foo' filesep]);

end

