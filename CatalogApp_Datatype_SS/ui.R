library(leaflet)

shinyUI(navbarPage("",
                   tabPanel("Water Rights", 
                            tags$style(type = "text/css", "#allocationmapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("allocationmapData")),
                   tabPanel("Diversions", 
                            tags$style(type = "text/css", "#diversionmapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("diversionmapData")),        
                   tabPanel("Consumptive Use", 
                            tags$style(type = "text/css", "#cusemapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("cusemapData")),
                   tabPanel("Return Flow", 
                            tags$style(type = "text/css", "#rfmapData {height: calc(100vh - 80px) !important;}"),
                            leafletOutput("rfmapData"))
  
  )
)
