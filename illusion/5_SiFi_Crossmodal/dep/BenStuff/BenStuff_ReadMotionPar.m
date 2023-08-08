function [M, MeanTrans, MaxTrans, RangeTrans, DistTrans, SpikeTrans, VarTrans, MeanRot, MaxRot, RangeRot, DistRot, SpikeRot, VarRot]= BenStuff_ReadMotionPar( TxtPointer, Plot, Deg )
%[M, MeanTrans, MaxTrans, RangeTrans, DistTrans, MeanRot, MaxRot, RangeRot, DistRot]= BenStuff_ReadMotionPar( TxtPointer, Plot )
%   read in estimated motion parameters from .txt SPM generated
%
%   TxtPointer: file name of .txt file (including extension)
%   Plot: optional argument to plot motion regressors (defaults to 0)
%   Deg: optional argument to convert rotation parameters from radians to
%   degrees (defaults to 0)
%
%   M: Matrix containing realingment parameters: first three columns x,y,z
%   translation in mm, columns 4:6 rotation about these in radians
%
%   MeanTrans: mean absolute amplitude across volumes and regressors
%   MaxTrans: maximum displacement across regressors
%   RangeTrans: maximum difference between deviations in either direction across
%   regressors
%   DistTrans: total distance travelled by head in multivariate space (doesn't make much sense for rotation)
%   Spike: maximum difference across two volumes (max across axes)
%   Var: mean variance across axes
%
%   '*Rot' output arguments contain the same data for rotation 
%
%
%   found a bug? Please let me know!
%   benjamindehaas@gmail.com 4/7/2014
%

if nargin<3
    Deg=0;
end

if nargin<2
    Plot=0;
end

 File=fopen(TxtPointer);
 M=fscanf(File, '%f');
 M=reshape(M,6,length(M)/6)';
 
 Trans=M(:,1:3);
 Rot=M(:,4:6);
 
 if Deg
    Rot=Rot.*(180/pi);%convert from radians to degrees
 end
 
 MeanTrans=mean(abs(Trans(:)));
 MaxTrans=max(Trans(:));
 RangeTrans=max(range(Trans));
 DistTrans=sqrt(sum(sum(diff(Trans).^2)));
 SpikeTrans = max(max(abs(diff(Trans))));
 VarTrans = mean(var(Trans));
 
 MeanRot=mean(abs(Rot(:)));
 MaxRot=max(Rot(:));
 RangeRot=max(range(Rot));
 DistRot=sqrt(sum(sum(diff(Rot).^2)));
 SpikeRot = max(max(abs(diff(Rot))));
 VarRot = mean(var(Rot));
 
 Path=fileparts(TxtPointer);%extract path from filename
 if isempty(Path)
     Path=['.' filesep];%cater for missing path (filename relative to pwd)
 end
 
 if Plot
     figure; hold on;
     set(gca, 'FontSize', 15);
     set(gca, 'FontWeight', 'b');
     
     plot(Trans, 'LineWidth', 1);
     legend({'x', 'y', 'z'});
     title('Translation');
     xlabel('Volumes');
     ylabel('Displacement [mm]');
     saveas(gcf, [Path 'TranslationPars.png'])
     close(gcf);
     
     figure; hold on;
     set(gca, 'FontSize', 15);
     set(gca, 'FontWeight', 'b');
     
     plot(Rot, 'LineWidth', 1);
     legend({'x', 'y', 'z'});
     title('Rotation');
     xlabel('Volumes');
     ylabel('Displacement [degrees]');
     saveas(gcf, [Path 'RotationPars.png'])
     close(gcf);
 end
     
 


end

