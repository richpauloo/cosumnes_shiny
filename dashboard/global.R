library(shiny)
library(shinythemes)
library(shinyBS)
library(leaflet)
library(quantmod)
library(tidyverse)
library(anytime)
library(plotly)
library(DBI)

# well location is built into the code, meaning every time a well is added, the code will need to be updated.
cs_coords <- read_tsv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/clean/dependencies/elev.txt")
cs_coords <- cs_coords[ , c("mw_name","ls_id", "lat", "lng")] 

# battery life will come in as a df from MySQL
battery_df = data.frame(mw_name = c("MW_2", "MW_9", "MW_11", "MW_20", "OnetoAg", "MW_19", "MW_23", "MW_22", "MW_7", "MW_5", "MW_3", "MW_17", "MW_13"), 
                        battery = 88:100)
# add battery info to well_cords
left_join(cs_coords, battery_df, by = "mw_name") -> cs_coords


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
  cs_coords$mw_name,
  cs_coords$lat,
  cs_coords$lng,
  cs_coords$battery, SIMPLIFY = F) 
  


##############################################################################

#bring in clean test data for now - need to experiment with .RData in SQL
load("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/dashboard/data/well_dat_daily.RData")
# load("data/well_dat_daily.RData")
well_dat_daily <- well_dat_daily %>% as.data.frame()

##############################################################################

# caption below hydrograph on first tab
caption <- 'These monitoring wells reflect the unconfined groundwater level in the South American River subbasin, and may not be exact. For more information on research by UC Water, please visit'


# read password for SQL database with groundwater level
pw <- read_rds("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/dashboard/data/pw.rds")
# pw <- read_rds("data/pw.rds")

# connect to UC Davis MySQL db
con <- dbConnect(RMySQL::MySQL(),
                 user = "gw_observatory",
                 password = pw,
                 host = "169.237.35.237",
                 dbname = "gw_observatory",
                 port = 33306)

# query MySQL db
df <- dbReadTable(con, "clean_historical_data_through_october")

# fix dates
dates <- as.POSIXct( strptime(df$date, format = '%Y-%m-%d %H:%M:%S') ) # format changes between mySWL writing and reading

# reorganize 
cs_hydro_long <- gather(df, well, head, -date)

cs_hydro_long$date <- dates # recycling makes this work


# scratch
grouped_heads <- cs_hydro_long %>%
  group_by(date) %>%
  summarise(mean = mean(head, na.rm = TRUE),
            min = min(head, na.rm = TRUE),
            max = max(head, na.rm = TRUE))
