####################################################################################
# Load the relevant libraries
####################################################################################
library(RSQLite)
library(DBI)
library(tidyverse)
library(stringr)
library(lubridate)



####################################################################################
# Refresh emails and append to sqlite database.  
####################################################################################
# simulates clicking the "Retrieve Emails Button"
system(
  shQuote(
    "C:/Program Files (x86)/Solinst/LevelSender/LSEmailClient.exe", # file path of email client .exe
    type = "cmd" # change to "sh" for Unix/bash, and "csh" for C-shell
  )
)



####################################################################################
# Connect to .sqlite database, get the emails, and format dates.
####################################################################################
db <- dbConnect(SQLite(), dbname = "C:/Users/rpauloo/Documents/LevelSender/db/levelsender.sqlite")

# read emails, select interesting data, filter for relevant emails with data, and rename columns
d <- dbReadTable(db, "ReceivedEmail") %>% 
  select(ReceivedDate, Subject, Body) %>% 
  filter( grepl("LS Report", Subject) ) %>% 
  rename(date = ReceivedDate, subject = Subject, body = Body)

# We want to arrange these emails by the date they were received, 
# but first we need to convert the `Date` from a character vector to a `Date` object.
d$date <- as.POSIXct( strptime( d$date, "%Y-%m-%d %H:%M:%S" ) )



####################################################################################
#Filter for all emails within a 120 day window of the current date.
####################################################################################
# 31 day rolling window
current <- Sys.Date() - 90

# add another date column without times
d$date_2 <- as_date(d$date)

# filter for all emails from `current` onwards
check <- filter(d, date_2 >= current)



####################################################################################
# Identify records containing MW5 & write a function to extract all timeseries data
####################################################################################

# serial number for mw5 level sender
mw5 <- ": 283687"

# separate each email body into a vector of lines, and store each in a list element
lines <- lapply(check$body, function(x){unlist(strsplit(x, "\r\n"))} )

# function to apply
get_data <- function(v){ 
  
  # initalize baro vector
  baro <- NULL 
  
  # does mw5 appear in the email? 
  ss <- sum(str_detect(v, mw5)) 
  
  # if the well == MW 5
  if (ss == 1) {
    id <- v[str_detect(v, "Serial: ")][1]    # 1st serial is level sender id
    baro <- v[str_detect(v, "Serial: ")][3]  # 3rd serial is baro  logger id
  }
  
  # if the well != mw5
  if (ss == 0) {
    id <- v[str_detect(v, "Serial: ")][1]    # 1st serial number is level sender id
  }
  
  # subset for the level logger serial number by string position "Serial: #######"
  id <- as.numeric(substr(id, 9, nchar(id)))
  
  # if barometric pressure logger is present, get its serial
  if(!is.null(baro)){baro <- as.numeric(substr(baro, 9, nchar(baro)))}
  
  
  # if the well == MW 5
  if (ss == 1) {
    
    # starting and ending index of logger 1 (monitoring well)
    mw_0 <- str_which(v, "Logger 1 Samples") + 2
    mw_n <- str_which(v, "Logger 2 Samples") - 2
    
    # starting and ending index of logger 2 (baro logger)
    bl_0 <- str_which(v, "Logger 2 Samples") + 2
    bl_n <- str_which(v, "MESSAGES: Email report") - 2
    
    # organize into a dataframe
    v1 <- v[mw_0:mw_n]                           # monitoring well lines 
    v2 <- v[bl_0:bl_n]                           # barologger lines
    m1 <- str_split_fixed(v1, ", ", 3)           # matrix of mw strings
    m2 <- str_split_fixed(v2, ", ", 3)           # matrix of baro strings
    m1[, 2:3] <- round(as.numeric(m1[, 2:3]), 2) # round temp and level
    m2[, 2:3] <- round(as.numeric(m2[, 2:3]), 2) # round temp and level
    
    df <- rbind.data.frame(m1, m2)               # convert to df
    colnames(df) <- c("dt", "temp", "level")     # rename columns
    df$dt <- dmy_hms(df$dt)                      # format dates
    
    # add ids
    df$id <- rep(c(id, baro), times = c(length(v1), length(v2)))
    
    # finagle the object classes
    df$temp <- as.numeric(levels(df$temp)[df$temp])
    df$level <- as.numeric(levels(df$level)[df$level])
    #df$id <- factor(df$id)
    
  }
  
  # if the well != mw5
  if (ss == 0) {
    
    # starting and ending index of logger 1 (monitoring well)
    mw_0 <- str_which(v, "Logger 1 Samples") + 2
    mw_n <- str_which(v, "MESSAGES: Email report") - 2
    
    
    # organize into a dataframe
    v1 <- v[mw_0:mw_n]                           # monitoring well lines 
    m1 <- str_split_fixed(v1, ", ", 3)           # matrix of mw strings
    m1[, 2:3] <- round(as.numeric(m1[, 2:3]), 2) # round temp and level
    
    df <- as.data.frame(m1)                      # convert to df
    colnames(df) <- c("dt", "temp", "level")     # rename columns
    df$dt <- dmy_hms(df$dt)                      # format dates
    
    # add ids
    df$id <- id
    
    # finagle the object classes
    df$temp <- as.numeric(levels(df$temp)[df$temp])
    df$level <- as.numeric(levels(df$level)[df$level])
    #df$id <- factor(df$id)
  }
  
  return(df)
}



