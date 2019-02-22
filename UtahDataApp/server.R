# server.R

shinyServer(function(input, output,session) {
  #Link to map functions
  source("map.R",local=TRUE)$value
  
  #Register an ru_id variable so they can be set in an "observe" in map.R
  ru_id <- RU_List[1,"ReportingUnit"]
  makeReactiveBinding("ru_id") 
  
  #Determine suffix for url (depends on type of reporting unit)
  url_suffix <- reactive({
    switch(input$reportingunittype,
           HUC = {suffix <- '_HUC8'},
           County = {suffix <- '_County'},
           Custom = {suffix <- ''}
           )
    return(suffix)
  })
  
  #Return the Reporting Unit Name and ID (changes when user clicks on map)
  get_RUNameID <- reactive({
    RUNameID <- RU_List[(RU_List$ReportingUnit==ru_id),"Name_ID"]
    return(RUNameID)
  })
  
  #Return the Reporting Unit Name (changes when user clicks on map)
  get_RUName <- reactive({
    RUName <- RU_List[(RU_List$ReportingUnit==ru_id),"ReportingUnitName"]
    return(RUName)
  })
  
  #Return data for consumptive use (changes when user clicks on map)
  CU_data <- reactive({
    #Fetch and parse data
    CU_url <- paste0('https://water.utah.gov/DWRE/WADE/v0.2/GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=',
                     ru_id,
                     '&orgid=utwre&reportid=',
                     input$year,
                     '_ConsumptiveUse',url_suffix(),'&datatype=ALL')
    
    return(get_wade_data(wade_url = CU_url))
  })
  
  #Return data for diversions (changes when user clicks on map)
  Div_data <- reactive({
    Div_url <- paste0('https://water.utah.gov/DWRE/WADE/v0.2/GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=',
                      ru_id,
                      '&orgid=utwre&reportid=',
                      input$year,
                      '_Diversion',url_suffix(),'&datatype=ALL')
    
    return(get_wade_data(wade_url = Div_url))
  })
    
    
    #CONSUMPTIVE USE###################################################################################################################################    
    #Creates outputs for consumptive use data when the user changes the inputs (year or location)
    CU_data_set <- observe({ # 

      output$CUplot <- renderPlotly({
        CU_df <- CU_data()
        title <- paste("Comparison of Consumptive Use by Sector for:",get_RUName())
        CU_plot <-  ggplot(data=CU_df,environment = environment())+
          geom_bar(aes(x=Sector,y=Amount, fill=SourceType),stat="identity")+
          theme_bw()+scale_fill_brewer(palette="Paired", name="Source")+
          xlab("Sector")+ylab("Consumptive Use (acre-feet/year)")+ggtitle(title)+
          theme(legend.position="bottom",plot.title = element_text(hjust = 0.5))
        ggplotly(CU_plot)
      })
      
      #List amounts in table
      output$CUtable <-renderTable({
        CU_df <- CU_data()
      },bordered=TRUE,striped=TRUE)
    })  

    CUmethod_url <- 'https://water.utah.gov/DWRE/WADE/v0.2/GetMethod/GetMethod.php?methodid=utwre&methodname=CONSUMPTIVE_USE'
    CUmethod_df <- get_wade_method(CUmethod_url)
    
    CUlink <- a("Consumptive Use Methodology", href=CUmethod_df$MethodLinkText[[1]])
    output$CUmethodlink <- renderUI({
      tagList("For more information about the methods used for this data, see:",CUlink)
    })
     
    
    #DIVERSION##########################################################################################################################################    
    #Creates outputs for diversion data when the user changes the inputs (year or location)
    Div_data_set <- observe({
      output$Divplot <- renderPlotly({
        Div_df <- Div_data()
        title <- paste("Comparison of Diversions by Sector for:",get_RUName())
        Div_plot <-  ggplot(data=Div_df,environment = environment())+
          geom_bar(aes(x=Sector,y=Amount, fill=SourceType),stat="identity")+
          theme_bw()+scale_fill_brewer(palette="Paired", name="Source")+
          xlab("Sector")+ylab("Diversions (acre-feet/year)")+ggtitle(title)+
          theme(legend.position="bottom",plot.title = element_text(hjust = 0.5))
        ggplotly(Div_plot)
      })
      
      #List amounts in table
      output$Divtable <-renderTable({
        Div_df <- Div_data()
      },bordered=TRUE,striped=TRUE)
    })  
      
    
    #Returns information about the method
    Divmethod_url <- ('https://water.utah.gov/DWRE/WADE/v0.2/GetMethod/GetMethod.php?methodid=utwre&methodname=DIVERSION')
    Divmethod_df <- get_wade_method(Divmethod_url)
    
    #Prints the method information
    Divlink <- a("Diversion Methodology", href=Divmethod_df$MethodLinkText[[1]])
    output$Divmethodlink <- renderUI({
      tagList("For more information about the methods used for this data, see:",Divlink)
    })
    
})