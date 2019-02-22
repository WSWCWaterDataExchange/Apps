#Custom Reporting Unit Map

output$CustomMapData <- renderLeaflet({
  custommap <- leaflet() %>%
    addProviderTiles(providers$OpenStreetMap.HOT) %>%
    setView(lng = -110, lat = 38, zoom = 4) %>%
    addPolygons(data=allstates,
                weight=4,opacity = 1.0, fillOpacity = 0,col='black')%>%
    addPolygons(data=CustomRU_available,
                weight=4,
                col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                group="Custom",
                popup=paste(tags$b("Reporting Unit ID:"), CustomRU_available$RU_ID, "<br>", 
                            tags$b("Name:"), CustomRU_available$RU_Name, "<br>",
                            CustomRU_available$CATALOGLINK)) %>%
    addPolygons(data = CA, weight=3, col = 'grey')%>%
    addPolygons(data = DAU, weight=1, col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE), group = "Detailed Analysis Unit",
                popup=paste(tags$b("Reporting Unit ID:"), DAU$RU_ID, "<br>", 
                            tags$b("Name:"), DAU$RU_Name, "<br>",
                            DAU$CATALOGLINK))%>%
    addPolygons(data = HR, weight=1, col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE), group = "Hydrologic Region",
                popup=paste(tags$b("Reporting Unit ID:"), HR$RU_ID, "<br>", 
                            tags$b("Name:"), HR$RU_Name, "<br>",
                            HR$CATALOGLINK))%>%
    
    addPolygons(data = PA, weight=1, col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE), group = "Planning Area",
                popup=paste(tags$b("Name:"), PA$RU_Name, "<br>",
                            PA$CATALOGLINK))%>%
    
    
    addPolygons(data = WA_Cust, weight=1, col = 'grey',
                highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),
                popup=paste(tags$b("Name:"), WA_Cust$RU_Name, "<br>",
                            WA_Cust$CATALOGLINK))%>% 
    
    addLayersControl(position = "bottomleft",
                baseGroups = c("Hydrologic Region","Detailed Analysis Unit", "Planning Area"),
                options = layersControlOptions(collapsed = TRUE)
  )
  
  
  })


