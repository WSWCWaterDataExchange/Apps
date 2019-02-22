# Reactive function to grab the data we need from wateRuse
mapData <- reactive({
  
  unit_type <- "huc"
  
  year <- input$year # not used in function for now
  
  state <- input$state
  
  mapData <- get_state_spatial_units(state = state, 
                                     unit_type = unit_type,
                                     year = year)
  mapData
})

# renderLeaflet function that runs when the app reloads inputs.
output$mapData <- renderLeaflet({
  
  mapData <- mapData()
  
  fi <- tempfile()
  geoJson <- rgdal::writeOGR(mapData, dsn = fi, driver = "GeoJSON", layer = fi)
  geoJson <- readLines(fi) %>% paste(collapse = "\n")
  geoJson<-jsonlite::fromJSON(txt=readLines(fi, warn = FALSE),
                    collapse = "\n",simplifyVector = FALSE)
  
  leaflet() %>% 
    setView(lng = mean(mapData@bbox[1,]), lat = mean(mapData@bbox[2,]), zoom = 6) %>%
    addTiles() %>%
    addGeoJSON(geojson = geoJson)
  
})

# observe for a map click and register some variables to the global scope.
# Other observes are watching for wade_app_id!
observe({
  
  leafletProxy("mapData") %>% clearPopups()
  
  clk <- input$mapData_geojson_click
  if (!is.null(clk)) {
  
    wade_app_id <<- clk$properties$wade_app_id
    
    wade_app_label <<- clk$properties$wade_app_label
    
    content <- paste0('<font color="black">', wade_app_label, '</font>') #what a hack! The app CSS makes this text white.
    
    leafletProxy("mapData") %>% addPopups(clk$lng, clk$lat, content,
                                          options = popupOptions(closeButton = FALSE))
  }
})