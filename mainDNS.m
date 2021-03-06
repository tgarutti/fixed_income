%% Open folder (Windows)
clc
clear 
pad = '/Users/user/Documents/Repositories/fixed_income';
cd(pad);
format short

%% Load data
filename = 'GLC Nominal month end data_1970 to 2015';
[data_short,~] = xlsread(filename,'3. spot, short end','B332:BI521');
[data_long,~] = xlsread(filename,'4. spot curve','L332:AO521');
[maturities_short,~] = xlsread(filename,'3. spot, short end','B4:BI4');
[maturities_long,~] = xlsread(filename,'4. spot curve','L4:AO4');
data_short(:,61:90) = data_long;              % Concatenate all data
yieldData = data_short';                      % for both yields and
maturities_short(:,61:90) = maturities_long;  % maturities, then transpose
tau = maturities_short';                      % to get proper form
tau = 12*tau';

%% Calculate summary statistics of yield data
averageYield = zeros(1,size(tau,2));
stdYield     = zeros(1,size(tau,2));

for i=1:size(tau,2)
    averageYield(i) = mean(yieldData(i,:));
    stdYield(i)     = std(yieldData(i,:));
end

% Autocorrelations up to 20 lags for all relevant yields (index = month)
[acf1,~,~] = autocorr(yieldData(3,:));      % 3 month
[acf2,~,~] = autocorr(yieldData(6,:));      % 6 month
[acf3,~,~] = autocorr(yieldData(9,:));      % 9 month
[acf4,~,~] = autocorr(yieldData(12,:));     % 1 year    
[acf5,~,~] = autocorr(yieldData(18,:));     % 1.5 year
[acf6,~,~] = autocorr(yieldData(24,:));     % 2 year    
[acf7,~,~] = autocorr(yieldData(30,:));     % 2.5 year
[acf8,~,~] = autocorr(yieldData(36,:));     % 3 year
[acf9,~,~] = autocorr(yieldData(48,:));     % 4 year
[acf10,~,~] = autocorr(yieldData(60,:));    % 5 year
[acf11,~,~] = autocorr(yieldData(64,:));    % 7 year
[acf12,~,~] = autocorr(yieldData(70,:));    % 10 year
[acf13,~,~] = autocorr(yieldData(90,:));    % 20 year

