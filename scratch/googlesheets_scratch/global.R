library(shiny)
#library(googlesheets)
library(DT)
library(tidyverse)
#library(tibbletime)
library(stringr)
#library(cowplot)
#library(data.table)
library(googlesheets)
library(leaflet)
library(RSQLite)
library(DBI)

cs_key <- extract_key_from_url("https://docs.google.com/spreadsheets/d/1PGvaPn4wqXb02bnujJ31edoleVYJFnpL4OsP_tcXSeU/edit#gid=0")
# 
cs_ss <- gs_key(cs_key)
# 
cs_hydro <- gs_read(cs_ss, ws = "hydrographs")
cs_coords <- gs_read(cs_ss, ws = "coords")

# gather the data so it's easy to plot
cs_hydro_long <- gather(cs_hydro, well, head, -time)

# read in data from github
#df <- fread('https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/cosumnes_gw_observatory/AllData.csv')

#as_data_frame(df) -> df

#df$Date <- as.POSIXct(strptime(df$Date, "%m/%d/%Y %H:%M:%S"))

#cs_hydro_long <- gather(df, well, head, -Date)


# try sqlite
# connect to SQLite database that Solinist regularly updates
# db = dbConnect(SQLite(), dbname = "C:/Users/ayoder/Documents/LevelSender/db/levelsender.sqlite")
# 
# # There's a lot of information that we don't need. Let's select what we do need.
# df <- dbReadTable(db, "ReceivedEmail") %>% 
#   select(ReceivedDate, Subject, Body)