####################################################################################
# Apply function to all `lines` from `current` data.
####################################################################################

# apply function to list of current emails
dfs <- lapply(lines, get_data) # temp until non-equal issue is fixed

# bind all dfs together
all <- do.call(rbind, dfs)

# omit erronous values input when a measurement error is made
all <- filter(all, level < 1000)

# save immediately checked email for battery df later
use_for_bat <- all



####################################################################################
# Outage Hot Fixes
####################################################################################

# October 2018 MW5 OUTAGE with affected the baro and water level loggers
out_window <- read_tsv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/clean/dependencies/ls_battery_outages.txt")

# omit the data from these outage wells within the outage window 
for(i in 1:nrow(out_window)){
  all <- filter(all, !(id == out_window$ls_id[i] & 
                         dt >= out_window$out_start[i] & 
                         dt <= out_window$out_end[i]))
}

# read in recovered data and append to all
recovered_data <- read_tsv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/clean/dependencies/ls_recovered_data.txt")

# reorderfor merge
recovered_data <- rename(recovered_data, id = ls_id) %>% select(dt, temp, level, id)

# merge
all <- bind_rows(all, recovered_data)



####################################################################################
# Separate barologger and monitoring well data. 
####################################################################################

# serial number for baro logger
baro_serial <- "2038232"

# barometric timeseries
baro_data <- filter(all, id == baro_serial)  

# monitoring well timeseries
mw_data <- filter(all, id != baro_serial) 



####################################################################################
# Tranformations
####################################################################################

# Remove temperature from barometric and monitoring well data.
baro_data <- select(baro_data, -temp)
mw_data   <- select(mw_data,   -temp)


# Convert barometric data from PSI to meters.
psi_to_m <- function(psi){
  return(psi * 0.703070)    # PSI to meters conversion factor
}

# convert barometric timeseries from PSI to meters 
baro_data$level <- psi_to_m(baro_data$level)


# Adjust monitoring well levels by barometric data.

# rename columns in baro and mw data to remove ambiguity, drop id in baro data, round to nearest hour
baro_data <- rename(baro_data, level_baro = level) %>% 
  select(-id) %>% 
  mutate(dt = round_date(dt, unit = "hour"))             # round to nearest hour

mw_data   <- rename(mw_data, level_mw = level, ls_id = id) %>% 
  mutate(dt = round_date(dt, unit = "hour"))             # round to nearest hour

# join baro and mw databy datetime, calculate adjusted water level
adj_data <- left_join(mw_data, baro_data, by = "dt") %>% 
  mutate(level_baro = zoo::na.approx(level_baro, na.rm = FALSE), # linear interpolation
         adj_level = level_mw - level_baro) # adjusted level            


