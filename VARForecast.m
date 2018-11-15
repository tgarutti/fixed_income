% Function to creat a VAR model and provide 1 step ahead forecast
function [varForecast] = VARForecast(y)

tau = size(y,2);
T   = size(y,1);

Z = zeros(tau+1,T-1);
Z(1,:) = ones(1,T-1);
adjustedYields = y';

for i=1:tau
    for j=1:T-1
        Z(i+1,j) = adjustedYields(i,j);
    end
end

B = adjustedYields(:,2:end)*Z'*(inv(Z*Z'));
varForecast = B(:,1)+B(:,2:end)*y(end,:)';