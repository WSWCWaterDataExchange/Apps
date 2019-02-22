#Map of site specific (Detail) data for Return Flows

output$rfmapData <- renderLeaflet({
  rfmap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4)%>%
    addPolygons(data=allstates,
                weight=4,opacity = 1.0, fillOpacity = 0,col='black')
  
 
    rfmap <-  addPolygons(rfmap,data=ss_rf_custom,
                          weight=3,
                          col = 'grey',
                          highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                          group="Custom",
                          popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>", tags$b("Reporting Unit Name:"), ss_rf_custom$RU_Name,"<br>", 
                                      tags$b("Available Reports:"), ss_rf_custom$REPORTLINK))
    rfmap <-  addPolygons(rfmap,data=ss_rf_co,
                            weight=3,
                            col = 'grey',
                            highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                            group="County",
                            popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), ss_rf_co$GEOID,"<br>", 
                                        tags$b("Available Reports:"), ss_rf_co$REPORTLINK))

    rfmap <-  addPolygons(rfmap,data=ss_rf_huc,
                             weight=3,
                             col = 'grey',
                             highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                             group="HUC",
                             popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), ss_rf_huc$HUC_8,"<br>",
                                         tags$b("Available Reports:"), ss_rf_huc$REPORTLINK))

  #Add non-empty layers to the legend (as baseGroup layer names) for display
  layernames <- NULL
  if(nrow(ss_rf_custom)>0){
    layernames <- c(layernames,"Custom")
  }
  if(nrow(ss_rf_co)>0){
    layernames <- c(layernames,"County")
  }
  if(nrow(ss_rf_huc)>0){
    layernames <- c(layernames,"HUC")
  }
  rfmap <- addLayersControl(rfmap,position = "bottomleft",
                            baseGroups = layernames,
                            options = layersControlOptions(collapsed = FALSE)
  )
  rfmap
  
})