# Adjust by elevation.

# read in elevation data from github
#elev <- read_csv("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/dependencies/elev.csv")
elev <- read_tsv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/clean/dependencies/elev.txt") %>% 
  filter(!is.na(ls_id))


# update adjusted data
adj_data <- left_join(adj_data, elev, by = "ls_id") 
adj_data <- mutate(adj_data, adj_level = ifelse(ll_subtracts_95_m == TRUE, 
                                                9.5 + adj_level, 
                                                adj_level))


# add water elevation and subtract cable length to find final water level
adj_data <- mutate(adj_data, final_level = adj_level + elev_m - cable_length) 

# grab subset of data to append to cloud db
rows_to_append <- select(adj_data, dt, ls_id, final_level) %>% rename(id = ls_id, level = final_level)



####################################################################################
# Write Transformed Data to Cloud DB
####################################################################################

# Connect to cloud database

# password for gw obs db
pw <- read_rds("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/dashboard/data/pw.rds")

# connect to the cloud SQL database 
cdb <- dbConnect(RMySQL::MySQL(),
                 user = "gw_observatory",
                 password = pw,
                 host = "169.237.35.237",
                 dbname = "gw_observatory",
                 port = 33306)



####################################################################################
# Read the present data, define object classes, append new data, and filter for the unique rows.

# most current data
present <- dbReadTable(cdb, "present")

# fix class of dates and levels in present data
present$dt <- ymd_hms(present$dt)

present <- present %>% 
  gather(id, level, -dt) %>% 
  mutate(level = as.numeric(level)) %>% 
  select(dt, id, level) 

# change ids so the join can occur
rows_to_append$id <- paste0("X", rows_to_append$id)     

# remove recent data saved in present df that will be replaced by data from rows to append
present <- filter(present, dt < current)
# append data from LevelSender sqlite from the past 90 days to insure that if a day of reporting
# is skipped then the data gets saved to the cloud database later
complete <- bind_rows(present, rows_to_append) %>% 
  distinct(dt, id, .keep_all = TRUE)

# cast back into wide format for shiny app and smaller data.frame
complete <- spread(complete, key = "id", value = "level")


####################################################################################
# Overwrite the `present` data in the cloud database.  
####################################################################################

# write 2 tables to database: present and every 7 days, save a copy

# overwrite existing "present" table
dbWriteTable(cdb, "present", complete, overwrite = TRUE) # overwrite existing table

# Save a version of the database every 7 days.

# days of year to save copy of the data
save_days <- seq(8,365, 7)

# get day of the year
doy <- yday(Sys.Date())

# if present day is a save day, save a version of the database with name = today's date
if(doy %in% save_days == TRUE){
  
  # format system date, which serves as the table name
  todays_date <- as.character(Sys.Date()) %>% str_replace_all(., pattern = "-", replacement = "_")
  
  # write the table
  dbWriteTable(cdb, todays_date, complete)
}



####################################################################################
# Find most recent email, get the battery life of LS, LL and baro (if MW5), 
# and save to a table in cloud db
####################################################################################

# find most recent email subject lines
most_recent_email_subject <- 
  separate(d, subject, into = c("id", "ls", "report", "report_num")) %>% 
  select(date, id, report_num) %>% 
  mutate(report_num = as.numeric(report_num)) %>% 
  group_by(id) %>% 
  top_n(n = 1, wt = date) %>% 
  distinct() %>% 
  filter(id %in% unique(mw_data$ls_id)) %>% 
  mutate(find = paste(id, "LS Report", report_num)) %>% 
  pull(find)

# extract most recent emails
most_recent_emails <- d[d$subject %in% most_recent_email_subject, ] %>% 
  group_by(subject) %>% 
  top_n(1, wt = date)

battery_lines <- lapply(most_recent_emails$body, function(x){unlist(strsplit(x, "\r\n"))} )

