# ui.R
load("data/ReportingUnits.Rdata")

shinyUI(
  fluidPage(
    theme="bootstrapdarkly.css",
    titlePanel("California Water Supply and Water Use Data Exploration"),
           sidebarLayout(
             sidebarPanel(
               img(src='CADWRLogo.png', align = "left",height=100,width=100),
               helpText("Explore water supply and water use as reported by the 
          California Department of Water Resources for 2010. Note that data may not
          be available for all reporting units."),
               # sliderInput(inputId = "year", 
               #             label = "Select a year to display:",
               #             min=2010,max=2010,round=TRUE,ticks=FALSE,value=2010,sep=""),
               selectInput(inputId = "reportingunit",
                           label = "Select a reporting unit:",
                           choices = RU_df$Name_ID,
                           selected = "Loading Reporting Units"),
               selectInput(inputId = "displaytype",
                           label = "Display summary data as:",
                           choices = c("Barplot","Pie Chart","Dotplot"))
             ),
             mainPanel(
              tabsetPanel(
                 tabPanel("Water Supply", 
                          plotOutput(outputId="WSplot"),height="400px",
                          br(),
                          tableOutput("WStable"),
                          br(),
                          uiOutput("WSmethodlink")
                 ),
                 tabPanel("Water Use", 
                          plotOutput(outputId="WUplot"),height="400px",
                          br(),
                          tableOutput("WUtable"),
                          br(),
                          uiOutput("WUmethodlink")
                 )
                 
              )
            )
          )
  )
)

