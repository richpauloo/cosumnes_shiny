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
well_dat <- read_csv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/cosumnes_gw_observatory/AllData.csv")

# make the column names compatible with location data, just for testing
colnames(well_dat) <- c("Date", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")

# gather data
gather(well_dat, well, level, -Date) -> well_dat_long

# convert to POSIXct then xts
as.POSIXct(well_dat$Date, format = "%m/%d/%Y %H:%M:%S")

# left off here. convert to xts, and plug into highcharts. Then connect this to leaflet.

  
# original code
lapply(list.files(pattern="^cc4lite_launch_.*.\\.RData$"), load, envir=.GlobalEnv)
caption <- 'Due to inter-annual variability and model uncertainty, these graphs are useful for examining a range of projected trends, but not for precise prediction. For more information regarding climate projections, please visit'
dec.lab <- paste0(seq(2010, 2090, by=10), "s")

brks <- c(0, 1e4, 5e4, 1e5, 2.5e5, 5e5, 1e6)
nb <- length(brks)
cities.meta$PopClass <- cut(cities.meta$Population, breaks=brks, include.lowest=TRUE, labels=FALSE)
cities.meta$PopClass[is.na(cities.meta$PopClass)] <- 1
palfun <- colorFactor(palette=c("navy", "navy", "magenta4", "magenta4", "red", "red"), domain=1:(nb-1))
