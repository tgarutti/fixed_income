% Function to create an AR(1) fit and provide 1, 6 and 12 step ahead forecast
function [arForecasts] = ARForecast(y)

tau = size(y,2);

arForecasts   = zeros(tau,3);
arParameters  = zeros(tau,2);
arObject      = arima(1,0,0);

for i=1:tau
    estimatedModel    = estimate(arObject,y(:,i));
    arParameters(i,1) = estimatedModel.Constant;
    arParameters(i,2) = estimatedModel.AR{1};
end

% One step ahead
arForecasts(:,1) = arParameters(:,1)+arParameters(:,2).*y(end,:)';

% 6 step ahead
arForecasts(:,2) = (1+arParameters(:,2).^2+arParameters(:,2).^3+...
    arParameters(:,2).^4+arParameters(:,2).^5).*arParameters(:,1)+...
    arParameters(:,2).^6.*y(end,:)';

% 12 step ahead
arForecasts(:,3) = (1+arParameters(:,2).^2+arParameters(:,2).^3+...
    arParameters(:,2).^4+arParameters(:,2).^5+arParameters(:,2).^6+...
    arParameters(:,2).^7+arParameters(:,2).^8+arParameters(:,2).^9+...
    arParameters(:,2).^10+arParameters(:,2).^11).*arParameters(:,1)+...
    arParameters(:,2).^12.*y(end,:)';