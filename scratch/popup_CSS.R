# leaflet with leaflet popuptable CSS
m <- leaflet() %>%
  addProviderTiles("OpenStreetMap") %>%
  addPolygons(data = franconia,
              fillOpacity = 0.5, 
              color = "#BDBDC3", 
              weight = 2,
              group = "Municipios",
              popup = popupTable(franconia, zcol = 2:6 ))

# generate a regular mapview object to get default popup CSS
v <- mapview(breweries91, zcol = "founded")
v@map$dependencies[[4]] # this is the popup table dependency that we want

# add the popup table css from mapview to override leaflet's
m$dependencies <- list(m$dependencies[[1]],m$dependencies[[2]],
                       v@map$dependencies[[4]])

m

