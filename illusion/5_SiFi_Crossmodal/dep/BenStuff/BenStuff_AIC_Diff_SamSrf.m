function AIC_Srf = BenStuff_AIC_Diff_SamSrf( Srf1, Srf2, K1, K2)
% AIC_Srf = BenStuff_AIC_Diff_SamSrf( Srf1, Srf2, K1, K2)
%   
%   BEWARE! THIS STEMS FROM A STATS AMATEUR AND SHOULD BE DOUBLE-CHECKED 
%   BY SOMEONE WHO KNOWS WHAT SHE IS DOING! NO GUARANTEES WHATSOEVER! 
%   If you are that knowledgeable person I'd be grateful for
%   any kind of feedback to benjamindehaas@gmail.com
%   
%   calculates the difference in the Akaike Information Criterion between
%   two models fitted to the data (model1 - model2) from the respective
%   Srf structs.
%
%   the output ia a Srf struct containing AIC difference values for
%   each voxel wrt the models compared. the model with lower score is to be 
%   preferred (i.e. positive values favour Srf2 over Srf1), 
%   Ignoring multiple comparisons a value of about 4 is considered significant. 
%   the difference in bayesian information criterion is also given in a field of this struct. 
%   BIC tends to penalise additional parameters more than AIC. 
%   
%   Srf1: Srf struct for first fitted model
%   Srf2: Srf struct for second fitted model 
%   K1: number of fitted paramters of the first model
%   K2: number of fitted parameters of the second model 
%
%   nicked from wiki: 
%   http://en.wikipedia.org/wiki/Akaike_information_criterion c.f. http://www.researchgate.net/post/What_is_the_AIC_formula
%   http://en.wikipedia.org/wiki/Bayesian_information_criterion BEWARE -
%   this might be wrong, check out discussion page on wiki
%
%   
%   Please note that voxels with little explained variance by either model 
%   (which could be quite many) will simply prefer the model with fewer parameters - maybe massively so.
%   This does *not* neccessarily mean *any* of the compared models is any good. 
%   I highly recommend taking into account absolute model fit as well (such
%   as % variance explained).
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com
 
%   RSS1: residual sum of squares for model 1
%   RSS2: residual sum of squares for model 2
%   n1: size of sample 1
%   n2: size of sample 2


%% retrieve residuals 

if isfield(Srf1, 'Ys') && isfield(Srf2, 'Ys')
    disp('using smoothed data for model comparison');

    RS1=(Srf1.Ys-Srf1.X).^2;%residual squares
    RSS1=nansum(RS1,1);%residual sum of squares across time series

    RS2=(Srf2.Ys-Srf2.X).^2;%residual squares
    RSS2=nansum(RS2,1);%residual sum of squares across time series
else
    RS1=(Srf1.Y-Srf1.X).^2;%residual squares
    RSS1=nansum(RS1,1);%residual sum of squares across time series

    RS2=(Srf2.Y-Srf2.X).^2;%residual squares
    RSS2=nansum(RS2,1);%residual sum of squares across time series
end


%% retrieve number of observations for each model 
n1=size(Srf1.X,1);
n2=size(Srf2.X,1);

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

%% write to Srf struct
AIC_Srf=Srf1;

Fields={'Data', 'Y', 'Ys', 'X', 'Values', 'Raw_Data', };
for iField=1:length(Fields)
    if isfield(AIC_Srf, Fields{iField})
        rmfield(AIC_Srf, Fields{iField});
    end
end

AIC_Srf.Functional='AIC_difference between models';%Srf files don't contain info on actual models fitted so we can't retrieve them!
AIC_Srf.AIC_Difference=AIC_Diff;
AIC_Srf.BIC_Difference=BIC_Diff;

end