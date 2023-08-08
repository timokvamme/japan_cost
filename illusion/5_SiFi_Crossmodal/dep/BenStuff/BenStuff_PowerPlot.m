function PlotHandle = BenStuff_PowerPlot(FunIms, RoiMask, NoiseMask, MotionTxt)
%PlotHandle = BenStuff_PowerPlot(FunIms, RoiMask, NoiseMask, [MotionTxt])
%   function to do a 'Power plot' of a nii time series for QA
%
%   produces a voxel by TR heat map with signal of interest (GM) in a top section 
%   and nuissance signals in a lower section (WM and CSF)
%
%   will use SPM to segment structural provided and re-slice tissue class
%   images to functional space
%   
%   SPM estimates of head motion will be shown on top if provided
%
%   FunIms:     Cell string with filenames of functional images (nii) or sngle 4D nii file
%   RoiMask:    Matrix of Roi mask in register with FunIms (e.g. gray matter segmentation; c.f. BenStuff_TissueMasks)
%   NoiseMask:  Matrix of mask for parts of FunIms containing potential nuissance signals (e.g. WM and CSF segmentations)
%   MotionTxt:  Optional, filename of motion regressors estimated by SPM
%               (string)
%
%   PlotHandle: Handle for figure output
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 4/2017
%
%   dependencies: 
%       -> BenStuff_ReadMotionPar
%       -> SPM (spm_vol & spm_read_vols)
%


%% read in data

% time series
V = spm_vol(FunIms);
NumVols = length(V);

for iVol = 1:NumVols%needed to circumvent buggy spm_check_orientations (which appears to expect V to be a single struct rather tan a cell vector of structs [defeating the point, sort of] ) 
    M(:,:,:, iVol) = spm_read_vols(V{iVol}); 
end

% Masks
Roi = RoiMask; %spm_read_vols(spm_vol(RoiMask));
Nuissance = NoiseMask; %spm_read_vols(spm_vol(NoiseMask));

Roi = logical(repmat(Roi, [1, 1, 1, NumVols]));%turn into 4D
Nuissance = logical(repmat(Nuissance, [1, 1, 1, NumVols]));

%coresponding motion regressors
if nargin > 3
    [Foo, Foo, Foo, Foo, DistTrans, Foo, Foo, Foo, Foo, Foo, DistRot, Foo, Foo]= BenStuff_ReadMotionPar( MotionTxt, 0, 1);%we want the distance travelled in mm (translation) and deg (rotation)
end%if nargin > 1


%% apply masks and flatten to 2D
RoiM = reshape(M(Roi), [size(M(Roi),1) ./ NumVols, NumVols]);
NuissanceM = reshape(M(Nuissance), [size(M(Nuissance),1) ./ NumVols, NumVols]);

Image = [RoiM; NuissanceM];
NumRoiVoxels = size(RoiM, 1);

%% now plot
PlotHandle = figure; hold on;
imagesc(Image);
colormap gray;
colorbar;
line([0 size(Image, 2)], [NumRoiVoxels, NumRoiVoxels], 'LineWidth', 1)

if nargin > 3
    
end%if nargin > 3






end

