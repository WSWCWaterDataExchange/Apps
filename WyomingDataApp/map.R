output$mapData <- renderLeaflet({
  data(state)
  state_center_lng <- state.center$x[which(state.name == "Wyoming")]
  stae_center_lat <- state.center$y[which(state.name == "Wyoming")]
  leaflet() %>%
    addTiles() %>%
    setView(lng = state_center_lng, lat = stae_center_lat, zoom = 6) %>%
    addEsriFeatureLayer(
      url='https://services.arcgis.com/dFb8rUV8WxUeyMa2/ArcGIS/rest/services/Wyoming_River_Basins/FeatureServer/0',
      useServiceSymbology = TRUE)
})

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
