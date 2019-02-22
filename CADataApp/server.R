# server.R
source("./wadeRfunctions.R")
shinyServer(
  function(input, output,session) {
    #REPORTING UNIT INFO##############################################################################################################################
    load("data/ReportingUnits.Rdata")
    
    #WATER SUPPLY###################################################################################################################################    
    #Fetch water supply data when the user changes the inputs (year or location)
    WS_data <- reactive({
      RUNumber <- RU_df[(RU_df$Name_ID==input$reportingunit),"ReportingUnit"]
      #Fetch and parse data
      xml.urlWS=paste0('http://wade.sdsc.edu/WADE/v0.2/GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=',RUNumber,'&orgid=CA-DWR&reportid=2010&datatype=SUPPLY')
      
      WS_df <- get_wade_data(xml.urlWS)
      
      return(WS_df)
    })
    
    #Returns information about the method
    WSmethod_url='http://wade.sdsc.edu/WADE/v0.2/GetMethod/GetMethod.php?methodid=CA-DWR&methodname=CA%20DWR%20Hydrologic%20Analysis%20(hellyj@ucsd.edu)'
    WSmethod_df <- get_wade_method(WSmethod_url)
    
    #Prints the method information
    WSlink <- a("Water Supply Methodology", href=WSmethod_df$MethodLinkText[[1]])
    output$WSmethodlink <- renderUI({
      tagList("For more information about the methods used for this data, visit:",WSlink)
    })
    
    #Plots the results from the GetSummary call
    output$WSplot <- renderPlot({
      #Get data from reactive function (based on inputs of year and reporting unit)
      WS_df=WS_data()
      WS_dfsub=WS_df[(WS_df$Amount!=0),]
      WS_dfsub$Type=factor(WS_dfsub$Type)
      
      if (input$displaytype=="Barplot"){
        title=paste0("Water Supplies in ",input$reportingunit)
        ggplot(data=WS_dfsub,environment = environment())+
          geom_bar(aes(x=Type,y=Amount, fill=Type),stat="identity")+
          theme_bw()+scale_fill_brewer(palette="GnBu")+
          xlab("Supply Type")+ylab("Water Supply (acre-feet/year)")+ggtitle(title)+
          theme(legend.position="none",plot.title = element_text(hjust = 0.5,size=12))+
          theme(axis.text.x = element_text(angle = 0,hjust=0.5))
      }
      else if (input$displaytype=="Pie Chart"){
        title=paste0("Water Supplies in ",input$reportingunit," by Type")
        pie(WS_dfsub$Amount,labels=WS_dfsub$Type,col=rainbow(length(WS_dfsub$Type)),
              main=title)
      }
      else{
        title=paste0("Water Supplies in ",input$reportingunit)
        dotchart(WS_df$Amount,labels=WS_df$Type,cex=.7,
                 main=title,ps=6,
                 xlab="Water Supply (acre-feet/year)")
      } 
    })
    
    #List amounts in table
    output$WStable <- renderTable({
      WS_df=WS_data()
    },bordered=TRUE, striped=TRUE)
    
    
    #WATER USE###################################################################################################################################    
    #Fetch water supply data when the user changes the inputs (year or location)
    WU_data <- reactive({
      RUNumber <- RU_df[(RU_df$Name_ID==input$reportingunit),"ReportingUnit"]
      #Fetch and parse data
      xml.urlWU=paste0('http://wade.sdsc.edu/WADE/v0.2/GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=',RUNumber,'&orgid=CA-DWR&reportid=2010&datatype=USE')
      WU_df <- get_wade_data(xml.urlWU)
    })
    
    #Returns information about the method
    WUmethod_url='http://wade.sdsc.edu/WADE/v0.2/GetMethod/GetMethod.php?methodid=CA-DWR&methodname=CA%20DWR%20Hydrologic%20Analysis%20(hellyj@ucsd.edu)'
    WUmethod_df <- get_wade_method(WUmethod_url)
    
    #Prints the method information
    WUlink <- a("Water Use Methodology", href=WUmethod_df$MethodLinkText[[1]])
    output$WUmethodlink <- renderUI({
      tagList("For more information about the methods used for this data, visit:",WUlink)
    })
    
    #Plots the results from the GetSummary call
    output$WUplot <- renderPlot({
      #Get data from reactive function (based on inputs of year and reporting unit)
      WU_df=WU_data()
      WU_dfsub=WU_df[(WU_df$Amount!=0),]
      WU_dfsub$Sector=factor(WU_dfsub$Sector)
      if (input$displaytype=="Barplot"){
        title=paste0("Water Use in ",input$reportingunit)
        ggplot(data=WU_dfsub,environment = environment())+
          geom_bar(aes(x=Sector,y=Amount, fill=Sector),stat="identity")+
          theme_bw()+scale_fill_brewer(palette="GnBu")+
          xlab("Sector")+ylab("Water Use (acre-feet/year)")+ggtitle(title)+
          theme(legend.position="none",plot.title = element_text(hjust = 0.5,size=12))+
          theme(axis.text.x = element_text(angle = 0,hjust=0.5))
      }
      else if (input$displaytype=="Pie Chart"){
        title=paste0("Water Use in ",input$reportingunit," by Sector")
        pie(WU_dfsub$Amount,labels=WU_dfsub$Sector,col=rainbow(length(WU_dfsub$Sector)),
            main=title)
      }
      else{
        title=paste0("Water Use in ",input$reportingunit)
        dotchart(WU_df$Amount,labels=WU_df$Sector,cex=.7,
                 main=title,ps=6,
                 xlab="Water Supply (acre-feet/year)")
      } 
    })
    
    #List amounts in table
    output$WUtable <- renderTable({
      WU_df=WU_data()
    },bordered=TRUE, striped=TRUE)
    
  }
)