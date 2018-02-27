library(shiny)
library(googlesheets)
library(leaflet)

shinyUI(
  fluidPage(
    titlePanel(img(src='logo.png', width = 200)),
    
    sidebarLayout(
      sidebarPanel(
        h4("Cosumnes River Groundwater Observatory"),
        h6(paste("This app is updated daily, and displays real-time data from the Cosumnes",
                 "River Groundwater Observatory. Data is collected telemetrically at hourly intervals.")),
        h6(a("Click Here to See Code on Github",
             href="https://github.com/richpauloo/cosumnes_shiny",
             target="_blank"))
        
      ),
      mainPanel(
        tabsetPanel(
          
          tabPanel("map",
                   leafletOutput("map")
          ),
          
          tabPanel("data",
                   DT::dataTableOutput("data_table")
          ),
          
          tabPanel("plots",
                   plotOutput("plot")
          )
          
        )
      )
    )
  ))
