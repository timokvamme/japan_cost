function [AIC_DiffV, BIC_DiffV] = BenStuff_AIC_Diff_SPM( SPM1, SPM2, ResMS1, ResMS2)
%[AIC_Diff, BIC_Diff] = BenStuff_AIC_SPM( SPM1, SPM2, ResMS1, ResMS2)
%   
%   BEWARE! THIS STEMS FROM A STATS AMATEUR AND SHOULD BE DOUBLE-CHECKED 
%   BY SOMEONE WHO KNOWS WHAT SHE IS DOING! NO GUARANTEES WHATSOEVER! 
%   If you are that knowledgeable person I'd be grateful for
%   any kind of feedback to benjamindehaas@gmail.com
%   
%   calculates the difference in the Akaike Information Criterion between
%   two models fitted to the data (model1 - model2) from the respective
%   SPMs and ResMS images.
%
%   the output ia an image containing AIC difference values for
%   each voxel wrt the models compared. the model with lower score is to be 
%   preferred (i.e. positive values favour SPM2 over SPM1), 
%   Ignoring multiple comparisons a value of about 4 is considered significant. 
%   optionally the difference in bayesian information criterion is given as well. 
%   BIC tends to penalise additional parameters more than AIC. 
%   
%   SPM1: SPM struct for first fitted model
%   SPM2: SPM struct for second fitted model 
%   ResMS1: string pointer to scaled residues image for first fitted model (.img file)
%   ResMS2: string pointer to scaled residues image for first fitted model (.img file)
%
%   nicked from wiki: 
%   http://en.wikipedia.org/wiki/Akaike_information_criterion c.f. http://www.researchgate.net/post/What_is_the_AIC_formula
%   http://en.wikipedia.org/wiki/Bayesian_information_criterion BEWARE -
%   this might be wrong, check out discussion page on wiki
%
%   also, thank God for http://www.its.caltech.edu/~nsulliva/spmdatastructure.htm   
%
%   Please note that voxels with little explained variance by either model 
%   (which could be quite many) will simply prefer the model with fewer parameters - maybe massively so.
%   This does *not* neccessarily mean *any* of the compared models is any good. 
%   I highly recommend taking into account absolute model fit as well (such
%   as % variance explained).
%
%   found a bug?
%   please let me know: benjamindehaas@gmail.com

%   K1: number of fitted paramters of the first model
%   K2: number of fitted parameters of the second model  
%   RSS1: residual sum of squares for model 1
%   RSS2: residual sum of squares for model 2
%   n1: size of sample 1
%   n2: size of sample 2


%% retrieve residuals - c.f. https://www.jiscmail.ac.uk/cgi-bin/webadmin?A3=ind0709&L=SPM&E=7bit&P=1811254&B=------%3D_Part_11346_8872195.1190355704153&T=text%2Fhtml;%20charset=ISO-8859-1
DoF1=SPM1.xX.trRV;
ScaledRes1=spm_read_vols(spm_vol(ResMS1));%contains residuals divided by effective degrees of freedom
RSS1=ScaledRes1.*DoF1;

DoF2=SPM1.xX.trRV;
ScaledRes2=spm_read_vols(spm_vol(ResMS2));
RSS2=ScaledRes2.*DoF1;

%% retrieve number of fitted parameters and observations for each model (should correspond to lines and columns of raw design matrix)
n1=size(SPM1.xX.X,1);
K1=size(SPM1.xX.X,2);

n2=size(SPM2.xX.X,1);
K2=size(SPM2.xX.X,2);

%% Calculate AICs (note that this will be offset by a constant - which doesn't matter for comparison)

AIC1=n1.*log(RSS1./n1)+2.*K1;
AIC1=AIC1+(2.*K1.*(K1+1))./(n1-K1-1);%correction for finite sample size

BIC1=n1.*log(RSS1./(n1-1))+K1.*log(n1);

AIC2=n2.*log(RSS2./n2)+2*K2;
AIC2=AIC2+(2.*K2.*(K2+1))./(n2-K2-1);%correction for finite sample size

BIC2=n2*log(RSS2./(n2-1))+K2.*log(n2);

%% Calculate Difference
AIC_Diff=AIC1-AIC2;

BIC_Diff=BIC1-BIC2;

%% write to volumes
ResHdr=spm_vol(ResMS1);
AIC_hdr.fname='AIC_difference.nii';
AIC_hdr.mat=ResHdr.mat;
AIC_hdr.dt=ResHdr.dt;
AIC_hdr.dim=ResHdr.dim;
AIC_hdr.pinfo=[1 0 0]';

BIC_hdr=AIC_hdr;
BIC_hdr.fname='BIC_difference.nii';

AIC_DiffV=spm_write_vol(AIC_hdr, AIC_Diff);

BIC_DiffV=spm_write_vol(BIC_hdr, BIC_Diff);

end