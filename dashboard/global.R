library(shiny)
library(shinythemes)
library(shinyBS)
library(leaflet)
library(quantmod)
library(tidyverse)
library(anytime)
library(plotly)
library(DBI)
library(dplyr)
library(lubridate)
library(glue)

# well location is built into the code, meaning every time a well is added, the code will need to be updated.
# cs_coords2 <- data.frame(lat = c(38.31263, 38.30505, 38.30488, 38.29666, 38.30271, 38.2967, 38.29174, 38.29183, 38.30517, 38.30965, 38.30967, 38.2967, 38.30101),
#                         lng = c(-121.379, -121.381, -121.369, -121.374, -121.379, -121.379, -121.382, -121.391, -121.391, -121.376, -121.384, -121.382, -121.384),
#                         Location = c("MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")
#                         )
# 
# read password for SQL database with groundwater level
pw <- read_rds("data/pw.rds")
# pw <- read_rds("data/pw.rds")

# connect to UC Davis MySQL db
cdb <- dbConnect(RMySQL::MySQL(),
                 user = "gw_observatory",
                 password = pw,
                 host = "169.237.35.237",
                 dbname = "gw_observatory",
                 port = 33306)


cs_coords <- read_tsv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/clean/dependencies/elev.txt")
cs_coords <- cs_coords[ , c("lat", "lng", "mw_name","ls_id")] %>%
  mutate(ls_id = ifelse(is.na(ls_id), mw_name, paste0("X", ls_id))) %>% # rename ls_id, for archived loggers, assign old MW name
  rename(Location = ls_id) %>% 
  mutate(Location = str_replace_all(pull(., Location), "_", ""),
         Location = as.factor(Location)) %>% 
  filter(Location != "X284222") # remove bothersome well until it's updated


# wells
w <- levels(cs_coords$Location)[which(levels(cs_coords$Location) != "X284222")] # remove bothersome well

# battery life will come in as a df from MySQL
# battery_df = data.frame(Location = c("MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13"), 
#                         battery = 88:100)
# add battery info to well_cords
# left_join(cs_coords, battery_df, by = "Location") -> cs_coords


# add custom labels. http://rpubs.com/bhaskarvk/electoral-Map-2016.
cs_coords$hover_text <- mapply(
  function(well_id, lat, lng) {
    htmltools::HTML(
      sprintf(
        "<span style='font-size:16px;font-weight:bold'>%s</span>
        <div style='width:95%%'>
        <span style='font-size:12px'>Latitude: %s</span><br/>
        <span style='font-size:12px'>Longitude: %s</span><br/>
        
        
        </div>
        </div>",
        well_id,
        lat,
        lng

      )
    )
  },
  cs_coords$Location,
  cs_coords$lat,
  cs_coords$lng, SIMPLIFY = F) 
  


##############################################################################

# # bring in clean test data for now - need to experiment with .RData in SQL
load("data/well_dat_daily.RData")
# # load("data/well_dat_daily.RData")
# well_dat_daily <- well_dat_daily %>% as.data.frame()
well_dat_daily$Date <- round_date(well_dat_daily$Date, "day")

# bring in clean test data for now - need to experiment with .RData in SQL
present <- dbReadTable(cdb, "present")
present$dt <- lubridate::ymd_hms(present$dt)

# convert dates and levels to correct class
library(tibbletime)
well_dat_daily <- gather(present, ls_id, level, -dt) %>% 
  mutate(level = as.numeric(level)) %>% 
  filter(!is.na(dt)) %>% 
  spread(ls_id, level) %>% 
  as_tbl_time(index = dt) %>% 
  collapse_by("daily") %>% 
  group_by(dt) %>% 
  summarise_all(mean) %>% 
  mutate(dt = round_date(.$dt, "day")) %>% 
  rename(Date = dt) %>% 
  left_join(well_dat_daily, by = "Date") 

##############################################################################

# caption below hydrograph on first tab
caption <- 'These monitoring wells reflect the water table elevation in the South American River subbasin, and may not be accurate. For more information on research by UC Water, please visit'



