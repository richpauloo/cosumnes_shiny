library(shiny)
library(googlesheets)
library(DT)
library(tidyverse)
#library(tibbletime)
library(stringr)
library(cowplot)

cs_key <- extract_key_from_url("https://docs.google.com/spreadsheets/d/1PGvaPn4wqXb02bnujJ31edoleVYJFnpL4OsP_tcXSeU/edit#gid=0")

cs_ss <- gs_key(cs_key)

cs_hydro <- gs_read(cs_ss, ws = "hydrographs")
cs_coords <- gs_read(cs_ss, ws = "coords")

# gather the data so it's easy to plot
cs_hydro_long <- gather(cs_hydro, well, head, -time)

# mutate times in date format
cs_hydro_long$time <- strptime(cs_hydro_long$time, "%m/%d/%Y %H:%M:%S")


# basemaps
esri <- grep("^Esri", providers, value = TRUE)

l <- leaflet(cs_coords)
for (provider in esri) {
  l <- l %>% addProviderTiles(provider, group = provider)
}


# server
shinyServer(function(input, output, session) {
  
  output$plot <- renderPlot({
    
    ggplot(cs_hydro_long) +
      geom_line(aes(x=time, y = head, color = well)) + theme_cowplot()
    
  })
  
  output$data_table <- renderDataTable({
    
    DT::datatable(cs_hydro)
    
  })
  
  output$map <- renderLeaflet({
    
    l %>% 
      addTiles() %>% 
      addMarkers(~long, ~lat, popup = ~well) %>% 
      addMeasure(
        position = "topleft",
        primaryLengthUnit = "meters",
        primaryAreaUnit = "sqmeters",
        activeColor = "#3D535D",
        completedColor = "#7D4479") %>% 
      addLayersControl(baseGroups = names(esri),
                       options = layersControlOptions(collapsed = FALSE)) %>%
      htmlwidgets::onRender("
                            function(el, x) {
                            var myMap = this;
                            myMap.on('baselayerchange',
                            function (e) {
                            myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                            })
                            }")
    
  })
  
  
})