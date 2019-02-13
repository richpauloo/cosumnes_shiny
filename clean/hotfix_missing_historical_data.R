# first go to lines 10 through 23 and connect to the cloud database that the app reads
# diagnose problem "present" data is truncated at ~1,000 entries instead of 50,000
# determine the last saved copy of the data with all records and use it to "restart" the "present" dataframe

nam <- dbListTables(cdb) # names of tables in database
l <- lapply(nam, function(x){return(dbReadTable(cdb, x))}) # read all tables
sapply(l, nrow) # nrow of each table: where was the data lost?


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
present <- dbReadTable(cdb, "2019_01_29") # 2019_01_29 is the last saved copy of the data with all records

# fix class of dates and levels in present data
present$dt <- ymd_hms(present$dt)

present <- present %>% 
  gather(id, level, -dt) %>% 
  mutate(level = as.numeric(level)) %>% 
  select(dt, id, level) 

# change ids so the join can occur
rows_to_append$id <- paste0("X", rows_to_append$id)     

# append new data and trim overlapping data
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