library(shiny)
library(shinythemes)
library(shinyBS)
library(leaflet)
library(quantmod)
library(tidyverse)
library(anytime)
library(plotly)

# well location is built into the code, meaning every time a well is added, the code will need to be updated.
cs_coords <- data.frame(lat = c(38.31263, 38.30505, 38.30488, 38.29666, 38.30271, 38.2967, 38.29174, 38.29183, 38.30517, 38.30965, 38.30967, 38.2967, 38.30101), 
                        lng = c(-121.379, -121.381, -121.369, -121.374, -121.379, -121.379, -121.382, -121.391, -121.391, -121.376, -121.384, -121.382, -121.384), 
                        Location = c("MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13")
                        )

# battery life will come in as a df from MySQL
battery_df = data.frame(Location = c("MW2", "MW9", "MW11", "MW20", "OnetoAg", "MW19", "MW23", "MW22", "MW7", "MW5", "MW3", "MW17", "MW13"), 
                        battery = 88:100)
# add battery info to well_cords
left_join(cs_coords, battery_df, by = "Location") -> cs_coords


# add custom labels. http://rpubs.com/bhaskarvk/electoral-Map-2016.
cs_coords$hover_text <- mapply(
  function(well_id, lat, lng, bat) {
    htmltools::HTML(
      sprintf(
        "<span style='font-size:16px;font-weight:bold'>%s</span>
        <div style='width:95%%'>
        <span style='font-size:12px'>Latitude: %s</span><br/>
        <span style='font-size:12px'>Longitude: %s</span><br/>
        <span style='font-size:12px'>Battery: %s%%</span><br/>
        
        
        </div>
        </div>",
        well_id,
        lat,
        lng,
        bat
      )
    )
  },
  cs_coords$Location,
  cs_coords$lat,
  cs_coords$lng,
  cs_coords$battery, SIMPLIFY = F) 
  


##############################################################################

# bring in clean test data for now - need to experiment with .RData in SQL
#load("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/dashboard/well_dat_daily.RData")
load("well_dat_daily.RData")
well_dat_daily <- well_dat_daily %>% as.data.frame()

##############################################################################

  
# original code
#lapply(list.files(pattern="^cc4lite_launch_.*.\\.RData$"), load, envir=.GlobalEnv)
caption <- 'These monitoring wells reflect the water table elevation in the South American River subbasin. For more information on research by UC Water, please visit'

