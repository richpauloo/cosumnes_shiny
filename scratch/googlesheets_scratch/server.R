# server

shinyServer(function(input, output, session) {
  
  # output$plot <- renderPlot({
  #   
  #   ggplot(cs_hydro_long) +
  #     geom_line(aes(x=Date, y = head, color = well)) + theme_cowplot()
  #   
  # })
  
  output$data_table <- renderDataTable({
    
    DT::datatable(cs_hydro_long)
    
  })
  
  # output$map <- renderLeaflet({
  #   
  #   leaflet(cs_coords) %>% 
  #     addTiles() %>% 
  #     addMarkers(~long, ~lat, popup = ~well) %>% 
  #     addMeasure(
  #       position = "topleft",
  #       primaryLengthUnit = "meters",
  #       primaryAreaUnit = "sqmeters",
  #       activeColor = "#3D535D",
  #       completedColor = "#7D4479") %>% 
  #     addProviderTiles(providers$Esri.WorldImagery)
  #   
  # })
  
})