# ui.R
load("data/ReportingUnits.Rdata")

shinyUI(fluidPage(theme="bootstrapdarkly.css",
  titlePanel("Wyoming Water Use Data Viewer"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Explore water use by sector. Currently, data is available for 2014."),
      selectInput(inputId = "reportingunit",
                  label = "Select a reporting unit:",
                  choices = RU_df$ReportingUnitName,
                  selected = "Loading Reporting Units")
    ),
    
    mainPanel(
      plotOutput(outputId="WUplot"),height="400px",
      br(),
      tableOutput("table"),
      br(),
      uiOutput("WUmethodlink")
    )
  )
))

