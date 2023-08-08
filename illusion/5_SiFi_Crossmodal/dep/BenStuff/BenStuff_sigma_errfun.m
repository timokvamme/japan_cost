function err = BenStuff_sigma_errfun(ApFrm, Hrf, x0,y0,Sigma,Beta,Y)
%
% err = BenStuff_sigma_errfun(ApFrm, Hrf, x0,y0,Sigma,Beta,Y)
%
% Returns the error residuals between the prediction defined by x0, y0, Sigma and Beta 
% versus the observed data in Y. This function is named _sf
% because it is for minimising squared residuals. Both the fast and slow
% fits of the standard pRF model use this function however. 
%
%   ApFrm contains aperture frames. 
%   Hrf is the hemodynamic response function
%
% modified from SamSrf to fit only sigma by Ben
%
% found a bug? please let me know!
% benjamindehaas@gmail.com
%

Rfp = prf_gaussian_rf(x0,y0,Sigma);
Yp = prf_predict_timecourse(Rfp, ApFrm, false);
Yp = conv(Yp, Hrf);
Yp = Yp(1:length(Y));
Yp = Yp * Beta;
err = sum((Y-Yp).^2);
    