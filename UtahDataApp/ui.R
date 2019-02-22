# ui.R

load("data/ReportingUnits.Rdata")

shinyUI(fluidPage(theme="bootstrapdarkly.css",
  #Application Title
  titlePanel(title="Utah Water Data Exploration"),
  
  
  sidebarLayout(
    sidebarPanel(
      helpText("Explore water consumption and diversions by sector and source type, as reported by the 
               Utah Division of Water Resources via WaDE (Water Data Exchange). View available water data by selecting a reporting unit from the map."),
      helpText("For more information about the WaDE program, visit ", a("wade.westernstateswater.org/",
                       href="http://wade.westernstateswater.org/",target="_blank")),
      
      selectInput(inputId = "reportingunittype",
                  label = h3("Select a reporting unit type:"),
                  choices = c('County','HUC','Custom'),
                  selected = "County"),
      leafletOutput('mapData'),
      selectInput(inputId = "year", 
                  label = h3("Select a year to display:"),
                  choices = seq(2005,2014,by=1))
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Consumptive Use", 
                 plotlyOutput(outputId="CUplot"),height="400px",
                 br(),
                 tableOutput("CUtable"),
                 br(),
                 uiOutput("CUmethodlink")
        ),
        tabPanel("Diversions", 
                 plotlyOutput(outputId="Divplot"),height="400px",
                 br(),
                 tableOutput("Divtable"),
                 br(),
                 uiOutput("Divmethodlink")
        )
      )
    )
  )
))

