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
