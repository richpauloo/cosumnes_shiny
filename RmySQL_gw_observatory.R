library(RMySQL)

# create a mySQL connection object
con <- dbConnect(RMySQL::MySQL(), 
                 user = "gw_observatory",
                 password = "",
                 host = "sage.metro.ucdavis.edu",
                 dbname = "gw_observatory")

# summary of the connection
summary(con)

# dbGetInfo()
dbGetInfo(con)

# see what's inside
dbListTables(con) 

# write a table to the database
temp <- read_csv("C:/Users/rpauloo/Documents/GitHub/cosumnes_shiny/cosumnes_gw_observatory/AllData.csv")
temp$Date <- as.POSIXct( strptime(temp$Date, format = '%m/%d/%Y %H:%M:%S') )
temp_formatted <- temp %>% mutate_if(is.character, as.numeric) 
dbWriteTable(con, "test", temp_formatted, overwrite = TRUE)




# delete a table from the database
dbRemoveTable(con, "USArrests")

# see columns ("fields") in a particular table
dbListFields(con, "USArrests") # nothing for now

# import a table into R
test <- dbReadTable(con, "test")


# next step is to get this running in a shiny app