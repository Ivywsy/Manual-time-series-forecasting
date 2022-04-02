# Manual time-series forecasting with regression, ETS and ARIMA models
* Written by: [Ivy Wu S.Y.](https://www.linkedin.com/in/ivy-wusumyi)
* Technologies: R, forecast, tseries, ggplot2


## 1. Introduction
This project aims to utilise R and manual forcasting techniques (regression, exponential smoothing, ARIMA models) to forecast a monthly time series dataset of food glass containers shipments from January 1981 to June 1991. A forecast of 18 months is produced by each model with highest forecast accuracy in conjunction with residual diagnostics and parameter testings.


## 2. About the data
The data used is provided by the International Institute of Forecasters and available in the [M3-Competition package](https://cran.r-project.org/web/packages/Mcomp/index.html) in R (Series ID 1911).It is a monthly data of food (narrow neck) glass containers shipments from January 1981 to June 1991, implying 126 data points in total. <br/>
<img src="/images/M3_1911.PNG?raw=true" width="550"> 

A classical data decomposition is used to separate the seasonal, trend and reminder components. It is observed that a seasonal pattern occurs with a fixed frequency every year in which the shipment volume usually raises from January to March and fluctuates until it reached a peak in August and eventually experienced a steep drop until the end of the year. On the other hand, the decomposed trend exhibits serval rises and falls that can be observed in the data and are not of a fixed frequency. The duration of those fluctuations is about 3 to 4 years. In light of this, it is suspected that a cyclic behavior is also present in this shipments data with the fluctuations of the economic or business cycles effects from 1981 to 1991.<br/>
<img src="/images/data_decomposition.PNG?raw=true" width="1100">


## 3. Regression Model
Given the observed strong seasonality and trend, a multiple linear regression model of shipments is fitted on the seasonal and trend indicators. The independent variables are trend variable and 9 dummy variables created for 10 months, whereas one month is represented by the intercept. Two redundant seasonal variables (February and October) are dropped due to non-significant p-value observed. By running the regression model, the adjusted R-squared of 72.73% is obtained indicating this model can explain 72.73% of data variation. The plot below shows the fitted values exhibit the same seasonal pattern as the observed value and it has a good fit in terms of the spikes in shipment volume.<br/>
<img src="/images/regression.PNG?raw=true" width="550">

### 3.1 A 18 months forecast by regression model
A forecast of 18 months is produced with above model using 80%, 90%, 95% and 99% confidence levels. The forecast shows the seasonality with a slightly downward trend. As the confidence level increases, more variation is allowed in the forecast resulting in a larger area between upper and lower limits. <br/>
<img src="/images/regression_forecast.PNG?raw=true" width="550">


## 4. ETS Model
To fit an exponential smoothing method, the components of error(E), trend(T) and seasonal(S) should be decided based on the appearance of the time series data. AICc will be used to evaluate the fit of each model whereas a smaller value of AICc indicates a better model. By serveral model testings, a multiplicative error component with additive seasonality (“MNA”) gives the best AICc value of 2134.<br/>
<img src="/images/ETS.PNG?raw=true" width="550">

### 4.1 A 18 months forecast by ETS (MNA) model
It is worth noting that the exponential smoothing method suggests no trend in the time series, but the previous regression model does. This is because exponential smoothing emphasizes higher weight on more recent observations than older observations. Although there is a downward trend at the beginning of time series, the trend reached a plateau from 1987 to 1911, causing no trend on recent observations.A forecast of 18 months is produced with ETS(MNA) Model using 80%, 90%, 95% and 99%  confidence levels. The forecast demonstrates clear seasonality with no upward or downward trend.<br/>
<img src="/images/ETS_forecast.PNG?raw=true" width="550">


## 5. ARIMA Model
ARIMA model is another approach for time series forecasting by describing autocorrelations in the data. Both first differencing and seaonality differencing are applied to the time series data to reach stationary. The ACF and PACF plots will be used to determine the ARIMA ordering.<br/>
<img src="/images/ARIMA.PNG?raw=true" width="550">

By residual diagnostics and parameter testings, it is suggested that a seasonal MA(1) component and a non-seasonal MA(3) component should be used to create an ARIMA (0,1,3)(0,1,1)<sub>12</sub> model with white noise appears in its residuals.<br/>
<img src="/images/ARIMA_model.PNG?raw=true" width="550">

### 5.1 A 18 months forecast by ARIMA(0,1,3)(0,1,1)<sub>12</sub> model
A forecast of 18 months is produced with 80%, 90%, 95% and 99% confidence levels. The forecast demonstrates clear seasonality with no upward or downward trend, which is similar to the previously selected ETS model.<br/>
<img src="/images/ARIMA_forecast.PNG?raw=true" width="550">


### To learn more about Ivy Wu S.Y., visit her [LinkedIn profile](https://www.linkedin.com/in/ivy-wusumyi)

All rights reserved 2022. All codes are developed and owned by Ivy Wu S.Y..