# function to apply
get_bat_life <- function(v){ 
  
  # does mw5 appear in the email? 
  ss <- sum(str_detect(v, mw5)) 
  
  # extract and clean id and battery lines
  id       <- v[str_detect(v, "Serial: ")][1]      # 1st serial is level sender id
  id       <- as.numeric(substr(id, 9, nchar(id))) # numeric
  battery  <- v[str_detect(v, "Battery: ")]        # battery life for LS and 2 LLs
  
  # get battery of LS, LL, and barologger
  battery_vals <- substr(battery, 9, nchar(battery)-1) %>% as.numeric()
  
  # make into df
  bat_df <- data.frame(id   = paste0("X", id),
                       bat  = battery_vals)
  
  # if the well == MW 5
  if (ss == 1) {
    bat_df$unit <- c("Sender", "Logger","Baro")
  }
  
  # if the well != mw5 and has a level sender and logger
  if (ss == 0 & nrow(bat_df) == 2) {
    bat_df$unit <- c("Sender", "Logger")
  }
  
  # if the well != mw5 and only has a sender. happens during test emails
  if (ss == 0 & nrow(bat_df) == 1) {
    bat_df$unit <- c("Sender")
  }
  
  return(bat_df)
}

# extract and compile battery life data frame
battery_life_df <- lapply(battery_lines, get_bat_life) %>% 
  bind_rows() %>% 
  arrange(bat)

# write to the cloud db
dbWriteTable(cdb, "battery_life_df", battery_life_df, overwrite = TRUE)

# write to temp directory
write_rds(battery_life_df, "C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/battery_life_df.rds")



####################################################################################
# Save a plot of the last 30 days of data to send in the automated report
####################################################################################

# write plot attachment
library(ggplot2)
ggp <- ggplot(rows_to_append %>% filter(dt >= current), aes(dt, level, color = factor(id))) + 
  geom_line() +
  labs(title    = paste("Adjusted Groundwater Levels, last updated:", Sys.Date()),
       subtitle = "Showing last 30 days",
       x = "Time", y = "Groundwater Level (m)",
       color = "LS ID #") +
  theme_minimal()

write_rds(ggp, "C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/ggp.rds")



####################################################################################
# Source the Rmd file that writes the daily report.
####################################################################################

# tell R where to find Pandoc
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")

# render the report
rmarkdown::render(input = "C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/02_daily_report.Rmd", 
                  output_file = "C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/02_daily_report.pdf", 
                  output_format = "pdf_document")

Sys.sleep(30)

####################################################################################
# Send the daily report via GMAIL API
####################################################################################

suppressPackageStartupMessages(library(gmailr))

# OAuth token
gm_auth_configure(path="C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/gmail_oauth_gwobs_secret.json")


# email list
emails <- read_tsv("https://raw.githubusercontent.com/richpauloo/cosumnes_shiny/master/clean/dependencies/email_list.txt") %>% 
  pull(email)

# compose and email report
for(i in 1:length(emails)){
  gm_mime() %>% 
    gm_from("cosumnes.gw.observatory@gmail.com") %>% 
    gm_to(emails[i]) %>% 
    gm_subject(paste("Groundwater Observatory Report:", Sys.Date())) %>% 
    gm_text_body("") %>% 
    gm_attach_file("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/clean/02_daily_report.pdf") %>% 
    gm_send_message()
  
    Sys.sleep(5)
}

1 # select default cosumnesgwobs gmail account

# find low battery
low_bat_life <- filter(battery_life_df, bat <= 69)
subject <- paste0("WARNING!! LOW BATTERY LIFE in LS ID # ", paste(low_bat_life$id, collapse = ", "),"!!")

# compose and send warning battery email
if(nrow(low_bat_life) >= 1){
  for(i in 1:length(emails)){
    mime() %>% 
      from("cosumnes.gw.observatory@gmail.com") %>% 
      to(emails[i]) %>% 
      subject(subject) %>% 
      text_body("See the daily report email for details. Rapidly change batteries to avoid a disruption in service.") %>% 
      send_message()
    
    Sys.sleep(5)
  }
}




####################################################################################
# Disconnect from SQLite and cloud SQL databases.
####################################################################################

dbDisconnect(db)  # SQLite
dbDisconnect(cdb) # cloud SQL
