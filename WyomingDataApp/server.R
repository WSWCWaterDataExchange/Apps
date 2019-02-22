# server.R

shinyServer(
  function(input, output, session) {
    #Fetch reporting units for the state (for selection in dropdown menu)
    load("data/ReportingUnits.Rdata")
    
    #WATER USE###################################################################################################################################    
    #Fetch consumptive use data when the user changes the inputs (location)
    WU_data <- reactive({
      RU_dfSub <- RU_df[!is.na(RU_df$ReportingUnitName),]
      RUNumber <- RU_dfSub[(RU_dfSub$ReportingUnitName==input$reportingunit),"ReportingUnit"]
      
      wade_url <- paste0('http://www.westernstateswater.org/Wyoming/WADE/v0.2/GetSummary/GetSummary.php?',
                         'loctype=REPORTUNIT&loctxt=',
                         RUNumber,
                         '&orgid=WYWDC&reportid=2014&datatype=USE')

      return(get_wade_data(wade_url = wade_url))
      
    })

    #Plots the results from the GetSummary call
    output$WUplot <- renderPlot({
      #Get data from reactive function (based on inputs of year and reporting unit)
      WU_df=WU_data()
      title="Comparison of Water Use by Sector"
      ggplot(data=WU_df,environment = environment())+
        geom_bar(aes(x=Sector,y=Amount, fill=SourceType),stat="identity")+
        theme_bw()+scale_fill_brewer(palette="Paired")+
        xlab("Sector")+ylab("Water Use (acre-feet/year)")+ggtitle(title)+
        theme(legend.position="bottom",plot.title = element_text(hjust = 0.5))
    })
    
    #List amounts in table
    output$table <- renderTable({
      WU_df=WU_data()
    },bordered=TRUE, striped=TRUE)
    
    #Returns information about the method
    WUmethod_url='http://www.westernstateswater.org/Wyoming/WADE/v0.2/GetMethod/GetMethod.php?methodid=WYWDC&methodname=Green%20River%20Basin%20Report%20Consumptive%20Use%20Estimation'
    WUmethod_df <- get_wade_method(WUmethod_url)
    
    #Prints the method information
    WUlink <- a("Water Use Methodology", href=WUmethod_df$MethodLinkText[[1]])
    output$WUmethodlink <- renderUI({
      tagList("For more information about the methods used for this data, see:",WUlink)
    })
    
    source("map.R",local=TRUE)$value
  }
)