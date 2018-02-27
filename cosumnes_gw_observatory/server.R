# server

shinyServer(function(input, output, session) {
  
  output$plot <- renderPlot({
    
    grouped_heads %>% 
      ggplot() + geom_line(aes(x = Date, y = mean)) + 
      geom_ribbon(aes(x = Date, ymin = min, ymax = max), alpha = 0.2)
    
  })
  
  output$data_table <- renderDataTable({
    
    DT::datatable(df)
    
  })
  
  output$map <- renderLeaflet({
    
    leaflet(cs_coords) %>% 
      addTiles() %>% 
      addMarkers(~long, ~lat, popup = ~well) %>% 
      addMeasure(
        position = "topleft",
        primaryLengthUnit = "meters",
        primaryAreaUnit = "sqmeters",
        activeColor = "#3D535D",
        completedColor = "#7D4479") %>% 
      addProviderTiles(providers$Esri.WorldImagery)
    
  })
  
})



