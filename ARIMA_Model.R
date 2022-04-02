library(forecast)

plot(data, type = "o")
tsdisplay(data,main = "Seasonally differenced time series")

#The data are clearly non-stationary, with some seasonality
#The ACF plot shows a seasonality, a graph of the lagged autocorrelation shows a relatively large positive autocorrelation at lag 12, with smaller peaks at lags 24 and 36
#We will start by applying a seasonal difference.Given that data are of yearly seasonality, we set the lag for differencing equal to 12.

#nsdiffs suggests to apply one seasonal differencing only
nsdiffs(data)
ndiffs(data)
ndiffs(diff(data, lag = 12))

#apply seasonal differencing
d_data<-diff(data, lag = 12)
kpss.test(d_data) #stationary
adf.test(d_data) #not stationary
tsdisplay(d_data, main = "Seasonally differenced time series")


#By observing the PACF graph, the significant spike at lag 1,3,5 in the PACF suggests a non-seasonal AR(3) component.The significant spike at lag 12 in the PACF suggests a seasonal AR(1) component. Meanwhile in ACF graph, there is a geometric decay at 12,24 and 36 lag.
fit1 <- Arima(data, order=c(3,0,0), seasonal=c(1,1,0))
summary(fit1)
#AIC=1735.77   AICc=1736.33   BIC=1749.46
checkresiduals(fit1) #not whitenoise

#PACF: lag 12 and 36 significant Seasonal AR2
fit2 <- Arima(data, order=c(3,0,0), seasonal=c(2,1,0))
summary(fit2)
#AIC=1730.16   AICc=1730.94   BIC=1746.57
checkresiduals(fit2) #not whitenoise


#Try to form a mixed model with some variations, it seems that model improved by add ing MA terms
fit3<- Arima(data, order=c(3,0,1), seasonal=c(2,1,1))
summary(fit3)
#AIC=1727.12   AICc=1728.49   BIC=1749.01
checkresiduals(fit3) #not whitenoise

#Try to decrease the AR terms, seems a much better model is found
fit4<- Arima(data, order=c(1,0,1), seasonal=c(0,1,1))
summary(fit4)
ggtsdisplay(residuals(fit4))#however, still does not pass the residual test
#AIC=1722.59   AICc=1723.14   BIC=1736.27

#Training set error measures: MAPE= 7.470719 

#----------------------------------------------------------------------
#The best model found with only seasonal differencing does not pass the residual test, I would like to know if I can still find a better model. (With only seaonsal differencing, *also as suggested by ndiffs* we only passed one stationary threshold - KPSS test. I would like to apply one more first differencing so that the data can pass both thresholds - KPSS & DF test for stationary)

#apply first differencing
d2_data<-diff(diff(data, 12), 1)
kpss.test(d2_data) #stationary
adf.test(d2_data) #stationary
tsdisplay(d2_data,main="First and seasonally differenced time series") #plot to observe the data

steps <- cbind("Original data" = data,
              "Seasonal differences" = diff(data, 12),
              "First & seasonal diffs" = diff(diff(data, 4)))
autoplot(steps, facets=TRUE) +
    xlab("Time") +
    ggtitle("Food (narrow neck) glass containers shipments (1981-1991)")

#seasonal differencing + first differencing
#By observing the ACF graph, there is a significant at lag 12 suggests a seaonsal MA(1) component. Meanwhile, there is a geometric decay at each m lag (at lag 12,24 and 36). 
#For non-seasonal time series data, there is a significant spike at 1 lag suggests a non-seasonal MA(1) component with geometric decay in PACF plot. 
#Clearly, the model here pass all of the residual tests with a smaller Training set error measure - MAPE **Cannot direcly compare the AICc with different diffs order** (Book 8.9)
# Base on this direction I would like to know if there is a even better model with a lower AICc 
fit5<- Arima(data, order=c(0,1,1), seasonal=c(0,1,1))
summary(fit5)
checkresiduals(fit5)
#AIC=1709.21   AICc=1709.43   BIC=1717.39
#Ljung-Box test,p-value = 0.03346 < 0.05 = non-whitenoise
Box.test(residuals(fit5),lag = 36, fitdf = 2,type = "Ljung-Box") 
#In addition, Box-Pierce test,p-value = 0.1295 > 0.05 = Independent
#Training set error measures: MAPE=7.456351 
ggtsdisplay(residuals(fit5), main = "Residuals from ARIMA(0,1,1)(0,1,1)[12]")
plot(forecast:::forecast(fit5, h=18))

#Both the ACF and PACF show significant spikes at lag 22, and almost significant spikes at lag 5, indicating that some additional non-seasonal terms need to be included in the model.
#Hence, 2 more non-seaonsal MA component is added to see the performance of the model. However, the model does not improv but the residuals appear to be white noise
fit6 <- Arima(data, order=c(0,1,3), seasonal=c(0,1,1))
summary(fit6)
ggtsdisplay(residuals(fit6), main = "Residuals from ARIMA(0,1,3)(0,1,1)[12]")
#AIC=1710.2   AICc=1710.76   BIC=1723.84
checkresiduals(fit6) #p-value = 0.1201 >0.05, whitenoise
Box.test(residuals(fit6),lag = 24, fitdf = 4) #Box-Pierce test,p-value = 0.8037 > 0.05 = Independent
#Training set error measures: MAPE=7.456188  
Box.test(residuals(fit6),lag = 36, fitdf = 4, type = "Ljung-Box")#p-value = 0.09962
plot(forecast:::forecast(fit5, h=18))

#Only fit 6 has passed the Ljung-Box test, I will use fit 6 for forecasting.

#Use fit 5 to forecast ---------------------------------------------------
plot(forecast:::forecast(fit6, h=18,level = c(80,90,95,99)))

