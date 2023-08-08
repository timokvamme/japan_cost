function [PearsonR, PearsonP, SpearmanR, SpearmanP, yhat, R2 ] = BenStuff_CrossValCorr( x,y, MathMagic, OmNullModel )
%[PearsonR, PearsonP, SpearmanR, SpearmanP, yhat, R2 ] = BenStuff_CrossValCorr( x,y, [MathMagic], [OmNullModel] )
%   leave-one-out crossvalidated linear regression 
%
%   x, y:           vectors of data (x(n) and y(n) correspond to a pair of observations)
%   MathMagic:      optional parameter; defaults to 1 - avoid looping through n models
%                   with the power of MathMagic (http://stats.stackexchange.com/questions/164223/proof-of-loocv-formula)  
%   OmNullModel:    optional parameter; defaults to 1 - should null model
%                   for R2 be 'omnisicent'?
%                   if set to 1 (default) R2 will compare explained variance against variance around mean
%                   of *all* data points; if set to 0 will comapre against iteration-specific mean excluding data point to predict
%
%   PearsonR:       Pearson correlation between predicted and observed values
%   PearonP:        p-value for PearsonR
%   SpearmanR:      Spearman correlation between predicted and observed values
%   SpearmanP:      p-value for SpearmanR
%   yhat:           LOO predicted values
%   R2:             cross-validated proportion of variance in y explained
%                   by x-based predictions
%
%   NOTE: depressingly, LOOCV isn't the holy grail either 
%         (according to http://www.sciencedirect.com/science/article/pii/S1093326301001231 high LOO R^2 is a
%          neccesary but not sufficient condition for (true) predictive validity) 
%         also check out http://andrewgelman.com/2015/06/02/cross-validation-magic/ for
%         some general words of caution
%
%   found a bug? please let me know!
%   benjamindehaas@gmail.com 11/2015
%

assert(all(size(x)==size(y) & isvector(x)), 'x and y have to be vectors of equal size!');


if nargin < 3
    MathMagic = 1;
end

if nargin < 4
    OmNullModel = 1;
end

if isrow(x)
    x = x';
    y= y';
end

n = length(x);

%% math-y magic
if MathMagic %avoid loop - esp useful if n is large
    fx = [ones(size(x)), x];%model intercept as well
    b = fx\y;%simple linear regression
    yhat = b(1)+b(2).*x;%prediction
    
    SSx = sum((x-mean(x)).^2);
    h = 1./n + ((x - mean(x)).^2)./SSx;% here math-y magic happens...
    Err = (y-yhat)./(1-h);
    Res = sum(Err.^2);%...leave-one-out residuals without the loop!
    Pred = y-Err;    
    
%% by foot...
else%if not MathMagic - mainly to be able to validate MathMagic - it's a bit spooky
    
    Ind = true(size(x));%indices
    Err = nan(size(x));%initialise

    for iFold = 1:n
        iInd = Ind;%indices for this iteration
        iInd(iFold) = false;
        iX =  x(iInd);
        iX = [ones(size(iX)), iX];%model intercept as well
        iY = y(iInd);

        b = iX\iY;%simple linear regression
        Pred(iFold) = b(1)+b(2).*x(iFold);%leave-one out prediction
        Obs(iFold) = y(iFold);%observed sample  
    end%for iFold
    Err = Pred-Obs;
    Res = sum(Err.^2);%residuals: sum of squared prediction errors
end%if MathMagic

%% calculate variables of interest
yhat = Pred;
if isrow(yhat)
    yhat = yhat';
end

[PearsonR, PearsonP] = corr(y,yhat);
[SpearmanR, SpearmanP] = corr(y,yhat, 'type', 'Spearman');


if OmNullModel
    SS = sum((y-mean(y)).^2);%compare to 'omniscient' null model - sum of squared deviations from mean *including* left out data point
else
    Ind = true(size(x));%indices
    for iFold = 1:n
        iInd = Ind;%indices for this iteration
        iInd(iFold) = false;
        SS(iFold) = y(iFold) - mean(y(iInd));%sum of squares around LOO means 
                                             % -> this means we compare to *prediction* based on *LOO* mean
                                             % rather than to mean including left out data point 
    end
    SS = sum(SS.^2);       
end

R2 = 1-(Res./SS);%proportion of variance explained across LOOCV iterations 
                 % -> note that this can become negative if predictions
                 % have more variance than actual data

end

