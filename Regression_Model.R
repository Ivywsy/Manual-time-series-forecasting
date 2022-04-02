library(forecast)
library(Mcomp)
library(tseries)
library(ggplot2)
library(lmtest)

M3[[1911]]$description
str(M3[[1911]])

data <- M3[[1911]]$x
dataout <- M3[[1911]]$xx


# Try trend ---------------------------------------------------------------------

fit6 <- tslm(data ~ trend)
summary(fit6)
#Adjusted R-square = 15.04%, trend is significant
dwtest(fit6)
qqnorm(fit6$residuals)
qqline(fit6$residuals)


#plot the fitted model 
plot(data, lwd = 2)
lines(fit6$fitted, col = "red")


#Residual plot VS Fitted value
cbind(Fitted = fit6$fitted,Residuals=fit6$residuals) %>%
    as.data.frame() %>%
    ggplot(aes(x=Fitted, y=Residuals)) + geom_point()
               

#--------------------------------------------------------------------------------

#Try season only
fit8 <- tslm(data~season)
summary(fit8)
#Adjusted R-squared = 56.14%

#Same fit with manual input seasonal dummy variables
dummy<-read.csv("dummy.csv")
fit8 <- tslm(data~dummy[,1]+dummy[,2]+dummy[,3]+dummy[,4]+
                 dummy[,5]+dummy[,6]+dummy[,7]+dummy[,8]+
                 dummy[,9]+dummy[,10]+dummy[,11])
summary(fit8)
#Adjusted R-squared = 56.14%

#plot the fitted model 
plot(data, lwd = 2, main = "Actual observations and the fitted values of model 1")
legend("topright", c("Actual observations", "Fitted values"), lty=1, col = 1:2)
lines(fit8$fitted, col = "red")



#Drop insignificant seasons--------------------------------------------------
dummy<-read.csv("dummy.csv")
fit8 <- tslm(data~dummy[,2]+dummy[,3]+dummy[,4]+dummy[,5]+dummy[,6]+dummy[,7]+dummy[,8]+dummy[,10]+dummy[,11])
summary(fit8)
#Adjusted R-squared = 56.86 %

#plot the fitted model 
plot(data, lwd = 2, main = "Actual observations and the fitted values of model 2")
legend("topright", c("Actual observations", "Fitted values"), lty=1, col = 1:2,cex = 0.7)
lines(fit8$fitted, col = "red")


#Trend + necessary season variables----------------------------------------------
fit8 <- tslm(data~trend+dummy[,2]+dummy[,3]+dummy[,4]+dummy[,5]+dummy[,6]+dummy[,7]+dummy[,8]+dummy[,10]+dummy[,11])
summary(fit8)
#Adjusted R-squared = 72.73%

#plot the fitted model 
plot(data, lwd = 2, main = "Actual observations and the fitted values of model 3")
legend("topright", c("Actual observations", "Fitted values"), lty=1, col = 1:2,cex = 0.7)
lines(fit8$fitted, col = "red")


#Forecast-------------------------------------------------------------------
futuredummy<-read.csv("futuredummy.csv")
dummy<-futuredummy

#Forecast the future 18 months with the fitted model
plot(forecast:::forecast(fit8, h=18,level = c(80, 90,95,99)))
lines(dataout, lty=2, lwd=2)

#Manual plot with different color shading
fcs <- forecast:::forecast(fit8, h=18,level = c(80, 90,95,99))

plot(data, xlim=c(1981,1993),ylim = c(1000,7000), main = "Focecasts from linear regression model 3")
lines(fcs$mean, col = "blue",lwd = 2, lty = 2) #mean
lines(fcs$lower[,1], col = "green") #80%
lines(fcs$upper[,1], col = "green") #80%
lines(fcs$lower[,2], col = "red") #90%
lines(fcs$upper[,2], col = "red") #90%
lines(fcs$lower[,3], col = "purple") #95%
lines(fcs$upper[,3], col = "purple") #95%
lines(fcs$upper[,4], col = "grey") #99%
lines(fcs$upper[,4], col = "grey") #99%


#-----------------------------------------------------------------------------
#Residual Analysis for Linearity
cbind(Fitted = fit8$fitted,Residuals=fit8$residuals) %>%
    as.data.frame() %>%
    ggplot(aes(x=Fitted, y=Residuals)) + geom_point()+
    labs(title="Plot of fitted values VS residuals")+
    theme(plot.title = element_text(hjust = 0.5))

#Residual Analysis for Normality 
qqnorm(fit8$residuals)
qqline(fit8$residuals)
shapiro.test(fit8$residuals) #p-value = 0.4868 > 0.05, follows normality

#Residual Analysis for Equal Variance 
bptest(fit8) #p-value = 0.4407 > 0.05, has constant variance


#Residual Analysis for Independence
dwtest(fit8)
#DW = 1.186, p-value = 5.519e-06 

