library(shiny)
library(DBI)
library(pool)
library(DT)
library(tidyverse)
#library(tibbletime)
#library(RMySQL)
library(stringr)
library(cowplot)
library(data.table)
library(leaflet)


cs_coords <- data_frame(lat = c(38.30139, 38.31263, 38.30505, 38.30488, 38.29666, 38.30271, 38.2967, 38.29174, 38.29183, 38.30517, 38.30965, 38.30967, 38.2967, 38.30101), 
                        long = c(-121.378, -121.379, -121.381, -121.369, -121.374, -121.379, -121.379, -121.382, -121.391, -121.391, -121.376, -121.384, -121.382, -121.384), 
                        well = c("MW14", "MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13"))

# connect to mySQL db
con <- dbConnect(RMySQL::MySQL(),
                 user = "gw_observatory",
                 password = "",
                 host = "169.237.35.237",
                 dbname = "gw_observatory",
                 port = 33306)

# pool <- dbPool(
#   drv = RMySQL::MySQL(),
#   dbname = "gw_observatory",
#   host = "sage.metro.ucdavis.edu",
#   username = "gw_observatory", 
#   password = ""
# )
# onStop(function() {
#   poolClose(pool)
# })


# query mySQL db
df <- dbReadTable(con, "test")

# fix dates
dates <- as.POSIXct( strptime(df$Date, format = '%Y-%m-%d %H:%M:%S') ) # format changes between mySWL writing and reading

# reorganize 
cs_hydro_long <- gather(df, well, head, -Date)

cs_hydro_long$Date <- dates # recycling makes this work


# scratch
grouped_heads <- cs_hydro_long %>%
  group_by(Date) %>%
  summarise(mean = mean(head, na.rm = TRUE),
            min = min(head, na.rm = TRUE),
            max = max(head, na.rm = TRUE))

