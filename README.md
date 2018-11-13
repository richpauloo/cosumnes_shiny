# About 

This repo contains all the scripts necessary to build an interactive web dashboard for a groundwater observatory in the open source language R.  

As an example, please see the [Cosumnes River Groundwater Observatory](https://richpauloo.shinyapps.io/gw_observatory/), a project of UC Water.  

![](dash.png)  


***  

# Contents

The `clean` folder contains scripts that are automatically run every day at 04:00:00. Together these scripts:  

* retrieve data from [Solinst](https://www.solinst.com/) hardware  
* clean and transform the data  (i.e. - adjust for reference elevation, baromaetric pressure)  
* generate a report of remaining battery life and recent monitoring well data and email that report to a contact list  
* push a clean version of the database to the cloud  
* save versions of the database every 7 days to the cloud  

The `dashboard` folder contains (among other files), the three files comprising an [R Shiny App](https://shiny.rstudio.com/): 

* `global.R`  
* `server.R`  
* `ui.R`  

Together, these files build the app.  

***  

# Use

If you aim to set of a monitoring well network of your own, this software is free to use for your purposes. You will need a skilled R programmer familiar with Shiny to integrate your hardware with this software.  





