#ui.R

shinyUI(navbarPage("",
                  
                        tabPanel("Custom Reporting Unit",
                                tags$style(type = "text/css", "#CustomMapData {height: calc(100vh - 80px) !important;}"),
                                leafletOutput('CustomMapData')
                        ),
                        tabPanel("County",
                                 tags$style(type = "text/css", "#CountyMapData {height: calc(100vh - 80px) !important;}"),
                                 leafletOutput("CountyMapData")
                        ),
                        tabPanel("HUC",
                                 tags$style(type = "text/css", "#HUCMapData {height: calc(100vh - 80px) !important;}"),
                                 leafletOutput("HUCMapData")
                        )
                      )
                    )
                 

