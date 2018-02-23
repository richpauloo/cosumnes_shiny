library(RMySQL)

mysqlHasDefault()

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

# delete a table from the database
dbRemoveTable(con, "USArrests_2")

# see columns ("fields") in a particular table
dbListFields(con, "USArrests") # nothing for now

# import a table into R
dbReadTable(con, "USArrests")



# next step is to get this running in a shiny app