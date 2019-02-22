#HUC Map


output$HUCMapData <- renderLeaflet({
  hucmap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4) %>%
    addPolygons(data=allstates,
                weight=4,opacity = 1.0, fillOpacity = 0,col='black')%>%
    addPolygons(data=HUC_available,
                weight=3,
                col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                group="HUC",
                popup=paste(tags$b("ID:"), HUC_available$HUC_8, "<br>", 
                            HUC_available$CATALOGLINK))
  })