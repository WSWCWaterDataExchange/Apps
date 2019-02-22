#Map of site specific (Detail) data for Consumptive Use

output$cusemapData <- renderLeaflet({
  cusemap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4)%>%
    addPolygons(data=allstates,
                weight=4,opacity = 1.0, fillOpacity = 0,col='black')

    cusemap <-  addPolygons(cusemap,data=ss_cuse_custom,
                          weight=3,
                          col = 'grey',
                          highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                          group="Custom",
                          popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit Name:"), ss_cuse_custom$RU_Name,"<br>", 
                                      tags$b("Available Reports:"), ss_cuse_custom$REPORTLINK))
    cusemap <-  addPolygons(cusemap,data=ss_cuse_huc,
                             weight=3,
                             col = 'grey',
                             highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                             group="HUC",
                             popup=paste("<div class='leaflet-popup-scrolled' style='max-width:600px;max-height:100px'>",tags$b("Reporting Unit ID:"), ss_cuse_huc$HUC_8,"<br>",
                                         tags$b("Available Reports:"), ss_cuse_huc$REPORTLINK))
  
  
  #Add non-empty layers to the legend (as baseGroup layer names) for display
  layernames <- NULL
  if(nrow(ss_cuse_custom)>0){
    layernames <- c(layernames,"Custom")
  }
  if(nrow(ss_cuse_co)>0){
    layernames <- c(layernames,"County")
  }
  if(nrow(ss_cuse_huc)>0){
    layernames <- c(layernames,"HUC")
  }
  if(!is.null(layernames)){
  cusemap <- addLayersControl(cusemap,position = "bottomleft",
                            baseGroups = layernames,
                            options = layersControlOptions(collapsed = FALSE)
  )}
  cusemap
  
})