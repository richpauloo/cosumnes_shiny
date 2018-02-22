library(shiny)
library(googlesheets)
library(leaflet)

shinyUI(
  fluidPage(
    titlePanel("Cosumnes River Groundwater Observatory"),
    
    sidebarLayout(
      sidebarPanel(
        h6(paste("This app is hard-wired to read a single, public Google",
                 "Sheet.")),
        h6("Visit the Sheet in the browser:", a("HERE", href = gs_gap_url(),
                                                target="_blank")),
        h6(paste("Since there is no user input, it defaults to reading",
                 "the first worksheet in the spreadsheet.")),
        h6(a("Click Here to See Code on Github",
             href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples/01_read-public-sheet",
             target="_blank"))
      ),
      mainPanel(
        img(src='logo.png'),
        tabsetPanel(
          
          tabPanel("plots",
                   plotOutput("plot")
          ),
          
          tabPanel("data",
                   DT::dataTableOutput("data_table")
          ),
          
          tabPanel("map",
                   leafletOutput("map")
          )
          
        )
      )
    )
  ))