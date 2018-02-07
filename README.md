demo_data_benefit

In this simple project we set out to show how collecting time series data over longer times allows discoery of more features and producing better models.

We begin by generating some noisy time series data that has some underlying periodic behavior.  We proceed to generate some polynomial time features as predictors, then attempt to predict forward using only 7 days of data in the model, and using up to cubic time.  The results are poor as would be expected.

Next we compare that result to using an ARIMA model, and the results are better but it is evident that the model is not getting all the behaior of the data into the predictions.  This motivates "collecting" more data--i.e. we now use 21 days of data and create another ARIMA model with somewhat better results.  Rather then trying to optimize the ARIMA model, we then move to smoothing.

Data are smoothed over two time periods to show that periodic behavior can be illuminated with simple moving average smoothing.  From this rudimentary analysis, we find there is a short term cycle that has about 12 cycles over the 90 days of data, or 7.5 days period, and a longer-term cycle having 4 cycles over the 90 days, or 22.5 days period.  Note that the actual underlying periods are 3.5 days and 21 days.

We then construct two cosine series using a sine and cosine function of the appropriate frequencies for each period.  Using a sine and cosine of the same frequency allows a linear mode to fit the phase and amplitude by adjusting the coefficients on each series.  This avoids having to find a way to discover the exact phases.

Finally we build a new linear model using simple time and the cosine series, and show that it captures more of the interesting behavior in the data.

This toy example illustrates some of the approaches than can be used to build models of complex time series behaior using linear models.
