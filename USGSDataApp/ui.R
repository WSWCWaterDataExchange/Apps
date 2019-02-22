# ui.R
library(leaflet)
load("data/ReportingUnits.Rdata")

shinyUI(fluidPage(theme="bootstrapdarkly.css",
  #img(src='UtahDivofWaterResources.jpg', align = "left",height=50,width=50),
  titlePanel("USGS Water Use Data Exploration"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Explore water withdrawals and consumptive use, as reported by the 
               USGS National Water Use Science Program."),
      selectInput(inputId = "state",
                  label = "Select a State:",
                  choices = datasets::state.name,
                  selected = "Colorado"),
      selectInput(inputId = "year", 
                  label = "Select a year to display:",
                  choices = c("1990", "1995"),
                  selected = "1990")
    ),
    
    mainPanel(
      leafletOutput('mapData'),
      verbatimTextOutput("huc"),
      helpText("Click a HUC to switch to a different watershed."),
      plotOutput(outputId="CUplot"),height="400px",
      tableOutput("CUtable"),
      textOutput(outputId="CUmethod"),
      plotOutput(outputId="Divplot"),height="400px",
      tableOutput("Divtable"),
      textOutput(outputId="Divmethod")
      )
  )
))

