library(forecast)
library(Mcomp)

#Plot the data
plot(data, type="o") 
#trend + seasonality
#Cant see if it is additive/multiplicative 

#Decompose
decomp <- decompose(data,type = "additive")
plot(decomp)

data %>% decompose(type="additive") %>%
    autoplot(main = "Decomposition of M3 Series 1911")+
    theme(plot.title = element_text(hjust = 0.5))

#Seasonal plot
ggseasonplot(data, year.labels=TRUE, year.labels.left=TRUE) +
    ylab("data") +
    ggtitle("Seasonal plot: Food (narrow neck) glass containers shipments ")+
    theme_bw()+
    theme(plot.title = element_text(hjust = 0.5))


#ETS 1: Additive Error, No Trend, No Seasonality -----------------------------
fit1 <- ets(data,model="ANN")
summary(fit1)
#optimal alpha = 0.8392, initial level 4292.7681, AICc = 2270.5
plot(fit1)

fit1$components
fit1$states #level estimation
fit1$fitted #forecast estimation, forecast value = last level value
forecast(fit1)#forecase more than 1 step will be the same
plot(forecast(fit1))


#ETS 2: Additive Error, Has Trend (No Damped), No Seasonality ----------------
fit2 <- ets(data,model="AAN")
summary(fit2)
# AICc = 2277.5, even worst if I included trend


#ETS 3: Additive Error, No Trend, Additive Seasonality 
fit3 <- ets(data,"ANA" )
summary(fit3)
# AICc = 2145.791, becomes better when include seasonality
#plot
plot(data, lwd = 2, main = "Actual observations and the fitted values of ETS model 1")
legend("topright", c("Actual observations", "Fitted values"), lty=1, col = c(1,4),cex = 0.7)
lines(fit3$fitted, col = "blue")


#ETS 4: Multiplicative Error, No Trend, Multiplicative Seasonality ------------
fit4 <- ets(data,"MNM")
summary(fit4)
# AICc = 2137.351, becomes even better with multiplicative error & seasonality


#ETS 5: Multiplicative Error, No Trend, Additive Seasonality ------------------
fit5 <- ets(data,"MNA")
summary(fit5)
#AICc = 2133.873, best
#plot
plot(data, lwd = 2, main = "Actual observations and the fitted values of ETS model 2")
legend("topright", c("Actual observations", "Fitted values"), lty=1, col = c(1,4),cex = 0.7)
lines(fit5$fitted, col = "blue")


#ETS 6: Multiplicative Error, Has Trend, Additive Seasonality -----------------
fit6 <- ets(data,"MAA")
summary(fit6)
#AICc = 2138.675
fit7 <- ets(data,"MAA", damped = TRUE)
summary(fit7)
#AICc = 2138.675
#plot
plot(data, lwd = 2, main = "Actual observations and the fitted values of ETS model 3 & 4")
legend("topright", c("Actual observations", "ETS(M,A,A)","ETS(M,Ad,A)"), lty=c(1,1,2), 
       col = c("black","blue","orange"),cex = 0.7)
lines(fit6$fitted, col = "blue",lwd = 2)
lines(fit7$fitted, col = "orange",lwd = 2,lty=2)


#Plot residuals---------------------------------------------------------------
cbind('Residuals' = residuals(fit5),
      'Forecast errors' = residuals(fit5,type='response')) %>%
    autoplot(facet=TRUE) + xlab("Year") + ylab("")

checkresiduals(fit5)

#Plot all manual forecast-----------------------------------------------------
plot(data,xlim=c(1981, 1992+3/4), ylim=c(1500,8000))
lines(dataout, lty=2, lwd=2)
lines(forecast(fit1)$mean, col="red")
lines(forecast(fit2)$mean, col="blue")
lines(forecast(fit3)$mean, col="orange")
lines(forecast(fit4)$mean, col="green")
lines(forecast(fit5)$mean, col="purple")
legend("topleft", c("Historic data", "Future data","ETS(ANN)","ETS(AAN)","ETS(ANA)","ETS(MNM)","ETS(MNA)"),
       col = c("black","black","red", "blue","orange","green","purple"),
       lty=c(1,2,1,1,1,1,1), lwd=c(1,2,1,1,1,1,1), cex=0.6)

#forecast---------------------------------------------------------------------
plot(data,xlim=c(1980, 1992+3/4), ylim=c(1500,8000))
plot(forecast:::forecast(fit5, level = c(80,90,95,99), h=18))