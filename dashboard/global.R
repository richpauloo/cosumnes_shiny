library(plyr)
library(shiny)
library(shinythemes)
library(shinyBS)
library(rCharts)
library(leaflet)
library(quantmod)
library(tidyverse)

# well location is built into the code, meaning every time a well is added, the code will need to be updated.
cs_coords <- data.frame(lat = c(38.30139, 38.31263, 38.30505, 38.30488, 38.29666, 38.30271, 38.2967, 38.29174, 38.29183, 38.30517, 38.30965, 38.30967, 38.2967, 38.30101), 
                        long = c(-121.378, -121.379, -121.381, -121.369, -121.374, -121.379, -121.379, -121.382, -121.391, -121.391, -121.376, -121.384, -121.382, -121.384), 
                        Location = c("MW14", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")
                        )

# battery life will come in as a df from MySQL
battery_df = data.frame(Location = c("MW14", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13"), 
                        battery = seq(87,93,1))
# add battery info to well_cords
left_join(cs_coords, battery_df, by = "Location") -> cs_coords


# add in well_dat from MySQL -- table of all well data
well_dat <- read.csv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/cosumnes_gw_observatory/AllData.csv")

# make the column names compatible with location data, just for testing
colnames(well_dat) <- c("Date", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")

# # convert to POSIXct then xts
well_dat$Date <- as.POSIXct(well_dat$Date, format = "%m/%d/%Y %H:%M:%S")
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



getSymbols(Symbols = c("AAPL", "MSFT"))

ds <- data.frame(Date = index(AAPL), AAPL[,6], MSFT[,6])
ds$Date %>% class()
well_dat$Date %>% class()

# test plotly for speed -- much faster
library(plotly)
wells = 15
samples_per_day = 1
days = 365 * 5
t = wells * samples_per_day * days 
n_rows <- 150000 + t
well_dat_short <- well_dat[150000:n_rows,]

plot_ly(well_dat_short, x = ~Date) %>%
  add_lines(y = ~MW2, name = "MW2") %>%
  add_lines(y = ~MW9, name = "MW9") %>%
  add_lines(y = ~MW11, name = "MW11") %>%
  add_lines(y = ~MW20, name = "MW20") %>%
  add_lines(y = ~OnetoAg, name = "OnetoAg") %>%
  add_lines(y = ~MW19, name = "MM19") %>%
  add_lines(y = ~MW23, name = "MW23") %>%
  add_lines(y = ~MW22, name = "MW22") %>%
  add_lines(y = ~MW7, name = "MW7") %>%
  add_lines(y = ~MW5, name = "MW5") %>%
  add_lines(y = ~MW3, name = "MW3") %>%
  add_lines(y = ~MW17, name = "MW17") %>%
  add_lines(y = ~MW13, name = "MW13") %>%
  #add_lines(y = ~MSFT.Adjusted, name = "Microsoft") %>%
  layout(
    title = "Water Numbers",
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



  
# original code
lapply(list.files(pattern="^cc4lite_launch_.*.\\.RData$"), load, envir=.GlobalEnv)
caption <- 'Due to inter-annual variability and model uncertainty, these graphs are useful for examining a range of projected trends, but not for precise prediction. For more information regarding climate projections, please visit'
hc_add_series(well_dat_1_t, id = "well_1") %>% dec.lab <- paste0(seq(2010, 2090, by=10), "s")

brks <- c(0, 1e4, 5e4, 1e5, 2.5e5, 5e5, 1e6)
nb <- length(brks)
cities.meta$PopClass <- cut(cities.meta$Population, breaks=brks, include.lowest=TRUE, labels=FALSE)
cities.meta$PopClass[is.na(cities.meta$PopClass)] <- 1
palfun <- colorFactor(palette=c("navy", "navy", "magenta4", "magenta4", "red", "red"), domain=1:(nb-1))
