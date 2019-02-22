library(leaflet)

shinyUI(navbarPage("",
                     
                   tabPanel("Water Supply", 
                            tags$style(type = "text/css", "#supplymapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("supplymapData")),
                   # tabPanel("Water Availability", 
                   #          tags$style(type = "text/css", "#availabilityMapData {height: calc(100vh - 80px) !important;}"),
                   #          leafletOutput("availabilitymapData")),
                   tabPanel("Water Use", 
                            tags$style(type = "text/css", "#usemapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("usemapData")),
                   tabPanel("Regulatory Information", 
                            tags$style(type = "text/css", "#regulatorymapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("regulatorymapData"))
                            
                            
                   
  
  )
)
