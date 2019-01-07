shinyServer(function(input, output, session){

observeEvent(input$location, {
    x <- input$location
	if(!is.null(x) && x!=""){
        sink("locationLog.txt", append=TRUE, split=FALSE)
        cat(paste0(x, "\n"))
        sink()
    }
})

# leaflet output of wells
output$Map <- renderLeaflet({
	leaflet() %>% 
    addProviderTiles(providers$Esri.WorldImagery) %>% 
		addCircleMarkers(data         = cs_coords, 
		                 stroke       = TRUE, 
		                 color        = "black",
		                 opacity      = 1,
		                 weight       = 1,
		                 fillOpacity  = 0.7, 
		                 fillColor    = "magenta",
		                 radius       = 6,
		                 layerId      = ~Location, 
		                 label        = ~hover_text,
		                 labelOptions = labelOptions(
		                   offset = c(-30,-60),
		                   textOnly = T,
		                   style    = list(
		                     'background'='rgba(255,255,255,0.95)',
		                     'border-color' = 'rgba(0,0,0,1)',
		                     'border-radius' = '3px',
		                     'border-style' = 'solid',
		                     'border-width' = '4px'))
		                 )
})

observeEvent(input$Map_marker_click, {
    p <- input$Map_marker_click
	if(p$id=="Selected"){
		leafletProxy("Map") %>% removeMarker(layerId="Selected")
	} else {
		leafletProxy("Map") %>% setView(lng=p$lng, lat=p$lat, input$Map_zoom) %>% addCircleMarkers(p$lng, p$lat, radius=10, color="black", fillColor="orange", fillOpacity=1, opacity=1, stroke=TRUE, layerId="Selected")
	}
})

observeEvent(input$Map_marker_click, {
	p <- input$Map_marker_click
	if(!is.null(p$id)){
		if(is.null(input$location)) updateSelectInput(session, "location", selected=p$id)
		if(!is.null(input$location) && input$location!=p$id) updateSelectInput(session, "location", selected=p$id)
	}
})

# when a location is chosen in the drop down menu, change the map popup
observeEvent(input$location, {
	p <- input$Map_marker_click
	p2 <- cs_coords %>% filter(Location==input$location)
	if(nrow(p2)==0){
		leafletProxy("Map") %>% removeMarker(layerId="Selected")
	} else if(is.null(p$id) || input$location!=p$id){
		leafletProxy("Map") %>% setView(lng=p2$lng, lat=p2$lat, input$Map_zoom) %>% addCircleMarkers(p2$lng, p2$lat, radius=10, color="black", fillColor="orange", fillOpacity=1, opacity=1, stroke=TRUE, layerId="Selected")
	}
})



# when the location changes, so does the data for the plot
location <- reactive({ 
  well_dat_daily %>% gather(wells, value, -Date) %>% 
    filter(wells == input$location)
})


location_units <- reactive({
  temp <- location()
  if(input$units == "feet") return(cbind.data.frame(Date = temp[,1], value = (temp[,3]) * 3.28084)) else return(temp) 
})
  


# individual well plot
output$Chart1 <- renderPlotly({
  if(!length(input$location) || input$location=="") return(plotly()) # blank until a location is selected
  
  # plot
  location_units() %>% 
    plot_ly(x = ~Date) %>%
    add_lines(y = ~value, name = input$location) %>% 
    layout(
      title = FALSE,
      # title = paste0("Monitoring Well ID: ", input$location),
      xaxis = list(
        rangeselector = list(
          buttons = list(
            list(
              count = 3,
              label = "3 mo",
              step = "month",
              stepmode = "backward"),
            list(
              count = 6,
              label = "6 mo",
              step = "month",
              stepmode = "backward"),
            list(
              count = 1,
              label = "1 yr",
              step = "year",
              stepmode = "backward"),
            list(
              count = 1,
              label = "YTD",
              step = "year",
              stepmode = "todate"),
            list(step = "all"))),
        
        rangeslider = list(type = "date")),
      
      yaxis = list(title = paste0("Level (", input$units, ")"))) %>% 
    config(displayModeBar = FALSE) %>% 
    add_annotations(
      yref="paper", 
      xref="paper", 
      y=1.15, 
      x=1, 
      text = paste0(input$location, " Hydrograph"), 
      showarrow=F, 
      font=list(size=17)
    )
})


# map for all wells
output$network <- renderPlotly({
  # gather data and get geom_smooth line from it
  temp <- NA
  ifelse(input$units_2 == "meters", 
         temp <- well_dat_daily, 
         temp <- cbind.data.frame(Date = well_dat_daily[,1], (well_dat_daily[,-1]) * 3.28084))
  
  temp %>% 
    gather(wells, level, -Date) %>% 
    qplot(Date, level, data = .) + stat_smooth() -> p
  
  # get geom_smooth coords 
  ggplot_build(p)$data[[2]] %>% select(x,y,ymin,ymax) -> smooth
  
  #smooth$x <- as.Date(as.POSIXct(smooth$x, origin="1970-01-01"))
  smooth$x <- anytime(smooth$x)
  
  temp2 <- gather(temp, wells, level, -Date)
  ggp <- ggplot(temp2, aes(Date, level)) +
    geom_line(aes(color = wells)) +
    geom_smooth(color = "red") +
    scale_color_grey() +
    labs(y = paste0("Level (", input$units_2, ")")) +
    theme(legend.position='none') +
    scale_x_datetime(limits = c( ymd(input$date_range[1], tz= "UTC"), 
                                 ymd(input$date_range[2], tz = "UTC"))) 
  ggplotly(ggp)
    
  
#   # plot 
  # plot_ly(temp, x = ~Date) %>%
  #   add_lines(y = ~MW2, name = "MW2", color= I("gray5")) %>%
  #   add_lines(y = ~MW9, name = "MW9", color= I("gray10")) %>%
  #   add_lines(y = ~MW11, name = "MW11", color= I("gray15")) %>%
  #   add_lines(y = ~MW20, name = "MW20", color= I("gray20")) %>%
  #   add_lines(y = ~OnetoAg, name = "OnetoAg", color= I("gray25")) %>%
  #   add_lines(y = ~MW19, name = "MM19", color= I("gray30")) %>%
  #   add_lines(y = ~MW23, name = "MW23", color= I("gray35")) %>%
  #   add_lines(y = ~MW22, name = "MW22", color= I("gray40")) %>%
  #   add_lines(y = ~MW7, name = "MW7", color= I("gray45")) %>%
  #   add_lines(y = ~MW5, name = "MW5", color= I("gray50")) %>%
  #   add_lines(y = ~MW3, name = "MW3", color= I("gray55")) %>%
  #   add_lines(y = ~MW17, name = "MW17", color= I("gray60")) %>%
  #   add_lines(y = ~MW13, name = "MW13", color= I("gray65")) %>%
  #   add_ribbons(data = smooth, x=~x, ymin=~ymin, ymax=~ymax, color = I("gray80"), name = "Confidence Interval") %>%
  #   add_lines(data = smooth, x=~x, y=~y, color = I("red"), name = "AVERAGE") %>%
  #   layout(
  #     showlegend = FALSE,
  #     title = FALSE, #"Entire Monitoring Well Network",
  #     xaxis = list(
  #       rangeselector = list(
  #         buttons = list(
  #           list(
  #             count = 3,
  #             label = "3 mo",
  #             step = "month",
  #             stepmode = "backward"),
  #           list(
  #             count = 6,
  #             label = "6 mo",
  #             step = "month",
  #             stepmode = "backward"),
  #           list(
  #             count = 1,
  #             label = "1 yr",
  #             step = "year",
  #             stepmode = "backward"),
  #           list(
  #             count = 1,
  #             label = "YTD",
  #             step = "year",
  #             stepmode = "todate"),
  #           list(step = "all"))),
  # 
  #       rangeslider = list(type = "date"),
  #       range = c( input$date_range[1], input$date_range[2])
  #     ),
  # 
  #     yaxis = list(title = paste0("Level (", input$units_2, ")"))
  # 
  #   ) %>%
  # 
  #   config(displayModeBar = FALSE)

})

# Download All Data
output$download_all_data <- downloadHandler(
  # This function returns a string which tells the client browser what name to use when saving the file.
  filename = function() {
    paste0("UC_Water_gw_observatory", ".csv")
  },
  
  # This function should write data to a file given to it by the argument 'file'.
  content = function(file) {
    # Write to a file specified by the 'file' argument
    write.table(well_dat_daily, file, sep = ",", row.names = FALSE)
  }
)

})