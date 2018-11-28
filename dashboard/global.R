lp <- "/zeolite/rpauloo/R/x86_64-pc-linux-gnu-library/3.4"

library(shiny,       lib.loc = lp)
library(DBI,         lib.loc = lp)
library(dplyr,       lib.loc = lp)
library(shinythemes, lib.loc = lp)
library(shinyBS,     lib.loc = lp)
library(leaflet,     lib.loc = lp)
library(tidyr,       lib.loc = lp)
library(withr,       lib.loc = lp)
library(ggplot2,     lib.loc = lp)
library(plotly,      lib.loc = lp)
library(lubridate,   lib.loc = lp)
library(readr,       lib.loc = lp)
library(stringr,     lib.loc = lp)
library(anytime,     lib.loc = lp)
library(RMySQL,      lib.loc = lp)
library(tibbletime,  lib.loc = lp)

# disable sanitize_errors
options(shiny.sanitize.errors = FALSE)

# read password for SQL database with groundwater level
pw <- read_rds("/srv/shiny-server/gw_obs/data/pw.rds")

# connect to UC Davis MySQL db
cdb <- dbConnect(MySQL(),
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
# load("data/well_dat_daily.RData")
load("/srv/shiny-server/gw_obs/data/well_dat_daily.RData")
well_dat_daily$Date <- round_date(well_dat_daily$Date, "day")

# bring in clean test data for now - need to experiment with .RData in SQL
present <- dbReadTable(cdb, "present")
present$dt <- lubridate::ymd_hms(present$dt)

# convert dates and levels to correct class
well_dat_daily <- gather(present, ls_id, level, -dt) %>% 
  mutate(level = as.numeric(level)) %>% 
  filter(!is.na(dt)) %>% 
  spread(ls_id, level) %>% 
  as_tbl_time(index = dt) %>% 
  collapse_by("daily") %>% 
  group_by(dt) %>%
  summarise_all(mean, na.rm = TRUE) %>% 
  mutate(dt = round_date(.$dt, "day")) %>% 
  rename(Date = dt) %>% 
  left_join(well_dat_daily, by = "Date") 


##############################################################################

# caption below hydrograph on first tab
caption <- 'These monitoring wells reflect the water table elevation in the South American River subbasin, and may not be accurate. For more information on research by UC Water, please visit'

# disconnect from cloud database
dbDisconnect(cdb)


