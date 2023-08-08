function [ B0, B1, Y_hat, Resid, R2, FigHandle ] = BenStuff_LinReg( X,Y, Fig )
%[ B0, B1, Y_hat, Resid, FigHandle ] = BenStuff_LinReg( X,Y, Fig )
%   linear regression: Y_hat = B0 + B1.*X and 
%                      Y = Y_hat + Resid
%
%   R2 is the coefficient of determination (R^2)
%   optional plot when Fig is set to 1 (defaults to 0)
%
%   c.f. http://uk.mathworks.com/help/matlab/data_analysis/linear-regression.html
%
% found a bug? please let me know!
% benjamindehaas@gmail.com 10/2015
%

if nargin<3
    Fig = false;
end

X2 = [ones(length(X),1) X];%prepad columns of 1s to fit intercept
B = X2\Y;
B0 = B(1);
B1 = B(2);

Y_hat = B0 + B1.*X;

Resid = Y - Y_hat;

R2 = 1 - sum((Y - Y_hat).^2)./sum((Y - mean(Y)).^2);

if Fig
    FigHandle = figure; hold on;
    scatter(X,Y, 'LineWidth', 2);%data
    line([min(X), max(X)], [min(X), max(X)].*B1+B0);%fit
    line([X, X]', [Y, Y_hat]', 'LineStyle', '--', 'Color', 'r');%show residuals
else
    FigHandle =[];
end%if Fig


end

