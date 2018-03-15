library(quantmod)
library(highcharter)

# example from highcharts website
usdjpy <- getSymbols("USD/JPY", src = "oanda", auto.assign = FALSE)
eurkpw <- getSymbols("EUR/KPW", src = "oanda", auto.assign = FALSE)

hc <- highchart(type = "stock") %>% 
  hc_title(text = "Charting some Symbols") %>% 
  hc_subtitle(text = "Data extracted using quantmod package") %>% 
  hc_add_series(usdjpy, id = "usdjpy") %>% 
  hc_add_series(eurkpw, id = "eurkpw")

hc

# can a POSIXct object be converted into xts for highcharts?
dts <- data.frame(day = c("20081101", "20081101", "20081101", "20081101", "20081101", "20081102",
                          "20081102", "20081102", "20081102", "20081103"), 
                  time = c("01:20:00", "06:00:00", "12:20:00", "17:30:00", "21:45:00", "01:15:00", "06:30:00", "12:50:00", "20:00:00", "01:05:00"), 
                  value = c("5","5", "6", "6", "5", "5", "6", "7", "5", "5"))

dts1 <- paste(dts$day, dts$time)
dts2 <- as.POSIXct(dts1, format = "%Y%m%d %H:%M:%S")


# create POSIXct
temp <- data.frame(time = dts2, val = c(1,2))
# convert to xts
temp_xts <- xts(temp[,-1], order.by=temp[,1]) 

# chart it. It works! Worthwhile checking if I can write xts objects to MySQL and avoid these conversions in the app
highchart(type = "stock") %>% 
  hc_title(text = "Charting some Water Data") %>% 
  hc_subtitle(text = "By the seat of my pants") %>% 
  hc_add_series(temp_xts, id = "well_1") #%>% 
  #hc_add_series()


#########################
#HIGHCHARTS
#########################

# add in well_dat from MySQL -- table of all well data
well_dat <- read.csv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/cosumnes_gw_observatory/AllData.csv")