autocorrelations = [acf1',acf2',acf3',acf4',acf5',acf6',...
                    acf7',acf8',acf9',acf10',acf11',acf12',acf13'];
                
% Keep only the 1st, 6th, 12th, and 20th order autocorrelations
autocorrelations = [autocorrelations(2,:);autocorrelations(7,:);...
                    autocorrelations(13,:);autocorrelations(21,:)]';

% Remove autocorrelation functions to clear workspace
clear acf1 acf2 acf3 acf4 acf5 acf6 acf7 acf8 acf9 acf10 acf11 acf12 acf13

% Create matrix of relevant yields
yields = [yieldData(3,:);yieldData(6,:);yieldData(9,:);yieldData(12,:);
        yieldData(18,:);yieldData(24,:);yieldData(30,:);yieldData(36,:);
        yieldData(48,:);yieldData(60,:);yieldData(64,:);yieldData(70,:);
        yieldData(90,:)]';
        
% Calculate cross correlations
crossCorr = corrcoef(yields);

%% Plot relevant data
figure
plot(tau,yieldData(:,10))
hold on
plot(tau,yieldData(:,45))   % Plot four yield curves at random
plot(tau,yieldData(:,103))
plot(tau,yieldData(:,140))
grid on
title('Yield Curves','FontSize',30)
ylabel('Yield $[\%]$','FontSize',14,'FontWeight','bold','Color','k',...
    'Interpreter','latex')
xlabel('Maturities [months]','FontSize',14)
legend({'31 Dec 1997','30 Nov 2000',...
    '30 Sep 2005', '31 Oct 2008'},'Location','southeast');
set(gca,'FontSize',16)
set(gca,'FontName','Times New Roman')

% Plot average yield curve against maturity length
figure
plot(tau,averageYield);
grid on
title('Average Yield Curve for UK Gilts','FontSize',30)
ylabel('Yield $[\%]$','FontSize',14,'FontWeight','bold','Color','k',...
    'Interpreter','latex')
xlabel('Maturities [months]','FontSize',14)
set(gca,'FontSize',16)
set(gca,'FontName','Times New Roman')

%% Find lambda that maximises curvature factor loading
N            = 10000;
B            = zeros(size(yieldData,1),3,N);
betaLoadings = zeros(3,size(yieldData,2),N);
betaLoadingMeans = zeros(3,100);
lambda       = linspace(0.001,1,N);
maxBThree    = zeros(1,N);

for i=1:N
    for j=1:size(yieldData,1)
        factor1 = 1;
        factor2 = (1-exp(-lambda(i)*tau(j)))/(lambda(i)*tau(j));
        factor3 = (1-exp(-lambda(i)*tau(j)))/(lambda(i)*tau(j))-exp(-lambda(i)*tau(j));
        B(j,1,i) = factor1;
        B(j,2,i) = factor2;
        B(j,3,i) = factor3;
    end
    betaLoadings(:,:,i) = (B(:,:,i)'*B(:,:,i))\(B(:,:,i)'*yieldData);
    
    maxBThree(i)     = max(B(:,3,i));
    avgBThree(i)     = mean(B(:,3,i));
    avg23BThree(i)   = mean(B(24:36,3,i));
    thirtyBThree(i)  = B(30,3,i);
end

[MaxBThree,k]   = max(avgBThree);
[~,i]           = max(avg23BThree);
[~,j]           = max(thirtyBThree);
lambdaDiLi      = lambda(j);
lambdaAvg23     = lambda(i);
lambdaMax       = lambda(k);

figure
plot(lambda,avgBThree,'Color','b','LineWidth',1.5)
hold on
plot(lambda,avg23BThree,'Color','r','LineWidth',1.5)
plot(lambda,thirtyBThree,'Color','g','LineWidth',1.5)
grid on
title('Estimated $\hat{\beta}_{3t}$ against Parameter $\lambda_t$',...
    'FontSize',30,'bold','Interpreter','latex')
ylabel('$\hat{\beta}_{3t}$ Factor','FontSize',14,'FontWeight','bold','Color','k',...
    'Interpreter','latex')
xlabel('$\lambda_t$','FontSize',14,'Interpreter','latex')
legend({'Average $\hat{\beta}_{3t}$, All Maturities',...
    'Average $\hat{\beta}_{3t}$, 2-3 Years',...
    '$\hat{\beta}_{3t}$, 2.5 Years (30 Months)'},'Interpreter','latex',...
    'Location','northeast');
set(gca,'FontSize',16)
set(gca,'FontName','Times New Roman')

%% We use the Diebold and Li value of 0.0597 for modelling/forecasting
forecastedYieldsAR = zeros(13,36,3);
forecastedYieldsVAR = zeros(13,36,3);
forecastedYieldsDNS = zeros(13,36,3);

tau13 = [3, 6, 9, 12, 24, 60, 120, 240]; 

% Moving window forecasts
for i=1:36
    t = i-1;
    T = size(yields,1);
    arForecasts = ARForecast(yields(1+t:T-(36-t),:));
    varForecasts = VARForecast(yields(1+t:T-(36-t),:));
    dnsForecasts = DNS(yields(1+t:T-(36-t),:)')';
    for j=1:3
        forecastedYieldsAR(:,i,j) = arForecasts(:,j);
        forecastedYieldsVAR(:,i,j) = varForecasts(:,j);
        forecastedYieldsDNS(:,i,j) = dnsForecasts(:,j);
    end
end

%% Mean Forecast Errors

% 1-step ahead

%mse_1 = zeros(13,2);

%mse_1(