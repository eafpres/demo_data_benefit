#
# demo benefit of more data
#
# clear the environment
#
  rm(list=ls())
# 
# generate some noisy sales data
#
  set.seed(2018)
  days <- seq(1:90)
  sales <- 9 - 
    (2 * sin(2 * 3.14159 * (days / 3.5)) + 2) - 
    (2 * sin(2 * 3.14159 * (days / 21)) + 2)
  noise <- -1 * runif(90, -2, 3)
  act_sales <- sales + noise
  for (i in 1:length(act_sales)) {
#    
# drop some data to simulate random days with no sales
#    
    if (runif(1, 0, 1) > 0.9) {
      act_sales[i] <- 0
    }
#
# drop Saturdays and Sundays
#
    if (((i %% 6) == 0) | ((i %% 7) == 0)) {
      act_sales[i] <- 0
    }
  }
#
# visualize all data
#
  plot(act_sales,
       xlim = c(1, length(days)),
       ylim = c(0, 20),
       ylab = "Actual sales",
       xlab = "days",
       main = "Raw data",
       cex.main = 0.75
       axes = FALSE)
  axis(1, at = seq(1, length(days), 7))
  axis(2)
  lines(act_sales, col = "red")
#
# look at only 1 week
#
  plot((act_sales)[1:7], 
       ylim = c(0, 20),
       ylab = "Actual sales",
       xlab = "days",
       main = "Raw data",
       cex.main = 0.75,
       axes = FALSE)
  axis(1)
  axis(2)
  lines((act_sales)[1:7], 
        col = "red")
#
# build some polynomial time data to use to fit
#
  poly_days <- 
    as.data.frame(matrix(nrow = length(days), ncol = 5))
  for (i in 1:3) {
    poly_days[, i] <- days^i
  }
#
# fit simpele model to 1 week of data
#
# let's use polynomial up to cubic
#
  sales_mod_1 <- lm(act_sales[1:7] ~ 
                      poly_days[1:7, 1] +
                      poly_days[1:7, 2] +
                      poly_days[1:7, 3])
#
# predict 3 weeks using this model (blows up outside original data)
#
  plot(act_sales[1:35],
       ylim = c(0, 20),
       ylab = "Actual/predicted sales",
       xlab = "days",
       main = paste0("Raw data + models (using 7 days data)\n",
                     "Blue = poly^3, Red = ARIMA(3,0,3)"),
       cex.main = 0.75,
       axes = FALSE)
  axis(1, at = seq(1, 35, 7))
  axis(2)
  pred_sales_1 <- sales_mod_1$coefficients[1] +
                  sales_mod_1$coefficients[2] * poly_days[1] +
                  sales_mod_1$coefficients[3] * poly_days[2] +
                  sales_mod_1$coefficients[4] * poly_days[3]
  lines(x = days[1:21], pred_sales_1[1:21, 1], col = "blue")
#
# try ARIMA model
#
  pred_sales_333 <- arima(act_sales[1:7], order = c(3, 0, 3))
#
# predict 3 weeks ahead using this model (better)
#
  lines(act_sales[1:7], col = "red")
  lines(x = days[8:28],
        y = predict(pred_sales_333, n.ahead = 21)$pred,
        col = "red")
#
# try ARIMA model on 3 weeks of data
#
  pred_sales_8102 <- arima(act_sales[1:21], order = c(8, 1, 0))
#
# predict 3 weeks using this model
#
  plot(act_sales[14:42],
       ylim = c(0, 20),
       ylab = "Actual/predicted sales",
       xlab = "days",
       main = paste0("Raw data + models\n",
                     "(using 21 days data)\n",
                     "Blue = last 7 days data, Red = ARIMA(8, 1, 0)"),
       cex.main = 0.75,
       axes = FALSE)
  axis(1, at = seq(1, 29), labels = days[14:42])
  axis(2)
  lines(act_sales[14:21], col = "blue")
  lines(x = seq(8, 28),
        y = predict(pred_sales_8102, n.ahead = 21)$pred,
        col = "red")
#
# smooth data over n days
#
  pass <- 0
  for (smooth_window in c(3, 15)) {
    pass <- pass + 1
    smoothed_sales <- numeric(length = length(days))
    trim <- as.integer(smooth_window / 2)
    smoothed_sales[1:trim] <- 0
    smoothed_sales_3[(length(days) - trim):length(days)] <- 0
    for (i in (trim + 1):(length(days) - trim)) {
      smoothed_sales[i] <- mean(act_sales[(i - trim):(i + trim)])
    }
    if (pass == 1) {
      plot(smoothed_sales,
           ylim = c(0, 20),
           ylab = "Smoothed actual sales",
           xlab = "days",
           main = paste0("Smoothed raw data\n",
                         "black = 3 days, red = 15 days\n",
                         "shorter period = (90/12) days\n",
                         "longer period = (90/4 days"),
           cex.main = 0.75,
           axes = FALSE)
      axis(1, at = seq(1, length(days), 7))
      axis(2)
      lines(smoothed_sales, col = pass, lty = pass, lwd = 2)
    } else {
      lines(smoothed_sales, col = pass, lty = pass, lwd = 2)
    }
  }
#
# recognize periodic behavior, add to model
#
  poly_days[, 2] <- sin(2 * 3.14159 * (days / (length(days) / 4)))
  poly_days[, 3] <- cos(2 * 3.14159 * (days / (length(days) / 4)))
  poly_days[, 4] <- sin(2 * 3.14159 * (days / (length(days) / 12)))
  poly_days[, 5] <- cos(2 * 3.14159 * (days / (length(days) / 12)))
  sales_mod_4 <- lm(act_sales[1:21] ~ 
                      poly_days[1:21, 1] +
                      poly_days[1:21, 2] +
                      poly_days[1:21, 3] +
                      poly_days[1:21, 4] +
                      poly_days[1:21, 5])
  pred_sales_4 <- sales_mod_4$coefficients[1] +
    sales_mod_4$coefficients[2] * poly_days[2] +
    sales_mod_4$coefficients[3] * poly_days[3] +
    sales_mod_4$coefficients[2] * poly_days[4] +
    sales_mod_4$coefficients[3] * poly_days[5]
#
# predict 3 weeks using this model
#
  plot(act_sales[14:42],
       ylim = c(0, 20),
       ylab = "Actual/predicted sales",
       xlab = "days",
       main = paste0("Raw data + model (cosines)\n",
                     "(using 21 days data)\n",
                     "Blue = last 7 days data, Red = cosines"),
       cex.main = 0.75,
       axes = FALSE)
  axis(1, at = seq(1, 29), labels = days[14:42])
  axis(2)
  lines(act_sales[14:21], col = "blue")
  lines(x = seq(8, 28),
        y = pred_sales_4[22:42, 1],
        col = "red")
#