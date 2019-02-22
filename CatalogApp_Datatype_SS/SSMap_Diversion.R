#Map of site specific (Detail) data for Diversions


output$diversionmapData <- renderLeaflet({
    diversionmap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4)%>%
      addPolygons(data=allstates,
                  weight=4,opacity = 1.0, fillOpacity = 0,col='black')
    
      diversionmap <-  addPolygons(diversionmap,data=ss_diversion_custom,
                                  weight=3,
                                  col = 'grey',
                                  highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                                  group="Custom",
                                  popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit Name:"), ss_diversion_custom$RU_Name,"<br>", 
                                              tags$b("Available Reports:"), ss_diversion_custom$REPORTLINK))
    
    
      diversionmap <-  addPolygons(diversionmap,data=ss_diversion_co,
                              weight=3,
                              col = 'grey',
                              highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                              group="County",
                              popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), ss_diversion_co$GEOID,"<br>", 
                                          tags$b("Available Reports:"), ss_diversion_co$REPORTLINK))
    
      diversionmap <-  addPolygons(diversionmap,data=ss_diversion_huc,
                               weight=3,
                               col = 'grey',
                               highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                               group="HUC",
                               popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), ss_diversion_huc$HUC_8,"<br>",
                                           tags$b("Available Reports:"), ss_diversion_huc$REPORTLINK))
   
      #Add non-empty layers to the legend (as baseGroup layer names) for display
      layernames <- NULL
      if(nrow(ss_diversion_custom)>0){
        layernames <- c(layernames,"Custom")
      }
      if(nrow(ss_diversion_co)>0){
        layernames <- c(layernames,"County")
      }
      if(nrow(ss_diversion_huc)>0){
        layernames <- c(layernames,"HUC")
      }
    diversionmap <- addLayersControl(diversionmap,position = "bottomleft",
                     baseGroups = layernames,
                     options = layersControlOptions(collapsed = FALSE)
    )
    diversionmap
  
})