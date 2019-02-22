#CountyMap

output$CountyMapData <- renderLeaflet({
  countymap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4) %>%
    addPolygons(data=allstates,
                weight=4,opacity = 1.0, fillOpacity = 0,col='black')%>%
    addPolygons(data=CO_available,
                weight=3,
                col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                group="County",
                popup=paste(tags$b("ID:"), CO_available$GEOID, "<br>", 
                            tags$b("Name:"), CO_available$NAME, "<br>",
                            CO_available$CATALOGLINK))
  })