# make the column names compatible with location data, just for testing
colnames(well_dat) <- c("Date", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")

# # convert to POSIXct then xts
well_dat$Date <- as.POSIXct(well_dat$Date, format = "%m/%d/%Y %H:%M:%S")
# compare to anytime
mbm <- microbenchmark(
  base = as.POSIXct(well_dat$Date, format = "%m/%d/%Y %H:%M:%S"),
  anytime = anytime(well_dat$Date),
  times = 5
)
autoplot(mbm) # much faster in base

#gather(well_dat_xts, well, level, -Date) -> well_dat_long

well_dat_1 <- xts(well_dat[,2], order.by=well_dat[,1])
well_dat_2 <- xts(well_dat[,3], order.by=well_dat[,1])
well_dat_3 <- xts(well_dat[,4], order.by=well_dat[,1])
well_dat_4 <- xts(well_dat[,5], order.by=well_dat[,1])
well_dat_5 <- xts(well_dat[,6], order.by=well_dat[,1])
well_dat_6 <- xts(well_dat[,7], order.by=well_dat[,1])
well_dat_7 <- xts(well_dat[,8], order.by=well_dat[,1])
well_dat_8 <- xts(well_dat[,9], order.by=well_dat[,1])
well_dat_9 <- xts(well_dat[,10], order.by=well_dat[,1])
well_dat_10 <- xts(well_dat[,11], order.by=well_dat[,1])
well_dat_11 <- xts(well_dat[,12], order.by=well_dat[,1])
well_dat_12 <- xts(well_dat[,13], order.by=well_dat[,1])
well_dat_13 <- xts(well_dat[,14], order.by=well_dat[,1])

# trim for load testing
wells = 15
samples_per_day = 1
days = 365 * 3
t = wells * samples_per_day * days 
n_rows <- 150000 + t

well_dat_1_t <- well_dat_1[150000:n_rows,]
well_dat_2_t <- well_dat_2[150000:n_rows,]
well_dat_3_t <- well_dat_3[150000:n_rows,]
well_dat_4_t <- well_dat_4[150000:n_rows,]
well_dat_5_t <- well_dat_5[150000:n_rows,]
well_dat_6_t <- well_dat_6[150000:n_rows,]
well_dat_7_t <- well_dat_7[150000:n_rows,]
well_dat_8_t <- well_dat_8[150000:n_rows,]
well_dat_9_t <- well_dat_9[150000:n_rows,]
well_dat_10_t <- well_dat_10[150000:n_rows,]
well_dat_11_t <- well_dat_11[150000:n_rows,]
well_dat_12_t <- well_dat_12[150000:n_rows,]
well_dat_13_t <- well_dat_13[150000:n_rows,]

# plug into highcharts. Then connect this to leaflet.
highchart(type = "stock") %>% 
  hc_title(text = "Charting some Water Data") %>% 
  hc_subtitle(text = "By the seat of my pants") %>% 
  hc_add_series(well_dat_1_t, id = "well_1") %>% 
  hc_add_series(well_dat_2_t, id = "well_2") %>% 
  hc_add_series(well_dat_3_t, id = "well_3") %>% 
  hc_add_series(well_dat_4_t, id = "well_4") %>% 
  hc_add_series(well_dat_5_t, id = "well_5") %>% 
  hc_add_series(well_dat_6_t, id = "well_6") %>% 
  hc_add_series(well_dat_7_t, id = "well_7") %>% 
  hc_add_series(well_dat_8_t, id = "well_8") %>% 
  hc_add_series(well_dat_9_t, id = "well_9") %>% 
  hc_add_series(well_dat_10_t, id = "well_10") %>% 
  hc_add_series(well_dat_11_t, id = "well_11") %>% 
  hc_add_series(well_dat_12_t, id = "well_12") %>% 
  hc_add_series(well_dat_13_t, id = "well_13") 


####################################################
# plotly solution
####################################################

# bring in test data
#well_dat <- read.csv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/cosumnes_gw_observatory/AllData.csv")


# make the column names compatible with location data, just for testing
colnames(well_dat) <- c("Date", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")

# # convert to POSIXct 
well_dat$Date <- as.POSIXct(well_dat$Date, format = "%m/%d/%Y %H:%M:%S") # faster than anytime

# save and load for faster testing
#save(well_dat, file = "well_dat.RData")
load("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/dashboard/well_dat.RData")

# test plotly for speed -- much faster than highcharts
library(plotly)
wells = 15
samples_per_day = 1
days = 365 * 2
t = wells * samples_per_day * days 
n_rows <- 150000 + t
well_dat_short <- well_dat[150000:n_rows,]

# save
save(well_dat_short, file="well_dat_short.RData")

# gather data and get geom_smooth line from it
well_dat_short %>% 
  gather(wells, level, -Date) %>% 
  qplot(Date, level, data = .) + stat_smooth() -> p

# get geom_smooth coords 
ggplot_build(p)$data[[2]] %>% select(x,y,ymin,ymax) -> smooth

#smooth$x <- as.Date(as.POSIXct(smooth$x, origin="1970-01-01")) 
library(anytime)
smooth$x <- anytime(smooth$x)

# plot 
plot_ly(well_dat_short, x = ~Date) %>%
  add_lines(y = ~MW2, name = "MW2", color= I("gray50")) %>%
  add_lines(y = ~MW9, name = "MW9", color= I("gray50")) %>%
  add_lines(y = ~MW11, name = "MW11", color= I("gray50")) %>%
  add_lines(y = ~MW20, name = "MW20", color= I("gray50")) %>%
  add_lines(y = ~OnetoAg, name = "OnetoAg", color= I("gray50")) %>%
  add_lines(y = ~MW19, name = "MM19", color= I("gray50")) %>%
  add_lines(y = ~MW23, name = "MW23", color= I("gray50")) %>%
  add_lines(y = ~MW22, name = "MW22", color= I("gray50")) %>%
  add_lines(y = ~MW7, name = "MW7", color= I("gray50")) %>%
  add_lines(y = ~MW5, name = "MW5", color= I("gray50")) %>%
  add_lines(y = ~MW3, name = "MW3", color= I("gray50")) %>%
  add_lines(y = ~MW17, name = "MW17", color= I("gray50")) %>%
  add_lines(y = ~MW13, name = "MW13", color= I("gray50")) %>%
  add_ribbons(data = smooth, x=~x, ymin=~ymin, ymax=~ymax, color = I("gray80"), name = "Confidence Interval") %>% 
  add_lines(data = smooth, x=~x, y=~y, color = I("red"), name = "AVERAGE") %>% 
  layout(
    showlegend = FALSE,
    title = "Monitoring Well Network",
    xaxis = list(
      rangeselector = list(
        buttons = list(
          list(
            count = 3,
            label = "3 mo",
            step = "month",
            stepmode = "backward"),
          list(
            count = 6,
            label = "6 mo",
            step = "month",
            stepmode = "backward"),
          list(
            count = 1,
            label = "1 yr",
            step = "year",
            stepmode = "backward"),
          list(
            count = 1,
            label = "YTD",
            step = "year",
            stepmode = "todate"),
          list(step = "all"))),
      
      rangeslider = list(type = "date")),
    
    yaxis = list(title = "Price"))


# anytime is faster than base for this simple conversion
library(microbenchmark)
mbm <- microbenchmark(
  base = as.Date(as.POSIXct(smooth$x, origin="1970-01-01")) ,
  anytime = anytime(smooth$x),
  times = 100
)
autoplot(mbm)







###################################################
# make a calendar heatmap of water level
###################################################


# http://margintale.blogspot.in/2012/04/ggplot2-time-series-heatmaps.html
library(ggplot2)
library(plyr)
library(scales)
library(zoo)

df <- read.csv("https://raw.githubusercontent.com/selva86/datasets/master/yahoo.csv")
df$date <- as.Date(df$date)  # format date
df <- df[df$year >= 2012, ]  # filter reqd years

# Create Month Week
df$yearmonth <- as.yearmon(df$date)
df$yearmonthf <- factor(df$yearmonth)
df <- ddply(df,.(yearmonthf), transform, monthweek=1+week-min(week))  # compute week number of month
df <- df[, c("year", "yearmonthf", "monthf", "week", "monthweek", "weekdayf", "VIX.Close")]
head(df)
#>   year yearmonthf monthf week monthweek weekdayf VIX.Close
#> 1 2012   Jan 2012    Jan    1         1      Tue     22.97
#> 2 2012   Jan 2012    Jan    1         1      Wed     22.22
#> 3 2012   Jan 2012    Jan    1         1      Thu     21.48
#> 4 2012   Jan 2012    Jan    1         1      Fri     20.63
#> 5 2012   Jan 2012    Jan    2         2      Mon     21.07
#> 6 2012   Jan 2012    Jan    2         2      Tue     20.69


# Plot
ggplot(df, aes(monthweek, weekdayf, fill = VIX.Close)) + 
  geom_tile(colour = "white") + 
  facet_grid(year~monthf) + 
  scale_fill_gradient(low="red", high="green") +
  labs(x="Week of Month",
       y="",
       title = "Time-Series Calendar Heatmap", 
       subtitle="Yahoo Closing Price", 
       fill="Close")





###############################################################
library(dygraphs)

dygraph(well_dat_short)

class(well_dat_short)
mdeaths %>% class()
as.ts(well_dat_short) %>% dygraph()

ts(well_dat_short[,-1], start= min(well_dat_short$Date), end = max(well_dat_short$Date), frequency = 1) %>% 
  dygraph()



