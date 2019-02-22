#Map of aggregated (summary) data for Availability

output$availabilitymapData <- renderLeaflet({
    availabilitymap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4) %>%
    addPolygons(data=allstates,
                weight=4,opacity = 1.0, fillOpacity = 0,col='black')
    
    availabilitymap <-  addPolygons(availabilitymap,data=agg_availability_custom,
                           weight=3,
                           col = 'grey',
                           highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                           group="Custom",
                           popup=paste(tags$b("Reporting Unit Name:"), agg_availability_custom$RU_Name, "<br>",
                                       tags$b("Available Reports:"), agg_availability_custom$REPORTLINK))
      availabilitymap <-  addPolygons(availabilitymap,data=agg_availability_co,
                               weight=3,
                               col = 'grey',
                               highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                               group="County",
                               popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), agg_availability_co$GEOID, "<br>",
                                           tags$b("Available Reports:"), agg_availability_co$REPORTLINK))
    
      availabilitymap <-  addPolygons(availabilitymap,data=agg_availability_huc,
                                weight=3,
                                col = 'grey',
                                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                                group="HUC",
                                popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), agg_availability_huc$HUC_8, "<br>",
                                            tags$b("Available Reports:"), agg_availability_huc$REPORTLINK))
    
      #Add non-empty layers to the legend (as baseGroup layer names) for display
      layernames <- NULL
      if(nrow(agg_availability_custom)>0){
        layernames <- c(layernames,"Custom")
      }
      if(nrow(agg_availability_co)>0){
        layernames <- c(layernames,"County")
      }
      if(nrow(agg_availability_huc)>0){
        layernames <- c(layernames,"HUC")
      }
      
    availabilitymap <- addLayersControl(availabilitymap,position = "bottomleft",
                               baseGroups = layernames,
                               options = layersControlOptions(collapsed = FALSE)
    )
    availabilitymap
  
})