function [ beta, forecasts ] = DNS(yields, tau)
%DNS Dynamic Nelson Siegel estimation
%   The yields vector should be of dimensions -> maturities x date 
%   or (nxT) where n is the number of maturities.
lambda = 0.0597;

n_maturities = length(tau);
B = zeros(n_maturities, 3);
f = zeros(3, 2);

% Estimate the level, slope and curvature factors
B(:,1) = ones(n_maturities, 1);
B(:,2) = (lambda*tau')./(1-exp(-lambda*tau'));
B(:,3) = B(:,2)-exp(-lambda*tau');

beta = (B'*B)\(B'*yields);
beta1 = beta(:,1:(length(beta(1,:))-1));
beta2 = beta(:,2:length(beta(1,:)));

% Estimate the factor dynamics
for i=1:3
    x = cat(1,ones(1,length(beta2(1,:))), beta2(i,:));
    f(i,:) = (x*x')\(x*beta1(i,:)');
end

% Forecast the level, slope and curvature factors
forecasts = zeros(3, n_maturities);
phi = f(:,2);
c = f(:,1);
bt = beta(:,end);

% One-step ahead
beta_f1 = c + phi.*bt;
forecasts(1,:) = B*beta_f1;

% Six-step ahead
beta_f6 = c.*(1 + phi + phi.^2 + phi.^3 + phi.^4 + phi.^5) + phi.*bt;
forecasts(2,:) = B*beta_f6;

% Twelve-step ahead
beta_f12 = c.*(1 + phi + phi.^2 + phi.^3 + phi.^4 + phi.^5 + phi.^6 ...
+ phi.^7 + phi.^8 + phi.^9 + phi.^10 + phi.^11) + phi.*bt;
forecasts(3,:) = B*beta_f12;

end