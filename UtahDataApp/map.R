#Show shapefile data for Utah based on the type of reporting unit selected
output$mapData <- renderLeaflet({
  RUmap <- leaflet() %>%
    setView(lng = state_center_lng, lat = state_center_lat, zoom = 6) %>%
    addTiles()
  switch(input$reportingunittype,
         HUC = {RUmap %>%
             addPolygons(data=simplehuc8,layerId=~ReportingU,weight=3,col = 'grey',
                         highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),group="HUC")},
         County = {RUmap %>%
             addPolygons(data=simplecounty,layerId=~ReportingU,weight=3,col = 'grey',
                         highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),group="County")},
         Custom = {RUmap %>%
             addPolygons(data=simplecustom,layerId=~ReportingU,weight=3,col = 'grey',
                         highlightOptions = highlightOptions(color = "blue", weight = 2,bringToFront = TRUE),group="Custom")
             })
})





observe({
  leafletProxy("mapData") %>%
    clearPopups()
  clk <- input$mapData_shape_click
  if (!is.null(clk)) {
    ru_id <<- clk$id
    
    content <- paste0('<font color="black">',get_RUNameID(), '</font>')
    
    leafletProxy("mapData") %>%
      addPopups(clk$lng, clk$lat, popup=content,options = popupOptions(closeButton = TRUE))
    }

})
